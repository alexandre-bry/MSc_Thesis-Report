#import "@preview/drafting:0.2.2": *

#import "../../other-tools/styled-blocks.typ": block-discussion, block-todo
#import "../glossary/glossary-terms.typ": gloss-ref-and-footnote, gloss-url

= Introduction <hea:introduction>

#block-todo[Instructions][
  General introduction chapter to the topics for non-experts in the specific topic (but with a general grounding in geomatics). The goal of this chapter is to gently introduce the research and make the full report readable for a non-expert. Thus, you explain the structure (thesis = scientific article+background) and briefly explain the “high-level storyline”, in such a way that a non-expert can understand it. Mention that Part 3 is a scientific article, and note which technical background sections are found in Part 2, and how the background sections in Part 2 relate to the article in Part 3.
]

#block-discussion[Ideas][
  Relevance and context:

  - First nation-wide point cloud dataset of France
  - Similar to the Dutch AHN latest versions in nature (ALS) and in density
  - Goal of creating a 3D digital model of France, requiring great roofprint data
  - Current foot-/roofprint database in France has a few issues:
    - Multiple sources (terrain measurements, aerial images detection, and sometimes unknown)
    - Incorrect georeferencing (with a translation up to a few meters)
  - Fully in the scope of Geomatics for the built environment:
    - Handling of large point clouds
    - Creation of building footprints
    - Importance of geo-referencing for integration with the rest of the IGN data

  Problem statement:

  - Use the newly measured ALS point cloud data of France to produce high-quality boundaries for the buildings in France
  - Try to integrate the existing footprints/roofprints into the method to facilitate the process and/or improve the results
  - Assess the possibility of identifying and differentiating the footprint and the roofprint
]

In 2024, the #gloss-ref-and-footnote("ign") and two other French public entities have launched an initiative to bring together partners who can contribute to the development of a nation-wide digital twin @ignAppelCommuns.
In the same blog post, the @ign mentions ecological planning and sustainable land use as some of the priorities this project should accommodate.
In a different post, it is explained how the @lidarhd --- the first project to collect high-density point clouds on almost the whole territory of France --- is central to the future digital twin #cite(<ignRechercheDefi>).
This comes from the unprecedented precision that it brings compared to previous data used and maintained by the @ign.

In this context, one of the many components of the future digital twin is buildings.
Many algorithms have been developed to try to reconstruct simple but accurate 3D building models from various data sources, including point clouds.
Some researchers from @tudelft especially developed an algorithm called #gloss-ref-and-footnote("roofer") which produced great results and was then applied to the whole of the Netherlands.
This successfully created the @3dbag, the first complete dataset of Dutch buildings in @lod 2.2 @Peters22.
This algorithm however requires two input data: a dense 3D point cloud and 2D building @roofprint:pl.
In the Netherlands, the @ahn was used for the point cloud and the @bag was used for the @roofprint:pl.

This is where things become more technical and where the precision provided by @lidarhd becomes interesting.
There are mainly two kinds of 2D building @outline:pl, which are often used interchangeably, even though they can be significantly different once reaching the scale of centimetres or decimetres:
- #strong[@footprint:cap:pl]: the 2D outer boundary defined by the vertical projection of the #emph[outer walls/façades] of a building.
- #strong[@roofprint:cap:pl]: the 2D outer boundary defined by the vertical projection of the #emph[roof] of a building.
Usually, due to roof overhangs and gutters, the roof extends further than the walls, meaning that the @footprint is included in the @roofprint.
In the rest of this document, I will use the terms @roofprint and @footprint when possible, and otherwise talk about @outline when talking about any of them or when the differentiation was not made.
As an example, the roofprint is what matters in estimating solar energy potential --- in combination with other factors such as roof orientation and angle.
But in many other applications --- such as taxes or energy consumption --- an accurate estimation of the area of buildings is necessary, which will be better with a @footprint.

Adding this distinction to models is also what makes the difference between @lod 2.2 and @lod 2.3, as shown in @fig:lods-illustration.
Since @roofer uses the points from the roof to reconstruct buildings, it requires a @roofprint to work properly, but therefore reconstructs the buildings in @lod 2.2.

#figure(
  image("../../../images/LoDs_illustration-Filip_Biljecki.jpg"),
  caption: [Visual example of the refined @lod:pl for a residential building #cite(<Biljecki2016>, form: "normal").],
  placement: auto,
) <fig:lods-illustration>


Moreover, different sources of data often make it easier to get either of the two:
- Experts on the field mostly use the walls and therefore measure the @footprint.
- Experts working on aerial imagery can only use the roof as some walls will not be visible, meaning that they measure the @roofprint.
- @als point clouds (such as the @lidarhd and the @ahn) give many points on the roofs and therefore make it easier to extract the @roofprint.
- @tls and @mls point clouds give many points on the walls and therefore make it easier to extract the @footprint.

The @ign already has a dataset containing building @outline:pl, called @bdtopo.
However this dataset has some issues, that can be explained by how it was historically built from different sources.
First, some @outline:pl come from terrain measurements and are therefore @footprint:pl, while others come from aerial image detection and are therefore @roofprint:pl.
The dataset contains a column specifying for each @outline which of the two it is, but it is missing for some buildings.
Then, the georeferencing of these building @outline:pl is often wrong by up to a few meters.
This makes combining them with correctly georeferenced point clouds more complicated.

All in all, the current context combines:
- newly available data with high precision and correct georeferencing (@lidarhd),
- an objective to build a digital twin of France, including 3D buildings with algorithms which would benefit from or require correct building @outline:pl (such as @roofer),
- an existing dataset that provides nation-wide and potentially great data but is however missing harmonization and precise georeferencing (@bdtopo),
- the example of the Netherlands where a great dataset of 3D building models was built from similar point cloud data (@3dbag from @ahn),
- an interesting and not yet fully explored question of the possibility of extracting both an accurate @footprint and an accurate @roofprint from point clouds.
