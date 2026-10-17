-- lddr-book.lua: Typst output of the LDDR book
--   * book parts and appendices -> orange-book's #part[] and appendices (from Quarto's orange-book.lua)
--   * \index{sort@Display!sub|see{other}} -> lddr-index-mark(), listed by lddr-make-index()
--   * # Title {head-image="pictures/x/1__head"} -> update-heading-image() just before the chapter's
--     heading: the picture at the top of the chapter, set in the chapter itself
--   * \chapterimage{path} -> update-heading-image(): picture at the top of the next chapter (the LaTeX
--     way, still supported)
--   * \noindent, \vspace{}: dropped (LaTeX layout only)
--   * 10^-12^ -> 10^−12^: a true minus, so that the font's superscripts are used (no "-" in them)
-- The sources keep their LaTeX commands, so that the LaTeX version still works.

local function is_typst_book()
  local file_state = quarto.doc.file_metadata()
  return quarto.doc.is_format("typst") and file_state ~= nil and file_state.file ~= nil
end

-- Typst string literal
local function str(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

-- Arguments of every \name{...} in a LaTeX string (balanced braces)
local function command_args(tex, name)
  local args, pos = {}, 1
  while true do
    local s, e = tex:find("\\" .. name .. "{", pos, true)
    if not s then break end
    local depth, i = 1, e + 1
    while i <= #tex and depth > 0 do
      local c = tex:sub(i, i)
      if c == "{" then depth = depth + 1 elseif c == "}" then depth = depth - 1 end
      i = i + 1
    end
    table.insert(args, tex:sub(e + 1, i - 2))
    pos = i
  end
  return args
end

-- makeindex syntax: sort@Display!sub@Sub|see{Other}
local function index_mark(arg)
  local main, opt = arg:match("^(.-)|(.*)$")
  main = main or arg
  local see = opt and opt:match("^see{(.*)}$")
  local levels = {}
  for level in (main .. "!"):gmatch("(.-)!") do
    local sort, display = level:match("^(.-)@(.*)$")
    sort, display = sort or level, display or level
    table.insert(levels, "(" .. str(sort) .. ", [" .. display:gsub("([%[%]#%*_\\$@<>])", "\\%1") .. "])")
  end
  return "#lddr-index-mark((" .. table.concat(levels, ", ") .. ",)" ..
    (see and (", see: " .. str(see)) or "") .. ")"
end

-- \chapterimage{pictures/x/1__head}: the LaTeX path has no extension
local function chapter_image(path)
  local dir = quarto.project.directory or "."
  if not path:match("%.%w+$") then
    for _, ext in ipairs({ ".pdf", ".png", ".jpg", ".jpeg", ".svg" }) do
      local f = io.open(pandoc.path.join({ dir, path .. ext }), "r")
      if f then f:close(); path = path .. ext; break end
    end
  end
  return "#update-heading-image(image: image(" .. str("/" .. path) .. "))"
end

-- Typst for a raw LaTeX string, or nil to leave it alone
local function convert(tex)
  local out = {}
  for _, arg in ipairs(command_args(tex, "index")) do table.insert(out, index_mark(arg)) end
  for _, arg in ipairs(command_args(tex, "chapterimage")) do table.insert(out, chapter_image(arg)) end
  if #out > 0 then return table.concat(out, "") end
  if tex:match("^%s*\\noindent%s*$") or tex:match("^%s*\\vspace%*?{[^}]*}%s*$") then return "" end
  return nil
end

local function is_tex(el) return el.format == "tex" or el.format == "latex" end

local raw_filter = {
  RawInline = function(el)
    if not quarto.doc.is_format("typst") or not is_tex(el) then return nil end
    local typ = convert(el.text)
    if typ == nil then return nil end
    return pandoc.RawInline("typst", typ)
  end,
  RawBlock = function(el)
    if not quarto.doc.is_format("typst") or not is_tex(el) then return nil end
    local typ = convert(el.text)
    if typ == nil then return nil end
    return pandoc.RawBlock("typst", typ)
  end,
  -- Fira Sans has superscript digits and minus but no superscript hyphen: with a hyphen, Typst
  -- falls back to a smaller, raised text for the whole exponent
  Superscript = function(el)
    if not quarto.doc.is_format("typst") then return nil end
    local first = el.content[1]
    if first and first.t == "Str" and first.text:match("^%-%d") then
      first.text = "\u{2212}" .. first.text:sub(2)
      return el
    end
    return nil
  end,
}

-- From Quarto's bundled orange-book.lua: parts and appendices
local header_filter = {
  Header = function(el)
    if not is_typst_book() then return nil end
    local file = quarto.doc.file_metadata().file
    local bookItemType = file.bookItemType
    if el.level ~= 1 or bookItemType == nil then return nil end
    local head = el.attributes["head-image"]
    el.attributes["head-image"] = nil

    if bookItemType == "part" then
      return pandoc.RawBlock("typst", "#part[" .. pandoc.utils.stringify(el.content) .. "]")
    end

    if bookItemType == "appendix" then
      if file.bookItemNumber == 1 or file.bookItemNumber == nil then
        local language = quarto.doc.language
        local title = (language and language["section-title-appendices"]) or "Appendices"
        -- hide-parent: works around an orange-book bug with unnumbered headings in the TOC
        -- the appendices get the banner of the preface (not the one of the last chapter)
        local start = pandoc.RawBlock("typst", "#update-heading-image(image: lddr-default-image)\n" ..
          "#show: appendices.with(" .. str(title) .. ", hide-parent: true)")
        -- Quarto's synthetic "Appendices" heading: no divider page, as in the LaTeX book
        if el.classes:includes("unnumbered") then return start end
        return { start, el }
      end
    end
    -- the heading reads the picture where it stands: set it just before
    if head then return { pandoc.RawBlock("typst", chapter_image(head)), el } end
    return el
  end,
}

return quarto.utils.combineFilters({
  quarto.utils.file_metadata_filter(),
  header_filter,
  raw_filter,
})
