return {
  ["doc-press"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"]["literal"])
      local sourceDate = pandoc.utils.stringify(meta["date"])
      local sourceName = pandoc.utils.stringify(meta["affiliations"][1]["name"])
      local sourceUrl = pandoc.utils.stringify(meta["affiliations"][1]["url"])
      
      local calloutContent = pandoc.Inlines{"Cet article de ", pandoc.Emph(authorName), 
        " a été publié le ", pandoc.RawInline('latex', '\\DTMdate{'.. sourceDate .. '}'), " par ", 
        pandoc.Emph(pandoc.Link(sourceName, sourceUrl)), "."}
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["icon"] = false
      calloutDiv["title"] = "Article de presse"
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    end
  end,
  
  ["doc-book"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local documentTitle = pandoc.utils.stringify(meta["title"])
      local authorName = pandoc.utils.stringify(meta["authors"][1]["literal"])

      local calloutContent = pandoc.Inlines{"Ce chapitre est un extrait de ", pandoc.Emph(documentTitle), " écrit par ", pandoc.Emph(authorName), "."}
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["icon"] = false
      calloutDiv["title"] = "Extrait d'ouvrage"
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    end
  end
}
