#import "../common_imports.typ": *
#show: isprs-heading

#import "../data/validation/validation.typ": (
  categories-infos, datasets-full, datasets-infos, datasets-labels, datasets-per-category, display-bars,
  display-evolutions, display-table, metrics-infos, nice-tables, roofprints-iter-n-label, simple-categories,
)

= Experiments with real-world data and discussion <sec:experiments>

== Validation dataset

To assess and validate the method, we manually created a validation dataset with accurate and precise @roofprint:pl.
Our main objectives with the creation of this dataset are as follows:
+ it should allow for one-to-one comparisons on individual buildings with the @bdtopo: the identifiers of the new dataset are the ones of the @bdtopo and hopefully correspond to the same actual buildings,
+ the @roofprint:pl should be aligned on the @lidarhd dataset, which is assumed to be the most precise and accurate data source available,
+ the dataset should not be specific to our method, but rather contain precise and accurate @roofprint:pl independently from their shape and position in the @bdtopo.

In practice, we used as much information as necessary to identify correct positions for vertices and edges.
The positions of the points in the @lidarhd was the central criterion, but we also used the intensity when necessary as it sometimes allow to differentiate between different adjacent roofs.
Annotations were conducted in 2D using QGIS, but a 3D viewer was also used to get a better understanding of the point cloud.
When something was unclear, aerial photos or street view photos were also useful.

Regarding the actual shapes of the @roofprint:pl, a few decisions were taken to create accurate and coherent @roofprint:pl.
The version of the @bdtopo that we use as the basis is the current latest one (2026-03-15).
First, even if the @roofprint:pl are based on the @bdtopo, we have a complete freedom to modify the polygons: vertices can be freely added, moved or removed.
Changing the topology and the relations between the different buildings was also allowed.
One example is the creation or deletion of an inner ring representing a hole in the building.
Another example is adding a space between buildings that are adjacent in the @bdtopo.
Moreover, getting approximately right angles was sometimes prioritised over following precisely the points from the @lidarhd, since the alignment of points in @als point clouds is biased by the trajectory of the scan.
This was adapted individually to every building, with aerial photos helping to identify right angles.

#let bd-topo-origins = (
  lidarhd: 182114,
  image: 5037996,
  cadastre: 44221475,
  other: 503203,
)

However, we did not create a dataset for @footprint:pl.
The main reason for this is the lack of time which meant having to prioritise some elements in the dataset compared to others.
Multiple reasons lead us to dismissing @footprint:pl #review-ravi[could you nevertheless do a qualitative assesment, by look at some (common) success and failures cases?] in the dataset to the benefit of @roofprint:pl:
- qualitatively, the method seemed more robust and accurate for @roofprint:pl than for @footprint:pl,
- a @roofprint dataset with diverse buildings seemed more interesting than two smaller datasets for @roofprint:pl and @footprint:pl,
- approximately #{ calc.round(100 * bd-topo-origins.cadastre / bd-topo-origins.values().sum(), digits: 1) }% of the @bdtopo @outline:pl are already @footprint:pl.

We then picked three areas with different types of buildings, to test the method in different situations.
We split the buildings in four different categories (see @fig:validation-dataset):
- #datasets-per-category.isolated_houses.at(0).len() #categories-infos.isolated_houses.name: medium houses and buildings having up to a few storeys, isolated from the buildings around,
- #datasets-per-category.adjacent_houses.at(0).len() #categories-infos.adjacent_houses.name: blocks of adjacent and medium houses and buildings having up to a few storeys,
- #datasets-per-category.low_sheds.at(0).len() #categories-infos.low_sheds.name: low buildings in height, usually in gardens,
- #datasets-per-category.adjacent_blocks_of_flats.at(0).len() #categories-infos.adjacent_blocks_of_flats.name: blocks of adjacent and high buildings.

Note that these numbers are the exact numbers of @roofprint:pl, and buildings were split exactly as in the @bdtopo.
This means that one @roofprint:pl may contain many building units, or one building unit may be split in multiple @roofprint:pl.
For example, the #categories-infos.adjacent_houses.name contains two blocks, one of them being split in individual houses while the other one is not (as shown in @fig:validation-dataset-ozoir-south).
Therefore the amount of building units is likely closer to #{ datasets-per-category.adjacent_houses.at(0).len() + 20 }.

