-- lddr-book badges: the licence of the whole book and the AI declaration of each chapter, with the
-- icons of GeoDoc and of the lddr-key keynotes (licence: Creative Commons; AI: Me & My Machine
-- labels, https://mmmlabel.tech/).
--
-- Metadata (_quarto.yml), with the same names as lddr-key and GeoDoc:
--   cc: by-nc-sa        licence of the book: on the back of the title page of the PDF (the
--                       `lddr-copyright` variable of typst-show.typ), explained in the preface
--   ai: handyman        default AI label of the chapters:
--                       manmade | handyman | cyborg | piggybacker | lazyprompter
-- Chapter heading:
--   # Climates {ai="cyborg"}   another label for this chapter; ai="none": no label
-- Numbered chapters get the default label; unnumbered ones (preface, appendices) only an explicit one.
-- The label goes under the chapter title and links to the preface section {#sec-ai} (the first
-- page of the book: index.html, index.fr.html in the French book of babelquarto).
-- Shortcode for the preface: {{< badge-icon mmm-handyman >}} (shortcodes.lua).

local AI_LABELS = {
  manmade = { fr = "Réalisé sans IA générative", en = "Made without generative AI" },
  handyman = { fr = "Assisté par l'IA générative", en = "Assisted by generative AI" },
  cyborg = { fr = "Réalisé avec l'IA générative", en = "Made together with generative AI" },
  piggybacker = { fr = "Principalement réalisé par l'IA générative", en = "Mostly made by generative AI" },
  lazyprompter = { fr = "Réalisé par l'IA générative", en = "Made by generative AI" },
}

local LICENCES = {
  ["by-nc-sa"] = {
    url = { en = "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en", fr = "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr" },
    text = {
      en = "This book is published under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International licence (CC BY-NC-SA 4.0); see the preface. Images and other material from third parties keep their own licence.",
      fr = "Ce livre est publié sous la licence Creative Commons Attribution – Pas d'utilisation commerciale – Partage dans les mêmes conditions 4.0 International (CC BY-NC-SA 4.0) ; voir la préface. Les images et autres contenus de tiers conservent leur propre licence.",
    },
  },
}

local function iconPath(name)
  return quarto.utils.resolve_path("icons/" .. name .. ".svg")
end

local function read(path)
  local file = assert(io.open(path, "rb"))
  local content = file:read("a")
  file:close()
  return content
end

-- Path from the project root, for Typst (paths starting with "/" are relative to the root)
local function rootPath(path)
  local root = quarto.project.directory
  if root and path:sub(1, #root) == root then
    return path:sub(#root + 1)
  end
  return path
end

-- Typst string literal
local function str(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

local lang, defaultAi, licence = "en", nil, nil

local function setting(meta, key)
  return meta[key] and pandoc.utils.stringify(meta[key]) or nil
end

local function readMeta(meta)
  lang = (setting(meta, "lang") or "en"):sub(1, 2) == "fr" and "fr" or "en"
  defaultAi = setting(meta, "ai")
  licence = setting(meta, "cc")
  if defaultAi and not AI_LABELS[defaultAi] then
    quarto.log.warning("badges: unknown AI label '" .. defaultAi .. "'")
    defaultAi = nil
  end
  if licence and not LICENCES[licence] then
    quarto.log.warning("badges: unknown licence '" .. licence .. "'")
    licence = nil
  end
end

-- The licence on the back of the title page of the PDF
local function copyrightMeta(meta)
  if not licence or not quarto.doc.is_format("typst") then return nil end
  local L = LICENCES[licence]
  local author = meta.book and meta.book.author and pandoc.utils.stringify(meta.book.author)
    or (meta.author and pandoc.utils.stringify(meta.author)) or ""
  local typ = "#grid(columns: (auto, 1fr), column-gutter: 1.2em, align: horizon,\n" ..
    "  link(" .. str(L.url[lang]) .. ", image(" .. str(rootPath(iconPath("cc-" .. licence))) .. ", height: 1.1cm)),\n" ..
    "  [© " .. os.date("%Y") .. " " .. author .. ". #text(" .. str(L.text[lang]) .. ")],\n)"
  meta["lddr-copyright"] = pandoc.MetaBlocks({ pandoc.RawBlock("typst", typ) })
  return meta
end

-- The AI label under a chapter title
local function badge(name)
  local label = AI_LABELS[name][lang]
  if quarto.doc.is_format("typst") then
    return pandoc.RawBlock("typst",
      "#block(above: 0.6em, below: 1.4em, link(<sec-ai>)[#box(baseline: 35%, image(" ..
      str(rootPath(iconPath("mmm-" .. name))) .. ", height: 0.8cm)) #h(0.5em) #text(size: 9pt, fill: luma(90), " ..
      str(label) .. ")])")
  end
  if quarto.doc.is_format("html") then
    -- the preface, from the page: index.html at the root of the book, index.fr.html for the
    -- chapters of the French book of babelquarto (*.fr.qmd)
    local input = quarto.doc.input_file or ""
    local offset = quarto.project.offset or "."
    local href = offset .. "/" .. (input:match("%.fr%.qmd$") and "index.fr.html" or "index.html") .. "#sec-ai"
    local img = "data:image/svg+xml;base64," .. quarto.base64.encode(read(iconPath("mmm-" .. name)))
    return pandoc.RawBlock("html",
      '<div class="geobook-ai" style="display: flex; align-items: center; gap: 0.6rem; margin: -0.25rem 0 1.5rem;">' ..
      '<a href="' .. href .. '" title="' .. label .. '"><img src="' .. img .. '" alt="' .. label ..
      '" style="height: 34px; width: auto;"></a>' ..
      '<a href="' .. href .. '" style="font-size: 0.85rem; color: var(--bs-secondary-color, #6c757d); text-decoration: none;">' ..
      label .. "</a></div>")
  end
  return nil
end

local function chapterLabel(el)
  local explicit = el.attributes["ai"]
  el.attributes["ai"] = nil
  if explicit == "none" then return nil end
  if explicit then
    if AI_LABELS[explicit] then return explicit end
    quarto.log.warning("badges: unknown AI label '" .. explicit .. "'")
    return nil
  end
  if el.classes:includes("unnumbered") then return nil end
  return defaultAi
end

local function isPart()
  local state = quarto.doc.file_metadata and quarto.doc.file_metadata()
  return state and state.file and state.file.bookItemType == "part"
end

-- HTML: Quarto has already taken the chapter title out of the page (it becomes the title of the
-- page), so the label of the page is read from the title line of its source file
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
  if explicit then
    if AI_LABELS[explicit] then return explicit end
    quarto.log.warning("badges: unknown AI label '" .. explicit .. "'")
    return nil
  end
  if attrs:match("%.unnumbered") then return nil end
  return defaultAi
end

-- The filter for one output: "html" runs before Quarto's filters, "typst" after them (the parts
-- of the merged PDF book are known then)
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
