-- lddr-badges for books (used by lddr-book): the licence of the whole book and
-- the AI declaration of each chapter. Loaded by lddr-book's badges-html.lua
-- and badges-typst.lua; returns function(stage) -> filter.
--
-- Metadata (_quarto.yml), same names as for documents (badges-doc.lua):
--   cc: by-nc-sa        licence of the book: on the back of the title page of
--                       the PDF (the `lddr-copyright` variable of lddr-book's
--                       typst-show.typ), explained in the preface
--   ai: handyman        default AI label of the chapters:
--                       manmade | handyman | cyborg | piggybacker | lazyprompter
-- Chapter heading:
--   # Climates {ai="cyborg"}   another label for this chapter; ai="none": none
-- Numbered chapters get the default label; unnumbered ones (preface,
-- appendices) only an explicit one. The label goes under the chapter title and
-- links to the preface section {#sec-ai} (the first page of the book:
-- index.html, index.fr.html in the French book of babelquarto).
-- Icons in the preface: shortcode {{< badge-icon mmm-handyman >}}.

local core = dofile(pandoc.path.join({ pandoc.path.directory(debug.getinfo(1, "S").source:gsub("^@", "")), "badges-core.lua" }))

local LICENCE_TEXT = {
  ["by-nc-sa"] = {
    en = "This book is published under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International licence (CC BY-NC-SA 4.0); see the preface. Images and other material from third parties keep their own licence.",
    fr = "Ce livre est publié sous la licence Creative Commons Attribution – Pas d'utilisation commerciale – Partage dans les mêmes conditions 4.0 International (CC BY-NC-SA 4.0) ; voir la préface. Les images et autres contenus de tiers conservent leur propre licence.",
  },
}

local lang, defaultAi, licence = "en", nil, nil

local function readMeta(meta)
  lang = core.lang(meta, "en")
  defaultAi = core.checkAi(core.setting(meta, "ai"))
  licence = core.checkLicence(core.setting(meta, "cc"))
end

-- The licence on the back of the title page of the PDF
local function copyrightMeta(meta)
  if not licence or not quarto.doc.is_format("typst") then return nil end
  local author = meta.book and meta.book.author and pandoc.utils.stringify(meta.book.author)
    or (meta.author and pandoc.utils.stringify(meta.author)) or ""
  local typ = "#grid(columns: (auto, 1fr), column-gutter: 1.2em, align: horizon,\n"
    .. "  " .. core.typstIcon("cc-" .. licence, core.LICENCES[licence].url[lang], 1.1) .. ",\n"
    .. "  [© " .. os.date("%Y") .. " " .. author .. ". #text(" .. core.str(LICENCE_TEXT[licence][lang]) .. ")],\n)"
  meta["lddr-copyright"] = pandoc.MetaBlocks({ pandoc.RawBlock("typst", typ) })
  return meta
end

-- The AI label under a chapter title
local function badge(name)
  local label = core.AI_LABELS[name][lang]
  if quarto.doc.is_format("typst") then
    return pandoc.RawBlock("typst",
      "#block(above: 0.6em, below: 1.4em, link(<sec-ai>)[#box(baseline: 35%, image("
      .. core.str(core.rootPath(core.iconPath("mmm-" .. name))) .. ", height: 0.8cm)) #h(0.5em) #text(size: 9pt, fill: luma(90), "
      .. core.str(label) .. ")])")
  end
  if quarto.doc.is_format("html") then
    -- the preface, from the page: index.html at the root of the book,
    -- index.fr.html for the chapters of the French book of babelquarto
    local input = quarto.doc.input_file or ""
    local offset = quarto.project.offset or "."
    local href = offset .. "/" .. (input:match("%.fr%.qmd$") and "index.fr.html" or "index.html") .. "#sec-ai"
    return pandoc.RawBlock("html",
      '<div class="lddr-badges" style="display: flex; align-items: center; gap: 0.6rem; margin: -0.25rem 0 1.5rem;">'
      .. core.htmlIcon("mmm-" .. name, href, label, 34)
      .. '<a href="' .. href .. '" style="font-size: 0.85rem; color: var(--bs-secondary-color, #6c757d); text-decoration: none;">'
      .. label .. "</a></div>")
  end
  return nil
end

local function chapterLabel(el)
  local explicit = el.attributes["ai"]
  el.attributes["ai"] = nil
  if explicit == "none" then return nil end
  if explicit then return core.checkAi(explicit) end
  if el.classes:includes("unnumbered") then return nil end
  return defaultAi
end

local function isPart()
  local state = quarto.doc.file_metadata and quarto.doc.file_metadata()
  return state and state.file and state.file.bookItemType == "part"
end

-- HTML: Quarto has already taken the chapter title out of the page (it becomes
-- the title of the page), so the label is read from the title line of the
-- source file
local function sourceLabel()
  local input = quarto.doc.input_file
  local file = input and io.open(input, "r")
  if not file then return nil end
  local title
  for line in file:lines() do
    if line:match("^# ") then title = line; break end
  end
  file:close()
  if not title then return nil end
  local attrs = title:match("{(.-)}%s*$") or ""
  local explicit = attrs:match('ai="([^"]*)"') or attrs:match("ai=(%S+)")
  if explicit == "none" then return nil end
  if explicit then return core.checkAi(explicit) end
  if attrs:match("%.unnumbered") then return nil end
  return defaultAi
end

-- The filter for one output: "html" runs before Quarto's filters, "typst"
-- after them (the parts of the merged PDF book are known then)
return function(stage)
  return {
    {
      Pandoc = function(doc)
        if not quarto.doc.is_format(stage) then return nil end
        readMeta(doc.meta)
        if stage == "html" then
          local name = sourceLabel()
          if name then doc.blocks:insert(1, badge(name)) end
          return doc
        end
        doc.blocks = doc.blocks:walk(quarto.utils.combineFilters({
          quarto.utils.file_metadata_filter(),
          {
            Header = function(el)
              if el.level ~= 1 or isPart() then return nil end
              local name = chapterLabel(el)
              if not name then return el end
              local b = badge(name)
              if not b then return el end
              return { el, b }
            end,
          },
        }))
        doc.meta = copyrightMeta(doc.meta) or doc.meta
        return doc
      end,
    },
  }
end
