#show: doc => letter(
$if(subject)$
  subject: [$subject$],
$endif$
$if(subsubject)$
  subsubject: [$subsubject$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    ( name: [$it.name.literal$],
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      $if(it.position)$position: $it.position$,$endif$
      email: [$it.email$] ),
$endif$
$endfor$
    ),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(logo)$
  logo: "$logo$",
$endif$
$if(title)$
  title: "$title$",
$endif$
$if(first)$
  first: "$first$",
$endif$
$if(last)$
  last: "$last$",
$endif$
$if(class)$
  class: "$class$",
$endif$
$if(address)$
  address: "$address$",
$endif$
$if(location)$
  location: "$location$",
$endif$
$if(nref)$
  nref: "$nref$",
$endif$
$if(cc)$
  cc: "$cc$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
  doc,
)
