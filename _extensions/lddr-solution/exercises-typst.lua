-- Typst layout for exercise documents (questions, parts, answer space).
-- Runs after Quarto so that shortcodes such as pagebreak are resolved:
-- Typst forbids page breaks inside containers, so questions are never
-- wrapped as a whole. Only the runs of blocks between page breaks are.

if not quarto.doc.isFormat("typst") then
  return {}
end

local function raw(text)
  return pandoc.RawBlock('typst', text)
end

local function isMarker(inline, marker)
  return inline.t == 'Span' and inline.classes:includes(marker)
end

local function hasLeadingSpan(block, class)
  if block.t ~= 'Para' and block.t ~= 'Plain' then
    return false
  end
  local first = block.content[1]
  return first ~= nil and isMarker(first, class)
end

local function stripLeadingSpan(block)
  block.content:remove(1)
  local first = block.content[1]
  if first ~= nil and (first.t == 'Space' or first.t == 'SoftBreak') then
    block.content:remove(1)
  end
  return block
end

local function isPageBreak(block)
  return block.t == 'RawBlock' and block.format == 'typst'
    and block.text:match('^#pagebreak') ~= nil
end

local function length(options, default)
  local value = options and pandoc.utils.stringify(options) or default
  if value:match('^%.') then
    value = '0' .. value
  end
  return value
end

-- Markers may follow each other on consecutive lines of one paragraph
-- (`[]{.p} first` + newline + `[]{.p} second`): split such paragraphs so
-- that every marker starts its own paragraph.
local function splitAtMarkers(blocks, marker)
  local out = pandoc.Blocks{}
  for _, block in ipairs(blocks) do
    if block.t == 'Para' or block.t == 'Plain' then
      local current = pandoc.Inlines{}
      for _, inline in ipairs(block.content) do
        if isMarker(inline, marker) and #current > 0 then
          while #current > 0 and (current[#current].t == 'SoftBreak'
              or current[#current].t == 'LineBreak' or current[#current].t == 'Space') do
            current:remove(#current)
          end
          out:insert(pandoc.Para(current))
          current = pandoc.Inlines{}
        end
        current:insert(inline)
      end
      out:insert(block.t == 'Para' and pandoc.Para(current) or pandoc.Plain(current))
    else
      out:insert(block)
    end
  end
  return out
end

-- Number the items marked by a leading `[]{.marker}` span and indent the
-- blocks that follow them, splitting the indentation at page breaks.
local function layoutItems(blocks, marker, item)
  local out = pandoc.Blocks{}
  local run = pandoc.Blocks{}
  local inItem = false
  blocks = splitAtMarkers(blocks, marker)

  local function flush()
    if #run > 0 then
      out:insert(raw('#lddr-indent['))
      out:extend(run)
      out:insert(raw(']'))
      run = pandoc.Blocks{}
    end
  end

  for _, block in ipairs(blocks) do
    if hasLeadingSpan(block, marker) then
      flush()
      inItem = true
      out:insert(raw('#' .. item .. '['))
      out:insert(stripLeadingSpan(block))
      out:insert(raw(']'))
    elseif block.t == 'Div' and block.classes:includes('fwe') then
      flush()
      inItem = false
      out:extend(block.content)
    elseif isPageBreak(block) then
      flush()
      out:insert(block)
    elseif inItem then
      run:insert(block)
    else
      out:insert(block)
    end
  end
  flush()

  return out
end

local function exerciseDiv(div)
  if div.classes:includes('answer') then
    return raw('#lddr-answer-lines(' .. length(div.attributes['options'], '3cm') .. ')')
  end

  if div.classes:includes('code') then
    return raw('#lddr-answer-box(' .. length(div.attributes['options'], '3cm') .. ')')
  end

  if div.classes:includes('parts') then
    local blocks = layoutItems(div.content, 'p', 'lddr-part')
    blocks:insert(1, raw('#lddr-parts-start()'))
    return blocks
  end

  if div.classes:includes('questions') then
    local blocks = layoutItems(div.content, 'q', 'lddr-question')
    blocks:insert(1, raw('#lddr-questions-start()'))
    return blocks
  end

  if div.classes:includes('center') then
    local blocks = pandoc.Blocks{raw('#align(center)[')}
    blocks:extend(div.content)
    blocks:insert(raw(']'))
    return blocks
  end

  return nil
end

local function exerciseSpan(span)
  if span.classes:includes('save') then
    return pandoc.RawInline('typst', '#lddr-save-number()')
  end

  if span.classes:includes('restore') then
    return pandoc.RawInline('typst', '#lddr-restore-number()')
  end

  if span.classes:includes('fw') then
    return span.content
  end

  return nil
end

-- A trailing page break adds an empty page in Typst (LaTeX ignores it).
-- Quarto may append empty divs after the content, so skip over those.
local function dropTrailingPageBreaks(doc)
  local i = #doc.blocks
  while i > 0 do
    local block = doc.blocks[i]
    if isPageBreak(block) then
      doc.blocks:remove(i)
    elseif not (block.t == 'Div' and #block.content == 0) then
      break
    end
    i = i - 1
  end
  return doc
end

return {
  {Div = exerciseDiv, Span = exerciseSpan},
  {Pandoc = dropTrailingPageBreaks}
}