#subpar.super(
  caption: [Validation dataset.],
  scope: "parent",
  placement: auto,
  label: <fig:validation-dataset>,
)[
  #let height = auto
  #grid(
    columns: 3,
    gutter: 2mm,
    figure(
      image("../figures/Validation/Validation_dataset-Ozoir_north.png", height: height),
      caption: [Area in Ozoir-la-Ferrière with isolated houses and small sheds.],
    ),
    [
      #figure(
        image("../figures/Validation/Validation_dataset-Ozoir_south.png", height: height),
        caption: [Area in Ozoir-la-Ferrière with mainly adjacent houses.],
      ) <fig:validation-dataset-ozoir-south>
    ],
    figure(
      image("../figures/Validation/Validation_dataset-Paris.png", height: height),
      caption: [Area in Paris with mainly adjacent blocks of flats.],
    ),
  )
]

== Results

We use three different metrics to evaluate a given polygon $cal(P)$ compared to the ground-truth polygon $cal(Q)$:
+ The intersection over union (IoU) defined as:
  $ "IoU"(cal(P), cal(Q)) = ("area"(cal(P) inter cal(Q))) / ("area"(cal(P) union cal(Q))) $
  The value is between 0 and 1 and higher values are better.
+ The Chamfer distance.
  Points are sampled on the two polygons with a step size $delta$, resulting in two point clouds $P$ and $Q$.
  The distance is then defined as:
  $
    "Chamfer"(cal(P), cal(Q)) = 1/2 ( & sum_(p in P) min_(q in Q) |p - q| #h(10mm) \
                                    + & sum_(q in Q) min_(p in P) |q - p|)
  $
+ The centroid distance, defined as the distance between the centroids of the two polygons.

Overall, the different metrics show that our method reconstructs @roofprint:pl that really improve the initial @outline:pl from the @bdtopo.
It has to be noted however that most of the @outline:pl in the validation dataset correspond to @footprint:pl in the @bdtopo, so comparing them to the hand-annotated @roofprint:pl puts them at a disadvantage.

In all the results shown below, we use the abbreviation "#roofprints-iter-n-label("N")" for the @roofprint:pl resulting of N iterations of the polygon matching algorithm (@alg:polygon-matching).
As displayed in @fig:valid-res-table-all, all the metrics are significantly improved by our method on average for all the buildings.

#[
  #show: nice-tables

  #let figures = ()

  #let categories-captions = (
    all: [Whole dataset.],
    all_except_low_sheds: [Whole dataset except the #categories-infos.low_sheds.name category.],
  )
  #for (category, caption) in categories-captions.pairs() {
    let dataset = datasets-per-category.at(category)
    let fig-cat = [
      #figure(
        display-table(dataset, datasets-labels, metrics-infos, text-size: 9pt),
        caption: caption,
      ) #label("fig:valid-res-table-" + category)
    ]
    figures.push(fig-cat)
  }

  #let fig-all = [
    #figure(
      display-table(datasets-full.values(), datasets-labels, metrics-infos, text-size: 9pt),
      caption: [Whole dataset.],
    ) <fig:valid-res-table-all>
  ]

  #for category in simple-categories {
    let dataset = datasets-per-category.at(category)
    let fig-cat = [
      #figure(
        display-table(dataset, datasets-labels, metrics-infos, text-size: 9pt),
        caption: [Category #categories-infos.at(category).name.],
      ) #label("fig:valid-res-table-" + category)
    ]
    figures.push(fig-cat)
  }

  #subpar.super(
    caption: [Average metrics over different subsets of the validation dataset.],
    scope: "parent",
    placement: auto,
    label: <fig:valid-res-table>,
  )[
    #grid(
      columns: 2,
      column-gutter: 10mm,
      row-gutter: 5mm,
      ..figures
    )
  ]
]

