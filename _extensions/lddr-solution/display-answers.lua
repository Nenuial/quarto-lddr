local solutionStatus = false
local solutionHeader = "Solution"
local questionNumber = 0

local function readStatus(meta)
  if meta['solution-header'] then
    solutionHeader = meta['solution-header']
  end
  
  if quarto.doc.isFormat("latex") then
    meta['commands'] = {}
    meta['environments'] = {}
    
    meta['commands']['q'] = 'question'
    meta['environments']['answer'] = 'solutionorlines'
    meta['environments']['code'] = 'solutionorbox'
  end
  
  if meta['solutions'] then
    solutionStatus = true
    
    if quarto.doc.isFormat("latex") then
      meta['classoption']:insert(pandoc.Str('answers'))
    end
    
    return meta
  end
  
  return meta
end

local function writeSolutions(divEl)
  if divEl.attr.classes:includes('answer') then
    if quarto.doc.isFormat("html") and not solutionStatus then
      return {}
    end
    
    if solutionStatus then
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["icon"] = false
      calloutDiv["title"] = solutionHeader
      calloutDiv["content"] = divEl.content
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    end
  end
  
  return divEl
end

local function writeQuestions(paraEl)
  if quarto.doc.isFormat("html") then
    firstEl = paraEl.content[1]
    
    if firstEl.attr == nil then
      return paraEl
    end
  
    if firstEl.attr.classes:includes('q') then
      questionNumber = questionNumber + 1
      local questionContent = paraEl
      questionContent.content:remove(1,2)
      return pandoc.OrderedList(paraEl, pandoc.ListAttributes(questionNumber))
    end
  end
  
  return paraEl
end

return {
  {Meta = readStatus},
  {Div = writeSolutions},
  {Para = writeQuestions}
}