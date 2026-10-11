-- {{< badge-icon <name> [link=URL] >}}: shows an icon of icons/ (cc-by-nc-sa,
-- mmm-manmade...), optionally as a link
local function iconPath(name)
  return quarto.utils.resolve_path("icons/" .. name .. ".svg")
end

local function read(path)
  local file = assert(io.open(path, "rb"))
  local content = file:read("a")
  file:close()
  return content
end

local function rootPath(path)
  local root = quarto.project.directory
  if root and path:sub(1, #root) == root then
    return path:sub(#root + 1)
  end
  return path
end

return {
  ["badge-icon"] = function(args, kwargs)
    local name = pandoc.utils.stringify(args[1])
    local link = kwargs["link"] and pandoc.utils.stringify(kwargs["link"]) or ""
    local height = name:match("^cc%-") and 0.8 or 1.1
    if quarto.doc.is_format("html") then
      local img = '<img src="data:image/svg+xml;base64,' .. quarto.base64.encode(read(iconPath(name)))
        .. '" alt="" style="height: ' .. math.floor(height * 40) .. 'px; width: auto; vertical-align: middle;">'
      if link ~= "" then img = '<a href="' .. link .. '">' .. img .. "</a>" end
      return pandoc.RawInline("html", img)
    end
    if quarto.doc.is_format("typst") then
      local img = 'box(image("' .. rootPath(iconPath(name)) .. '", height: ' .. height .. 'cm))'
      if link ~= "" then img = 'link("' .. link .. '", ' .. img .. ")" end
      return pandoc.RawInline("typst", "#" .. img)
    end
    return pandoc.Str("")
  end,
}
