#import "../common_imports.typ": *

= Introduction <hea:introduction>

In 2024, the #gloss-ref-and-footnote("ign") and two other French public entities have launched an initiative to bring together partners who can contribute to the development of a nation-wide digital twin #citen(<ignAppelCommuns>).
This initiative was officially launched in April 2026 under the name of @junn.
The idea behind a digital twin is to gather in one interface many sources and types of data, in order to make them more discoverable, accessible and usable, and by doing so allow for simulations and discussions based on real, accurate and complex data.
Ecological planning and sustainable land use are presented as some of the priorities this project should accommodate.
In a different post, it is explained how the #gloss-ref-and-footnote("lidarhd") --- the first project to collect high-density point clouds on almost the whole territory of France --- is central to the future digital twin #citen(<ignRechercheDefi>).
This comes from the unprecedented precision that it brings compared to previous data used and maintained by the @ign.

#figure(
  image("../figures/LoDs_illustration-Filip_Biljecki.jpg", width: 70%),
  caption: [Visual example of the refined @lod:pl:short for a residential building #cite(<Biljecki2016>, form: "normal").],
) <fig:lods-illustration>

One of the many components of the future digital twin is buildings.
Many algorithms have been developed to try to reconstruct structured and accurate 3D building models from various data sources, including point clouds.
To characterise the properties of the buildings created by these different methods, 5 @lod:pl have been introduced by #citep(<Groger2012>), before being extended into 16 @lod:pl described by #citep(<Biljecki2016>) and are illustrated in @fig:lods-illustration.
One of the current state-of-the-art algorithms was created by researchers at @tudelft and is called #gloss-ref-and-footnote("roofer") #citen(<Paden2024>).
It was applied to the whole of the Netherlands to create the @3dbag, the first complete dataset of Dutch buildings in #lod-version(2.2) #citen(<Peters2022>).
This algorithm however requires two input data: a dense @als 3D point cloud and 2D building @outline:pl.
In the Netherlands, the @ahn was used as the point cloud and the @bag was used as the @outline:pl.

However, talking about a building @outline is imprecise, as there are many different ways to create a 2D horizontal representation of a building.
There are mainly two kinds of 2D building @outline:pl that we consider in this thesis:
- the @footprint, defined as the horizontal 2D polygon obtained by projecting vertically the #emph[outer walls/façades] of a building,
- the @roofprint, defined as the horizontal 2D polygon obtained by projecting vertically the #emph[roof] of a building and taking its outer boundary.

#figure(
  image("../figures/Footprint_roofprint_on_LoD_23.png", width: 40%),
  caption: [
    Visual definition of the @roofprint and @footprint on the #lod-version[2.3] building example by #citep(<Biljecki2016>).
    The @roofprint in this picture displays the edges of the roof used for the definition and needs to be projected vertically to get the actual @roofprint.
  ],
) <fig:definition-roofprint-footprint>

These definitions are illustrated in @fig:definition-roofprint-footprint.
In the rest of this document, I will use the terms @roofprint and @footprint when possible, and otherwise use @outline for a more general term.
Usually, due to roof overhangs and gutters, the roof extends further than the walls, meaning that the @footprint is included in the @roofprint.
As an example, the @roofprint is what matters in estimating solar energy potential --- in combination with other factors such as roof orientation and angle.
But in many other applications --- such as taxes or energy consumption --- an accurate estimation of the area and volume of buildings is necessary, which will be better with a @footprint.

#let bd-topo-origins = (
  lidarhd: 182114,
  image: 5037996,
  cadastre: 44221475,
  other: 503203,
)
#let bd-topo-origins-percent(origin) = {
  [#{ calc.round(100 * bd-topo-origins.at(origin) / bd-topo-origins.values().sum(), digits: 2) }%]
}

The @ign already has a dataset containing building @outline:pl, called @bdtopo.
However, this dataset has some issues, that can be explained by how it was historically built from different sources.
Most @outline:pl (#bd-topo-origins-percent("cadastre")) come from terrain measurements and are therefore @footprint:pl, but most of the rest (#bd-topo-origins-percent("image")) come from aerial image detection and are therefore @roofprint:pl.
A small proportion was automatically generated from the @lidarhd (#bd-topo-origins-percent("lidarhd")) and the origin of the rest is not specified (#bd-topo-origins-percent("other"))#footnote[These numbers come from the 2026-03-15 version of the @bdtopo.].
The georeferencing of these building @outline:pl is often wrong by up to a few meters.
This makes combining them with correctly georeferenced point clouds more complicated.

All in all, the current context combines:
- an objective to build a digital twin of France, including 3D buildings with algorithms which would benefit from or require correct building @outline:pl (such as @roofer),
- newly available data with high precision and correct georeferencing (@lidarhd),
- the example of the Netherlands where a great dataset of 3D building models was built from similar point cloud data (@3dbag from @ahn),
- an interesting and not yet fully explored question of the possibility of extracting both an accurate @footprint and an accurate @roofprint from point clouds,
- an existing dataset that provides nation-wide and potentially great data but is however missing harmonisation and precise georeferencing (@bdtopo).

Therefore, the research question of this thesis is:

#block(
  inset: (
    x: 3em,
  ),
  [#text(
    weight: 600,
    emph[How to generate coherent building @roofprint:pl and @footprint:pl from high-density @als point clouds and existing imprecise @outline:pl?],
  )],
)

A few more specific sub-questions are also addressed in this thesis:
- How to identify and use the points on roof edges in @als point clouds?
- How to identify and use the points in an @als point cloud that contain information about the façades despite their sparsity?
- How to deform an imprecise @outline with global and local transformations while preserving the angles of the edges?

The core of this report is structured as a research paper, targeted at an expert audience, which can be found in @hea:paper.
To make its content accessible to non-experts, preliminary materials on several different topics are provided in @hea:preliminary-materials, although they still assume some GIS-related knowledge, to the level of the @tudelft Master of Geomatics.
Finally, the report ends with a conclusion and a presentation of potential future work on the topic.