But to see things clearer, the sub-results for the different categories must be considered.
What this shows is that the second and third iterations only worsen the results for #categories-infos.low_sheds.name (see @fig:valid-res-table-low_sheds), while improving them or keeping them constant in the other categories.
Moreover, the final metrics are much worse for the #categories-infos.low_sheds.name category compared to the others, which comes from the combination of multiple factors.
First, buildings in this category usually have smaller areas, meaning that the same shift will result in lower #metrics-infos.iou.name values.
Then, their initial position is significantly worse than for the other categories, as can be seen with the high values of #metrics-infos.centroid_distance.name for the #datasets-infos.bdtopo.name.
Finally, we used for this experiment $gamma_r = 2" m"$ (see @sec:roofprint-points) therefore targeting buildings which roof edges were at at least 2 metres above the ground, which is not always the case in this category.

To get a better understanding of what actually happens, we display the results in two different ways.
First, @fig:valid-res-bar-low_sheds shows the distributions of these metrics at every iteration of the algorithm.
Then, @fig:valid-res-evolutions-low_sheds shows the evolution of the metric for every single building in the #categories-infos.low_sheds.name category.
This shows that most of the buildings for which it was initially correct get better, while for some of them there is no change, which is often explained by the algorithm having identified no useful point in their neighbourhood.
It only gets really worse for 5 out of the #datasets-per-category.low_sheds.at(0).len() in that category.

#[
  #let figures = ()

  #let steps-bars = (
    "iou": 50,
    "chamfer": 50,
    "centroid_distance": 50,
  )
  #let mins-maxs-bars = (
    "iou": (0.0, 1.0),
    "chamfer": (0.0, auto),
    "centroid_distance": (0.0, auto),
  )
  #for (idx, metric-infos) in metrics-infos.values().enumerate() {
    let (min, max) = mins-maxs-bars.at(metric-infos.key)
    let steps = steps-bars.at(metric-infos.key)
    let fig-cat = [
      #figure(
        display-bars(
          datasets-per-category.low_sheds,
          datasets-labels,
          metric-infos,
          steps: steps,
          min: min,
          max: max,
          height: 6cm,
          width: 1.1cm,
        ),
        caption: [#metric-infos.name.],
      ) #label("fig:valid-res-bar-" + categories-infos.low_sheds.key + "-" + metric-infos.key)
    ]
    figures.push(fig-cat)
  }
  #subpar.super(
    caption: [Distribution of the metrics for the polygons in #categories-infos.low_sheds.name.],
    scope: "parent",
    placement: auto,
    label: label("fig:valid-res-bar-" + categories-infos.low_sheds.key),
  )[
    #grid(
      columns: 3,
      column-gutter: 5mm,
      row-gutter: 5mm,
      ..figures
    )
  ]
]

#[
  #let figures = ()

  #let flip-color-map-evolutions = (
    "iou": false,
    "chamfer": true,
    "centroid_distance": true,
  )
  #for (idx, metric-infos) in metrics-infos.values().enumerate() {
    let flip-color-map = flip-color-map-evolutions.at(metric-infos.key)
    let fig-cat = [
      #figure(
        display-evolutions(
          datasets-per-category.low_sheds,
          datasets-labels,
          metric-infos,
          flip-color-map: flip-color-map,
          height: 6cm,
        ),
        caption: [#metric-infos.name.],
      ) #label("fig:valid-res-evolutions-" + categories-infos.low_sheds.key + "-" + metric-infos.key)
    ]
    figures.push(fig-cat)
  }
  #subpar.super(
    caption: [Distribution of the metrics for the polygons in #categories-infos.low_sheds.name.],
    scope: "parent",
    placement: auto,
    label: label("fig:valid-res-evolutions-" + categories-infos.low_sheds.key),
  )[
    #grid(
      columns: 3,
      column-gutter: 5mm,
      row-gutter: 5mm,
      ..figures
    )
  ]
]

A large subset of the actual @roofprint:pl are displayed in @fig:valid-res-images, to compare the evolution between the @bdtopo and of the #datasets-infos.iter3.label, on top of the ground-truth polygons.
This shows that the method works well in most cases, and gives insights on the reasons why it fails in some cases.
@fig:valid-res-images-ozoir_north-bdtopo and @fig:valid-res-images-ozoir_north-rfpt3 show the different behaviours for the sheds depending on their surroundings.
When there is a large building close by, the polygon ends up fitting to this building instead of the shed, whereas when the neighbourhood is empty of higher points, the polygon stays in position.

