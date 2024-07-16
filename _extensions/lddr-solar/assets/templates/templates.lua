local templates = {}

templates["html"] = [[
<div class='grid object-box'>
  <div class='g-col-3'>
    <img src='{{ image_path }}{{ english }}.png'></img>
  </div>
  <div class='g-col-9'>
    <div class='grid'>
      <div class='g-col-12 fw-bold h4'>{{ name }}</div>
    </div>
    <div class='grid'>
      <div class='g-col-6 fw-bold'>Type</div>
      <div class='g-col-6'>{{ type }}</div>
    </div>
    {{#distance}}
    <div class='grid'>
      <div class='g-col-6 fw-bold'>{{ translation.distance }}</div>
      <div class='g-col-6'>{{ distance }} {{ translation.distance_unit }}</div>
    </div>
    {{/distance}}
    <div class='grid'>
      <div class='g-col-6 fw-bold'>{{ translation.mass }}</div>
      <div class='g-col-6'>{{ mass }} kg</div>
    </div>
    <div class='grid'>
      <div class='g-col-6 fw-bold'>{{ translation.radius }}</div>
      <div class='g-col-6'>{{ radius }} km</div>
    </div>
    <div class='grid'>
      <div class='g-col-6 fw-bold'>{{ translation.density }}</div>
      <div class='g-col-6'>{{ density }} g/cm<sup>3</sup></div>
    </div>
    <div class='grid'>
      <div class='g-col-6 fw-bold'>{{ translation.rotation }}</div>
      <div class='g-col-6'>{{ rotation }}</div>
    </div>
    {{#revolution}}
    <div class='grid'>
      <div class='g-col-6 fw-bold'>{{ translation.revolution }}</div>
      <div class='g-col-6'>{{ revolution }} {{translation.revolution_unit }}</div>
    </div>
    {{/revolution}}
  </div>
</div>
]]

templates["tex"] = [[
\begin{planet}
	\begin{tabularx}{\linewidth}{p{3cm} >{\bfseries}p{4cm} X}
		\multirow{4}{\linewidth}{\includegraphics[width=2.8cm]{ {{{ image_path }}}{{ english }}}} & \multicolumn{2}{X}{\bfseries\Large {{ name }} }\\
		& Type: & {{ type }}\\
    {{#distance}}
    & {{ translation.distance }} & {{ distance }} {{ translation.distance_unit }}\\
    {{/distance}}
		& {{ translation.mass }} & {{ mass }} kg\\
		& {{ translation.radius }} & {{ radius }} km\\
		& {{ translation.density }} & {{ density }} g/cm\textsuperscript{3}\\
		& {{ translation.rotation }} & {{ rotation }}\\
    {{#revolution}}
    & {{ translation.revolution }} & {{ revolution }} {{ translation.revolution_unit }}\\
    {{/revolution}}
	\end{tabularx}
\end{planet}
]]

return templates
