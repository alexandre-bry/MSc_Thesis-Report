#import "../common_imports.typ": *
#show: isprs-heading

#import "@preview/wordometer:0.1.5": total-words, word-count

#word-count(
  total => [
    #block-todo[][This abstract contains #total.words words.] <no-wc>

    In recent years, several methods have been successfully developed to create 3D building models in @lod:short#h(0em)2.2 from @als:short point clouds.
    These methods however rely on 2D horizontal building @outline:pl whose definitions and quality vary significantly.
    There are mainly two types of @outline:pl: @roofprint:pl and @footprint:pl, and having access to both of them allows to reconstruct the façades and the roof independently, therefore improving from @lod:short#h(0em)2.2 to @lod:short#h(0em)2.3 models.
    Moreover, this distinction also allows more precise analyses depending on the use case.
    Therefore, we present a method to construct both a @roofprint and a @footprint from @als:short data and existing inaccurate @outline:pl.
    By first precisely deforming and aligning the @outline on the roof to turn it into the @roofprint, our method can then accurately identify the few ground and façade points available, if there are any, in order to produce a @footprint coherent with the @roofprint.
    Our method preserves the validity of the polygons and the topological relations between them.
    It has been tested successfully on the French national datasets @bdtopo:short and @lidarhd:short.
  ],
  exclude: <no-wc>,
)
