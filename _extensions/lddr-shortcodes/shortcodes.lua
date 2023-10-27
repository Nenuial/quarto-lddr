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
      calloutDiv["attr"] = ""
      calloutDiv["icon"] = false
      calloutDiv["title"] = "Article de presse"
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    else
      return ""
    end
  end,
  
  ["doc-book"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local documentTitle = pandoc.utils.stringify(meta["title"])
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"]["literal"])

      local calloutContent = pandoc.Inlines{"Ce chapitre est un extrait de ", pandoc.Emph(documentTitle),
        " écrit par ", pandoc.Emph(authorName), "."}
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["attr"] = ""
      calloutDiv["icon"] = false
      calloutDiv["title"] = "Extrait d'ouvrage"
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    else
      return ""
    end
  end,
  
  ["doc-web"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"]["literal"])
      local sourceDate = pandoc.utils.stringify(meta["date"])
      local sourceName = pandoc.utils.stringify(meta["affiliations"][1]["name"])
      local sourceUrl = pandoc.utils.stringify(meta["affiliations"][1]["url"])
      
      local calloutContent = pandoc.Inlines{"Cet article de ", pandoc.Emph(authorName), 
        " provient de ", pandoc.Emph(pandoc.Link(sourceName, sourceUrl)), " (consulté le ",
        pandoc.RawInline('latex', '\\DTMdate{'.. sourceDate .. '}'), ")."}
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["attr"] = ""
      calloutDiv["icon"] = false
      calloutDiv["title"] = "Article internet"
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    else
      return ""
    end
  end,
  
  ["pdf-link"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("html") then
      local link = string.match(PANDOC_STATE['output_file'], "(.*).html")
      
      quarto.utils.dump(link)
      
      local button = pandoc.RawInline('html', '<button type="button" class="btn btn-primary"><i class="bi bi-file-pdf"></i> <em>' .. pandoc.utils.stringify(meta["title"]) .. '</em></button>')
      local dwnlink = pandoc.Link(button, link .. '.pdf')
      return pandoc.Blocks{pandoc.Para(pandoc.Emph("Ce document est uniquement disponible au format PDF.")), pandoc.Para(dwnlink)}
    else
      return ""
    end
  end
}
