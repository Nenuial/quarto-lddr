return {
  ["doc-source"] = function(args, kwargs, meta)
    local calloutDiv = pandoc.Div({})
    calloutDiv.attr.classes:insert("callout-note")
    calloutDiv.content:insert(pandoc.Header(2, "Test"))
    calloutDiv.content:insert("Abc")
    
    -- return calloutDiv
    return nil
  end,
  
  ["download-pdf"] = function()
    if quarto.doc.isFormat("html") then
      quarto.doc.addHtmlDependency({
        name = 'fontawesome6',
        version = '0.1.0',
        stylesheets = {'assets/css/all.css'}
      })
      
      local fileLink = PANDOC_STATE.output_file:gsub(".html","") .. ".pdf"
      
      local downloadLink = pandoc.Link("", fileLink)
      downloadLink.content:insert("Télécharger au format ")
      downloadLink.content:insert(pandoc.RawInline('html', '<i class="fa-solid fa-file-pdf" aria-hidden="true"></i>'))
      
      local asideSpan = pandoc.Span({})
      asideSpan.attr.classes:insert("aside")
      asideSpan.content:insert(downloadLink)
        
      return asideSpan
    end
  end
}