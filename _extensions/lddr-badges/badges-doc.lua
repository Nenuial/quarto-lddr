-- lddr-badges for documents (lddr-doc, lddr-exs, HTML pages): licence and AI
-- icons. Enable it for a project with `filters: [lddr-badges]`.
--
-- Metadata:
--   cc: by-nc-sa      Creative Commons licence (icon available: by-nc-sa)
--   ai: manmade       Me & My Machine label:
--                     manmade | handyman | cyborg | piggybacker | lazyprompter
--   badges: false     no icons
--   badges-signs: [PBd]  (project) the defaults below only for documents with
--                     one of these signatures (others: only explicit cc/ai).
--                     Without it: every document.
--   licence-url: https://df.geoviews.ch/licence.html
--                     (project, per language with babelquarto profiles) page
--                     explaining the icons; PDFs link to this URL, HTML pages
--                     to the page of that name at the project root.
--
-- Defaults: `cc: by-nc-sa` and `ai: manmade` for documents without `author`.
-- Documents with an `author` (press articles, external texts) get no icons
-- unless cc/ai are set: their licence is not yours. Index and listing pages
-- get none.
--
-- Typst: icons at the right of the page header (`header-right` of the
-- lddr-doc/lddr-exs templates, first page). HTML: icons under the title.

local core = dofile(quarto.utils.resolve_path("badges-core.lua"))

local function signedByListed(meta)
  local signs = meta["badges-signs"]
  if not signs then
    return true
  end
  local sign = core.setting(meta, "sign") or ""
  for _, listed in ipairs(signs) do
    if pandoc.utils.stringify(listed) == sign then
      return true
    end
  end
  return false
end

local function isIndex()
  local input = quarto.doc.input_file or PANDOC_STATE.input_files[1] or ""
  return pandoc.path.filename(input):match("^index") ~= nil
end

-- licence-url, else site-url + /licence.html
local function licenceUrl(meta)
  local url = core.setting(meta, "licence-url") or ""
  if url ~= "" then
    return url
  end
  local website = meta.website
  local site = website and website["site-url"] and pandoc.utils.stringify(website["site-url"]) or ""
  return (site:gsub("/$", "")) .. "/licence.html"
end

local function Pandoc(doc)
  local meta = doc.meta
  if meta.badges == false or meta.listing or isIndex() then
    return nil
  end

  local cc, ai = core.setting(meta, "cc"), core.setting(meta, "ai")
  if not meta.author and signedByListed(meta) then
    cc = cc or "by-nc-sa"
    ai = ai or "manmade"
  end
  cc, ai = core.checkLicence(cc), core.checkAi(ai)
  if not cc and not ai then
    return nil
  end

  local lang = core.lang(meta, "fr")
  -- PDF: full URL. HTML: the page at the root of the project, which Quarto
  -- turns into a relative link (with babelquarto each language is its own
  -- project, so French pages point to /fr/licence.html).
  local pageUrl = licenceUrl(meta)
  local pagePath = "/" .. pandoc.path.filename((pageUrl:gsub("#.*$", "")))
  local items = {}
  if cc then
    table.insert(items, { icon = "cc-" .. cc, anchor = "#licence", height = 0.55,
      text = (lang == "fr" and "Licence " or "License ") .. core.LICENCES[cc].label })
  end
  if ai then
    table.insert(items, { icon = "mmm-" .. ai, anchor = "#ia", height = 0.6, text = core.AI_LABELS[ai][lang] })
  end

  if quarto.doc.is_format("typst") then
    local parts = {}
    for _, item in ipairs(items) do
      table.insert(parts, core.typstIcon(item.icon, pageUrl .. item.anchor, item.height))
    end
    meta["header-right"] = pandoc.MetaInlines({
      pandoc.RawInline("typst", "#stack(dir: ltr, spacing: 5pt, " .. table.concat(parts, ", ") .. ")"),
    })
    return doc
  end

  if quarto.doc.is_format("html") then
    -- no negative top margin: on narrow screens the description of the title
    -- block wraps and would cover the icons
    local html = { '<div class="lddr-badges" style="display: flex; flex-wrap: wrap; gap: 0.5rem; margin: 0.5rem 0 1.5rem;">' }
    for _, item in ipairs(items) do
      table.insert(html, core.htmlIcon(item.icon, pagePath .. item.anchor, item.text, math.floor(item.height * 40)))
    end
    table.insert(html, "</div>")
    doc.blocks:insert(1, pandoc.RawBlock("html", table.concat(html)))
    return doc
  end
end

return { { Pandoc = Pandoc } }
