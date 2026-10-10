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
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(logo)$
  logo: "$logo$",
$endif$
  doc,
)
