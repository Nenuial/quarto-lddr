local lustache = require 'assets/lua/lustache'
local function convert_to_empty(value)
  return value == '' and {} or value
end
local solar = {}
for line in io.lines("_extensions/nenuial/lddr-solar/assets/data/solar.csv") do
  local english, french, type_en, type_fr, distance, mass, radius, density, rotation, revolution = line:match(
    "%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-)")
  if english and english ~= "" then
    solar[english] = {
      french = convert_to_empty(french),
      english = convert_to_empty(english),
      type_en = convert_to_empty(type_en),
      type_fr = convert_to_empty(type_fr),
      distance = convert_to_empty(distance),
      mass = convert_to_empty(mass),
      radius = convert_to_empty(radius),
      density = convert_to_empty(density),
      rotation = convert_to_empty(rotation),
      revolution = convert_to_empty(revolution)
    }
  end
end

local english_strings = {
  distance        = "Distance to Sun",
  distance_unit   = "AU",
  mass            = "Mass",
  radius          = "Equatorial radius",
  density         = "Density",
  rotation        = "Rotation period",
  revolution      = "Revolution period",
  revolution_unit = "years"
}

local french_strings = {
  distance        = "Distance au Soleil",
  distance_unit   = "UA",
  mass            = "Masse",
  radius          = "Rayon équatorial",
  density         = "Densité",
  rotation        = "Période de rotation",
  revolution      = "Période de révolution",
  revolution_unit = "années"
}

local function readFile(filePath)
  local file = io.open(filePath, "r")   -- Open the file in read mode
  if not file then
    return nil, "Could not open file"
  end

  local content = file:read("*all")   -- Read the entire file contents
  file:close()                        -- Close the file
  return content
end

return {
  ["solar-data"] = function(args, kwargs, meta)
    local object = pandoc.utils.stringify(args[1])

    local template_file = ""
    local out_type = ""

    if quarto.format.is_html_output() then
      template_file = "_extensions/lddr-solar/assets/templates/solar.html"

      quarto.doc.add_html_dependency({
        name = "solar_style",
        version = "1.0.0",
        stylesheets = { "assets/css/style.css" }
      })
      out_type = "html"
    elseif quarto.format.is_latex_output() then
      template_file = "_extensions/lddr-solar/assets/templates/solar.tex"

      quarto.doc.use_latex_package("tabularx")
      quarto.doc.use_latex_package("multirow")
      quarto.doc.include_file("in-header", "assets/tex/include.tex")
      out_type = "latex"
    else
      return nil
    end

    local template, err = readFile(template_file)
    local view_model = solar[object]

    view_model["image_path"] = "_extensions/lddr-solar/assets/pictures/"

    if args[2] == "en" then
      view_model["name"] = view_model["english"]
      view_model["type"] = view_model["type_en"]
      view_model["translation"] = english_strings
    elseif args[2] == "fr" then
      view_model["name"] = view_model["french"]
      view_model["type"] = view_model["type_fr"]
      view_model["translation"] = french_strings
    end

    output = lustache:render(template, view_model)

    quarto.log.output(output)

    return pandoc.RawBlock(out_type, output)
  end
}
