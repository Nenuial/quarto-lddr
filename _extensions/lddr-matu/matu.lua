local function exaTitle (el)
  local classes = el.classes or el.attr.classes

  if not classes:includes("section") then
    return nil
  else
    return pandoc.RawInline('tex', "\\sectitle{" .. pandoc.utils.stringify(el.content) .. "}")
  end
end

return {
  {Header = exaTitle}
}