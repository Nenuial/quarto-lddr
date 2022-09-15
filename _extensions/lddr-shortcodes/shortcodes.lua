return {
  ["doc-source"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"]["literal"])
      local sourceDate = pandoc.RawInline('latex', '\\DTMdate{' .. pandoc.utils.stringify(meta["date"]) .. '}')
      local sourceName = pandoc.utils.stringify(meta["affiliations"][1]["name"])
      local sourceUrl = pandoc.utils.stringify(meta["affiliations"][1]["url"])
      
      local calloutDiv = pandoc.Div({})
      calloutDiv.attr.classes:insert("callout-note")
      calloutDiv.attr.attributes["icon"] = "false"
      calloutDiv.content:insert(pandoc.Header(2, "Article de presse"))
      calloutDiv.content:insert(pandoc.Inlines{"Cet article de ", pandoc.Emph(authorName), " a été publié le ", sourceDate, " par ", pandoc.Emph(pandoc.Link(sourceName, sourceUrl)), "."})
      
      -- return calloutDiv
      return calloutDiv
    end
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