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
    meta['commands']['p'] = 'part'
    meta['commands']['fw'] = 'fullwidth'
    meta['commands']['save'] = 'savenumber'
    meta['commands']['restore'] = 'restorenumber'
    meta['environments']['center'] = 'center'
    meta['environments']['questions'] = 'questions'
    meta['environments']['parts'] = 'parts'
    meta['environments']['answer'] = 'solutionorlines'
    meta['environments']['code'] = 'solutionorbox'
    meta['environments']['fwe'] = 'EnvFullwidth'
  end
  
  if meta['solutions'] then
    solutionStatus = true
    
    if quarto.doc.isFormat("latex") then
      if not meta['classoption'] then
        meta['classoption'] = pandoc.List:new()
      end
      meta['classoption']:insert(pandoc.Str('answers'))
    end
    
    return meta
  end
  
  return meta
end

local function writeSolutions(divEl)
  if divEl.attr.classes:includes('answer') or divEl.attr.classes:includes('code') then
    if quarto.doc.isFormat("html") and not solutionStatus then
      return {}
    end
    
    if solutionStatus then
      
      local calloutDiv = {}
      calloutDiv["icon"] = false
      calloutDiv["title"] = solutionHeader
      calloutDiv["content"] = divEl.content
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    end
  end
  
  return nil
end

local function displaySolutions(divEl)
  if divEl.attr.classes:includes('key-only') and not solutionStatus then
    return {}
  end

  if divEl.attr.classes:includes('student-only') and solutionStatus then
    return {}
  end
  
  return nil
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

local function codeSolutions(divEl)
  if divEl.attr.classes:includes('cell') and divEl.attr.attributes then
    if divEl.attr.attributes['tags'] == 'solution' then
      if solutionStatus then
        return nil
      else
        divEl.content = {}
        return divEl
      end
    end
  end
end

return {
  {Meta = readStatus},
  {Div = writeSolutions},
  {Div = displaySolutions},
  {Div = codeSolutions},
  {Para = writeQuestions}
}