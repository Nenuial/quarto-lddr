local getLang = function(meta)
  local lang = pandoc.utils.stringify(meta['lang']):sub(1,2)
  if lang == nil then
    lang = 'en'
  end
  return lang
end

local translate = function(dict, lang)
  return dict[lang]
end

return {
  ["doc-press"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local lang = getLang(meta)
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"]["literal"])
      local sourceDate = pandoc.utils.stringify(meta["date"])
      local sourceName = pandoc.utils.stringify(meta["affiliations"][1]["name"])
      local sourceUrl = pandoc.utils.stringify(meta["affiliations"][1]["url"])
      
      local calloutContent = pandoc.Inlines{
          translate({en = "This article from ", fr = "Cet article de "}, lang),
          pandoc.Emph(authorName),
          translate({en = " has been published on ", fr = " a été publié le "}, lang),
          sourceDate,
          translate({en = " by ", fr = " par "}, lang),
          pandoc.Emph(pandoc.Link(sourceName, sourceUrl)), "."
        }
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["icon"] = false
      calloutDiv["title"] = translate({en = "Press article", fr = "Article de presse"}, lang)
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    else
      return ""
    end
  end,
  
  ["doc-book"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local lang = getLang(meta)
      local bookTitle = pandoc.utils.stringify(meta["book"])
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"]["literal"])

      local calloutContent = pandoc.Inlines {
        translate({en = "This chapter is an excerpt from ", fr = "Ce chapitre est un extrait de "}, lang),
        pandoc.Emph(bookTitle),
        translate({en = " written by ", fr = " écrit par "}, lang),
        pandoc.Emph(authorName), "."}
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["icon"] = false
      calloutDiv["title"] = translate({en = "Excerpt", fr = "Extrait d'ouvrage"}, lang)
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    else
      return ""
    end
  end,
  
  ["doc-web"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("pdf") then
      local lang = getLang(meta)
      local authorName = pandoc.utils.stringify(meta["authors"][1]["name"]["literal"])
      local sourceDate = pandoc.utils.stringify(meta["date"])
      local sourceName = pandoc.utils.stringify(meta["affiliations"][1]["name"])
      local sourceUrl = pandoc.utils.stringify(meta["affiliations"][1]["url"])
      
      local calloutContent = pandoc.Inlines{
        translate({en = "This article from ", fr = "Cet article de "}, lang),
        pandoc.Emph(authorName), 
        translate({en = " is from ", fr = " provient de "}, lang),
        pandoc.Emph(pandoc.Link(sourceName, sourceUrl)),
        translate({en = " (last consulted ", fr = " (consulté le "}, lang),
        sourceDate,
        ")."
      }
      
      local calloutDiv = {}
      calloutDiv["type"] = "note"
      calloutDiv["icon"] = false
      calloutDiv["title"] = translate({en = "Internet article", fr = "Article internet"}, lang)
      calloutDiv["content"] = pandoc.Blocks{calloutContent}
      
      calloutOut = quarto.Callout(calloutDiv)
      
      return calloutOut
    else
      return ""
    end
  end,
  
  ["pdf-link"] = function(args, kwargs, meta)
    if quarto.doc.isFormat("html") then
      local lang = getLang(meta)
      local link = string.match(PANDOC_STATE['output_file'], "(.*).html")
      
      local button = pandoc.RawInline('html', '<button type="button" class="btn btn-primary"><i class="bi bi-file-pdf"></i> <em>' .. pandoc.utils.stringify(meta["title"]) .. '</em></button>')
      local dwnlink = pandoc.Link(button, link .. '.pdf')
      return pandoc.Blocks{
        pandoc.Para(pandoc.Emph(
          translate({en = "This document is only available in PDF format.", fr = "Ce document est uniquement disponible au format PDF."}, lang)
        )),
        pandoc.Para(dwnlink)
      }
    else
      return ""
    end
  end
}
