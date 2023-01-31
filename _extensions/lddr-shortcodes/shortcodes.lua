return {
  ["doc-source"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"])
      local sourceDate = pandoc.utils.stringify(meta["date"])
      local sourceName = pandoc.utils.stringify(meta["authors"][1]["affiliation"]["name"])
      local sourceUrl = pandoc.utils.stringify(meta["authors"][1]["affiliation"]["url"])
      
      local calloutHeader = pandoc.Header(2, "Article de presse")
      local calloutContent = pandoc.Inlines{"Cet article de ", pandoc.Emph(authorName), 
        " a été publié le ", sourceDate, " par ", 
        pandoc.Emph(pandoc.Link(sourceName, sourceUrl)), "."}
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["content"] = pandoc.Blocks{calloutHeader, calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    end
  end
}