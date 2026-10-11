-- {{< badge-icon <name> [link=URL] >}}: an icon of icons/ (cc-by-nc-sa,
-- mmm-manmade...), optionally as a link; for the pages that explain the
-- licence and the AI labels (preface of a book, licence page of a site).

local core = dofile(quarto.utils.resolve_path("badges-core.lua"))

return {
  ["badge-icon"] = function(args, kwargs)
    local name = pandoc.utils.stringify(args[1])
    local link = kwargs["link"] and pandoc.utils.stringify(kwargs["link"]) or ""
    local height = name:match("^cc%-") and 0.8 or 1.1
    if quarto.doc.is_format("html") then
      local img = '<img src="' .. core.dataUri(name) .. '" alt="" style="height: ' .. math.floor(height * 40)
        .. 'px; width: auto; vertical-align: middle;">'
      if link ~= "" then img = '<a href="' .. link .. '">' .. img .. "</a>" end
      return pandoc.RawInline("html", img)
    end
    if quarto.doc.is_format("typst") then
      local img = "box(image(" .. core.str(core.rootPath(core.iconPath(name))) .. ", height: " .. height .. "cm))"
      if link ~= "" then img = "link(" .. core.str(link) .. ", " .. img .. ")" end
      return pandoc.RawInline("typst", "#" .. img)
    end
    return pandoc.Str("")
  end,
}