#{
  let height = 30%
  subpar.super(
    caption: [Visualisation of the results in different parts of the dataset. The polygons of the assessed datasets are coloured based on their #metrics-infos.iou.name values compared to the ground-truth polygons.],
    scope: "parent",
    placement: auto,
    label: label("fig:valid-res-images"),
  )[
    #grid(
      columns: 2,
      column-gutter: 5mm,
      row-gutter: 5mm,

      [#figure(
        image("../figures/Validation/Validation_dataset-Ozoir_north-BD_TOPO.png", height: height),
        caption: [Validation and @bdtopo.],
      )<fig:valid-res-images-ozoir_north-bdtopo>],
      [#figure(
        image("../figures/Validation/Validation_dataset-Ozoir_north-Roofprints_3.png", height: height),
        caption: [Validation and #datasets-infos.iter3.label.],
      )<fig:valid-res-images-ozoir_north-rfpt3>],

      figure(
        image("../figures/Validation/Validation_dataset-Ozoir_south-BD_TOPO.png", height: height),
        caption: [Validation and @bdtopo.],
      ),
      figure(
        image("../figures/Validation/Validation_dataset-Ozoir_south-Roofprints_3.png", height: height),
        caption: [Validation and #datasets-infos.iter3.label.],
      ),

      figure(
        image("../figures/Validation/Validation_dataset-Paris-BD_TOPO.png", height: height),
        caption: [Validation and @bdtopo.],
      ),
      figure(
        image("../figures/Validation/Validation_dataset-Paris-Roofprints_3.png", height: height),
        caption: [Validation and #datasets-infos.iter3.label.],
      ),
    )
  ]
}

== Discussion

The strengths of the method come from its ability to combine the strengths of the two data sources: the well estimated façade orientations and topology of the initial @outline:pl and the positioning accuracy of the @als point cloud.
Thanks to its ability to not only shift the polygons but also deform them, the method can take any @outline as input, as long as it has the characteristics mentioned in @sec:input-data.
The method is robust to outliers and to partial occlusions thanks to considering the @outline:pl globally and not only individual edges.

However, relying on the angles of the initial @outline:pl is not always desirable.
Moreover, our assumption is that the method can produce accurate @roofprint:pl even given @footprint:pl as an input, because we observed in practice that they are most of the time less complex.
However, it also happens sometimes that roofs have details that are not present at the bottom of the buildings and therefore the perfect @roofprint is more complex than the initial @footprint.
It is for example the case when a building has the same exact balcony at every storey, resulting in an extrusion of the façade that could also be part of the @roofprint.
In this case as well as many other cases where the initial @outline simply lacks some details, it would be necessary to complexify the initial @outline to get more accurate results.

The classification of the point cloud is also a crucial aspect of the input.
Our method requires points corresponding to high vegetation to be dismissed, because these points will otherwise be identified as points of the roof edges.
Since the method completely removes these points to compute the @roofprint, it can lead to inaccurate results if a whole side of a building is classified as vegetation.
Regarding the classification of ground points for the @footprint:pl, it is a less crucial requirement for two reasons.
First, ground points are usually well classified, with geometric methods such as CSF by #citep(<Zhang2016a>) already producing great results.
Then, the proposed metric used for @footprint:pl still looks improvable, and it may be possible to get similar or even better results without relying on this separation.

On top of that, the method has not really been tested yet with @lidar obtained with different @als sensor geometries.
The results are expected to be similar for @roofprint:pl, but potentially very different for @footprint:pl, as the number of points on the façades and on the ground below the roof depends heavily on the scan angle.

Finally, the method has a significant number of parameters to tune.
These parameters are related to different parts of the method:
- the extraction of the points on the roof edges,
- the amount of shift to try to apply to the edges for @roofprint:pl and for @footprint:pl,
- the metrics used to score the @roofprint:pl and the @footprint:pl.

Many of these parameters have interpretations that can help setting them to correct defaults by computing properties over the point cloud and by having information about the buildings to identify, such as the point cloud density or the height of the buildings.
But some of them are mathematical objects that are more complex to optimise, such as the weighting of the different terms in the metrics, which can be interpreted as balancing the quality of the point cloud and the initial @outline:pl, and requires more human input and knowledge about the datasets.
