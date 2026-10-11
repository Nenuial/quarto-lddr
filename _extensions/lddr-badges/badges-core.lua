-- lddr-badges core: what the document badges (badges-doc.lua) and the book
-- badges (badges-book.lua, used by lddr-book) share. Loaded with dofile();
-- returns a table.
--
-- Licence: Creative Commons buttons. AI declaration: Me & My Machine labels
-- (https://mmmlabel.tech/). Icons and their terms: icons/SOURCES.md.

local M = {}

-- Folder of this file, so that the icons are found whoever loads it
local here = debug.getinfo(1, "S").source:gsub("^@", "")
M.dir = pandoc.path.directory(here)

M.AI_LABELS = {
  manmade = { fr = "Réalisé sans IA générative", en = "Made without generative AI" },
  handyman = { fr = "Assisté par l'IA générative", en = "Assisted by generative AI" },
  cyborg = { fr = "Réalisé avec l'IA générative", en = "Made together with generative AI" },
  piggybacker = { fr = "Principalement réalisé par l'IA générative", en = "Mostly made by generative AI" },
  lazyprompter = { fr = "Réalisé par l'IA générative", en = "Made by generative AI" },
}

M.LICENCES = {
  ["by-nc-sa"] = {
    label = "CC BY-NC-SA 4.0",
    url = {
      en = "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en",
      fr = "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr",
    },
  },
}

function M.iconPath(name)
  return pandoc.path.join({ M.dir, "icons", name .. ".svg" })
end

function M.read(path)
  local file = assert(io.open(path, "rb"))
  local content = file:read("a")
  file:close()
  return content
end

function M.dataUri(name)
  return "data:image/svg+xml;base64," .. quarto.base64.encode(M.read(M.iconPath(name)))
end

-- Path from the project root, for Typst (paths starting with "/" are
-- relative to the root Quarto compiles with)
function M.rootPath(path)
  local root = quarto.project.directory
  if root and path:sub(1, #root) == root then
    return path:sub(#root + 1)
  end
  return path
end

-- Typst string literal
function M.str(s)
  return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

function M.setting(meta, key)
  return meta[key] and pandoc.utils.stringify(meta[key]) or nil
end

-- "fr" or "en" from the `lang` of the document (default: `default`)
function M.lang(meta, default)
  local lang = (M.setting(meta, "lang") or default or "fr"):sub(1, 2)
  return (lang == "en" or lang == "fr") and lang or (default or "fr")
end

-- An icon as HTML, linked. Not an <img>: Quarto takes the first image of a
-- page (data: URIs first) as its preview image in listings.
function M.htmlIcon(name, href, label, height)
  local width = name:match("^cc%-") and math.floor(height * 88 / 31) or height
  return '<a href="' .. href .. '" title="' .. label .. '" role="img" aria-label="' .. label
    .. '" style="display: inline-block; flex: none; width: ' .. width .. "px; height: " .. height
    .. "px; background: url('" .. M.dataUri(name) .. "') center / contain no-repeat;\"></a>"
end

-- An icon as Typst, linked (dest: URL string or Typst label like <sec-ai>)
function M.typstIcon(name, dest, height)
  local target = dest:match("^<") and dest or M.str(dest)
  return "link(" .. target .. ", image(" .. M.str(M.rootPath(M.iconPath(name))) .. ", height: " .. height .. "cm))"
end

function M.checkAi(name)
  if name and not M.AI_LABELS[name] then
    quarto.log.warning("lddr-badges: unknown AI label '" .. name .. "'")
    return nil
  end
  return name
end

function M.checkLicence(name)
  if name and not M.LICENCES[name] then
    quarto.log.warning("lddr-badges: no icon for licence '" .. name .. "'")
    return nil
  end
  return name
end

return M
