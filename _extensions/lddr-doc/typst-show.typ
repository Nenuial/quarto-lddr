#show: doc => document(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(sign)$
  sign: [$sign$],
$endif$
$if(landscape)$
  flipped: true,
$endif$
$if(links-as-notes)$
  links-as-notes: true,
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(header-right)$
  header-right: [$header-right$],
$endif$
$if(logo)$
  logo: "$logo$",
$endif$
  doc,
)
