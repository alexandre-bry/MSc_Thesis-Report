#import "@preview/subpar:0.2.2"

#import "../other-tools/styled-blocks.typ": block-discussion, block-todo

// Uncomment the following line to hide the comments in the final document
#let block-todo = block-todo.with(render: false)
#let block-discussion = block-discussion.with(render: false)

= Introduction <hea:introduction>

#block-todo[Instructions][
  An introduction in which the relevance of the project and its place in the context of geomatics is described, along with a clearly-defined problem statement.
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

In 2024, the @ign and two other French public entities have launched an initiative to bring together partners who can contribute to the development of a nation-wide digital twin @ignAppelCommuns.
In the same blog post, the @ign mentions ecological planning and sustainable land use as some of the priorities this project should accommodate.
In @ignRechercheDefi, it is explained how the @lidarhd --- the first project to collect high-density point clouds on almost the whole territory of France --- is central to the future digital twin.
This comes from the unprecedented precision that it brings compared to previous data used and maintained by the @ign.

In this context, one of the many parts of the future digital twin is buildings.
Many algorithms have been developed to try to reconstruct simple but accurate 3D building models from various data sources, including point clouds.
Some researchers from @tudelft especially developed an algorithm called @roofer which produced great results and was then applied to the whole of the Netherlands.
This successfully created the @3dbag, the first complete dataset of Dutch buildings @Peters22.
This algorithm however requires two input data: a dense 3D point cloud and 2D building @roofprint:pl.
In the Netherlands, the @ahn was used for the point cloud and the @bag was used for the @roofprint:pl.

This is where things become more technical and where the precision provided by @lidarhd becomes interesting.
There are mainly two kinds of 2D building @outline:pl, which are often used interchangeably, even though they can be significantly different once reaching the scale of centimers or decimeters:
- #strong[@footprint:cap:pl]: the 2D outer boundary defined by the vertical projection of the #emph[outer walls/façades] of a building.
- #strong[@roofprint:cap:pl]: the outer boundary defined by the vertical projection of the #emph[roof] of a building.
Usually, due to roof overhangs and gutters, the roof extends further than the walls, meaning that the @footprint is included in the @roofprint.
In the rest of this document, I will use the terms @roofprint and @footprint when possible, and otherwise talk about @outline when talking about any of them or when the differentiation was not made.
Since @roofer uses the points from the roof to reconstruct buildings, it requires a @roofprint to work properly.
But in many other applications --- such as taxes or energy consumption --- an accurate estimation of the area of buildings is necessary, which will be better with a @footprint.
Moreover, different sources of data often make it easier to get either of the two:
- Experts on the field mostly use the walls and therefore measure the @footprint.
- Experts working on aerial imagery can only use the roof as some walls will not be visible, meaning that they measure the @roofprint.
- @als point clouds (such as the @lidarhd and the @ahn) give many points on the roofs and therefore make it easier to extract the @roofprint.
- @tls and @mls point clouds give many points on the walls and therefore make it easier to extract the @footprint.

The @ign already has a dataset containing building @outline:pl, called @bdtopo.
However this dataset has some issues, that can be explained by how it was historically built from different sources.
First, some @outline:pl come from terrain measurements and are therefore @footprint:pl, while others come from aerial image detection and are therefore @roofprint:pl.
This information is contained in the dataset, although it is missing for some buildings.
Then, the georeferencing of these building @outline:pl is often wrong by up to a few meters.
This makes combining them with correctly georeferenced point clouds more complicated.

All in all, the current context combines:
- newly available data with high precision and correct georeferencing (@lidarhd),
- an objective to build a digital twin of France, including 3D buildings with algorithms which would benefit from or require correct building @outline:pl (such as @roofer),
- an existing dataset that provides nation-wide and potentially great data but is however missing harmonization and precise georeferencing (@bdtopo),
- the example of the Netherlands where a great dataset of 3D building models was built from similar point cloud data (@3dbag from @ahn),
- an interesting and not yet fully explored question of the possibility of extracting both an accurate @footprint and an accurate @roofprint from point clouds (more in @hea:related-work).

= Related work <hea:related-work>

#block-todo[Instructions][
  A related work section in which the relevant literature is presented and linked to the project.
]

#block-discussion[Ideas][
  - Not much literature looked into specifically differentiating roofprints and footprints
  - Talk about the literature about:
    - Footprints / roofprints
    - Footprint / roofprint extraction from point clouds
    - Point cloud semantic segmentation
    - Existing datasets
]

== @roofprint:pl:cap and @footprint:pl

I could only find a few research papers about identifying or reconstructing roof overhangs.
The difference between @footprint:pl and @roofprint:pl is often not acknowledged, and most papers talk about @outline:pl.
In the few papers that try to find and compute roof overhangs, the methods are often similar.

#block-discussion[Roof overhangs][
  In @Panday2012, roof overhangs are estimated by sweeping vertical planes perpendicularly to the roof edges.
  A correlation score is computed for each plane, and the best result is kept only if it is a sharp enough peak.

  In @Dahlke2015, a very precise @dsm is used in combination with known or pre-computed @footprint:pl.
  For each edge of the @footprint, the median height on segments parallel to the edge is computed, and the inflection point of the height variation is used as the roofprint edge.

  In @Frommholz2017, the @roofprint is projected onto the @dsm and the zero-crossings of the second-order derivative of height variation is used to estimate the size of the roof overhang.

  #cite(<Goebbels2023>, form: "prose") extends @lod 2 models by identifying potential overhang edges from the @footprint:pl and computing the size of the overhangs from either images or point clouds.

  #cite(<Girard2020>, form: "prose") uses a machine learning model to compute for each pixel of a RGB aerial image a classification of building and building edges, as well as a frame field defining tangents and normals of the buildings.
  Then a complex process is used to construct @roofprint:pl as polygons.

  #cite(<Dai2025>, form: "prose") uses a deep learning model that inputs a point cloud and outputs @footprint:pl as a binary raster.
  The model uses sparse voxel representations for the point cloud and decoder/encoder architectures with a specific 3D attention module.

  #cite(<Saadaoui2025>, form: "prose") uses a full deep learning pipeline that inputs satellite images and outputs @roofprint:pl as polygons.
  A first model identifies building pixels, followed by a residual autoencoder to regularize the segmentation, and finally a lightweight CNN that extract building corners that can be used for polygonization.

]

The most common method consists in sweeping vertical planes perpendicularly to the @roofprint edges or to the @footprint edges depending on what was computed first.
Then, a best-fitting plane is determined among these planes with different criteria.
In @Panday2012, a correlation score is computed for each plane, and the best result is kept only if it represents a sharp enough peak compared to its neighbours.
For each edge of the @footprint, #cite(<Dahlke2015>, form: "prose") computes the median height on segments parallel to the edge using a precise @dsm.
Then, they use the inflection point of the height variation as the roofprint edge.
In #cite(<Frommholz2017>, form: "normal"), the @roofprint is projected onto the @dsm and the zero-crossings of the second-order derivative of height variation are used to estimate the size of the roof overhang.

Other methods are proposed by #cite(<Goebbels2023>, form: "prose") to extend @lod 2 models by identifying potential overhang edges from the @footprint:pl and computing the size of the overhangs from either oblique images or point clouds.
Using obliques images and assuming angles of 45°, they identify the roof overhang in the texture using either edges detection or colour regions, and compute the size of the overhang from this.
The method with point clouds extends the roof planes and identify the inliers with a threshold.

Some interesting machine-learning methods were also proposed to compute building @outline:pl from point clouds and could potentially be used to compute both @footprint:pl and @roofprint:pl.
#cite(<Girard2020>, form: "prose") uses a machine learning model to compute, for each pixel of a RGB aerial image, a classification of building and building edges, as well as a frame field defining tangents and normals of the buildings.
Then a multi-step geometric process is used to construct @roofprint:pl as polygons.
#cite(<Dai2025>, form: "prose") uses a deep learning model that inputs a point cloud and outputs @footprint:pl as a binary raster.
The model uses sparse voxel representations for the point cloud and decoder/encoder architectures with a specific 3D attention module.
I also want to mention #cite(<Saadaoui2025>, form: "normal") which uses an almost full deep learning pipeline to produce @roofprint:pl as polygons.
A first model identifies building pixels, followed by a residual autoencoder to regularize the segmentation, and finally a lightweight CNN that extracts building corners that can be used for polygonization.

As a final note, #cite(<Panday2012>, form: "prose") use an interesting property of buildings that it worth bringing up.
They assume that building roofs are often symmetrical when they are slanted, meaning that the overhang is often the same on both side.
This allows to use more data to compute the size of the roof overhang, and could also help making a reasonable guess if there are no points on one side of a building but many points on the opposite side.

== Point cloud semantic segmentation

Point cloud semantic segmentation consists in assigning a class among a list of predefined classes to each individual point of a point cloud.
Since the @roofprint is computed with the points on the roof and the @footprint comes from the points on the façades, being able to tell them apart would really help the process.
This is why I looked into point cloud semantic segmentation methods.

Some models take range-images as input, which makes processing much more efficient and allows to re-uses all the knowledge developed for processing 2D images #cite(<Biasutti2019>, form: "normal") #cite(<Xu2020>, form: "normal").
Range-images represent the 3D points clouds in 2D by looking at it from the viewpoint of the sensor, which often scans point clouds in lines with almost uniform angular steps.
This is especially beneficial when fast inference is necessary, such as real-time applications.

Other models extend 2D convolutions to 3D in different ways.
#cite(<Thomas2019>, form: "prose") introduced KPConv, a pointwise convolution with weights carried by points that are correlated with the points in the neighbourhood.
#cite(<Li2020>, form: "prose") uses their own geometry-aware convolution and combine it with attention based on points elevation to process @als point clouds.
#cite(<Zhao2020>, form: "prose") took inspiration from self-attention networks for image analysis to build a Point Transformer Layer that can work as a convolutional layer by using the neighbourhood of the points.
With farthest point sampling and trilinear interpolation it allows to build a U-net architecture called PointTransformer that outperformed other models at that time in semantic segmentation.
Its latest iteration PointTransformerv3 improved accuracy, speed and memory usage by getting rid of costly 3D operations like neighbourhood queries which were replaced by serialization of the point clouds using space-filling curves #cite(<Wu2023>, form: "normal").

Since @als point clouds can also be very imbalanced, especially with roof points being easier to get than façade points, I also looked into papers dealing with class-imbalanced datasets.
#cite(<Li2024>, form: "prose") advocated to decouple the optimization of the backbone and the classifier, by alternating them.
Optimization of the backbone happens on a rebalanced set of points, using ground-truth points and pseudo-labelled points, and a custom loss is added against imbalance.
#cite(<Pan2025>, form: "prose") proposed a framework to deal with sparse and inhomogeneous annotations, with a label-aware downsampling strategy and a gradient calibration function to compensate the bias introduced by annotation inhomogeneity.

== Datasets

To be able to train a model and/or to evaluate the results, it would be useful to have datasets that can be used as ground-truth.
Therefore, I looked for @als datasets with semantic segmentation classes differentiating façades and roofs; and for datasets containing both @footprint:pl and @roofprint:pl.

Regarding building outlines, #cite(<Dai2025>, form: "prose") should publish a dataset with more than 3000 building @footprint:pl based on the @als dataset called DALES #cite(<Varney2020>, form: "normal").
However, it is not yet available.

Regarding @als datasets, a few of them make the distinction between roof and façades.
#cite(<Koelle2021>, form: "prose") published the Hessigheim 3D (H3D) dataset which is much denser than @lidarhd (800 pts/m² on average _versus_ 40 pts/m²) #cite(<Gaydon2024>, form: "normal").
There is also the Vaihingen 3D (V3D) dataset acquired by #cite(<Cramer2010>, form: "prose") and then manually labelled by #cite(<Niemeyer2014>, form: "prose") with 780,879 points and a closer average density of 8 pts/m².
Then, there is DublinCity with 260M points and 348 pts/m² on average which even classified windows and doors #cite(<Zolanvari2019>, form: "normal").
The Campus3D dataset contains 937.1M points generated from aerial images #cite(<Li2020a>, form: "normal").
Finally, #cite(<Zachar2023>, form: "prose") proposed the CENAGIS-ALS benchmark, with 550M points and 275 pts/m² on average, classifying stairs, balconeys and chimneys as well as roof and façades.

Then, there are @als datasets which put all the points belonging to buildings in a single class.
Many papers mention the DALES dataset published by #cite(<Varney2020>, form: "prose"), which contains 505M points with 50 pts/m² on average.
Other examples are SensatUrban by #cite(<Hu2020>, form: "prose") which contains 2847M points generated from aerial images, LASDU with 3.12M points with 4 pts/m² on average by #cite(<Ye2020>, form: "prose").
A more recent example is TALD, featuring 121M points and 12 pts/m² on average #cite(<Vijaywargiya2025>, form: "normal").

There is also a very large dataset called FRACTAL, which was made by the @ign with the @lidarhd #cite(<Gaydon2024>, form: "normal").
It contains 9261M points with an average density of 37 pts/m², but unfortunately does not differentiate between roof and façade points.
The paper also explains how other French datasets such as @bdtopo were used to select the areas to include in order to reduce class imbalance.

Finally, to be able to create a dataset more quickly, #cite(<Merizette2025>, form: "prose") explained how they created a new dataset for semantic segmentation of indoor TLS with two different processes: manual labelling and automatic generation of pseudo-labels from a BIM model of the objects.
For the automatic generation, they had experts make a 3D BIM model of the rooms, and then used this model to classify points in the class of the closest object if close enough.

= Research questions

#block-todo[Instructions][
  The research questions are clearly defined, along with the scope (ie what you will not be doing).

  To help you define a "good" research question, read https://geomatics.bk.tudelft.nl/geo2021/templates/Research-Questions_WS-handout.pdf.
]

#block-discussion[Ideas][
  Something like:

  #emph[In which conditions can ALS point clouds be used to generate accurate building @roofprint:pl and @footprint:pl in combination with existing but inaccurate building @outline:pl?]

  Should I mention more specific things about @lidarhd for example?

  Do I need specific sub-questions?
]

The research question of this thesis will be:

#block(
  inset: (
    x: 3em,
  ),
  [#text(
    weight: 600,
    emph[In which conditions can @als point clouds be used to generate accurate building @roofprint:pl and @footprint:pl in combination with existing but inaccurate building @outline:pl?],
  )],
)

I will also try to look into the following sub-questions:

- How do the characteristics of the point cloud (geometry of the scanning device, trajectory of the flying vehicle) impact the whole process?
- Can other characteristics of buildings help compensate the lack of points on the façades?
- How meaningful are the differences obtained between roofprints and footprints in France in terms of distances and areas?

= Methodology <sec:methodology>

#block-todo[Instructions][
  Overview of the methodology to be used.
]

#block-discussion[Ideas][
  - Current plan:
    - Train a model to classify point clouds to separate building façades and roofs:
      - Use AHN and 3DBAG data to make a synthetic dataset
      - Train a DL model on this data
      - Fine-tune this model on French data
    - Compute the roofprint and the footprint geometrically:
      - Start with the roofprint, as it has more points and is easier to identify
      - Then the footprint, probably using the edges of the roofprint as guides
  - Other ideas that we have considered and discarded:
    - A DL model that outputs footprints/roofprints directly
    - ???
]

Based on the literature review and on discussions with my supervisors, I plan to experiment with a process combining machine learning for point cloud semantic segmentation and geometric processing to compute the @roofprint:pl and @footprint:pl.
The possibility of a full machine learning pipeline was rejected because time constraints and the lack of training dataset would likely make it difficult to get robust results.

The first step will be to identify in the point clouds the points corresponding to the façades and the points corresponding to the roof.
To do so, I will train a deep learning model on a custom dataset.
To build the custom dataset, I will use Dutch data mostly, by overlaying the @ahn with the @3dbag.
By doing so, I should be able to classify the @ahn between façade points, roof points and others.
Then, since Dutch buildings have similarities with French buildings, and the @ahn is also similar in density to the @lidarhd, I hope to be able to simply fine-tune the model on a limited amount of French buildings.
In the end, I should end up with the ability to extract points corresponding to buildings, separated between roof and façades.

Then, the geometric process will start by computing the @roofprint, as @als point clouds give many more points on the roofs than on the façades.
How this will be done exactly will depend on the quality of the point cloud semantic segmentation, but many algorithms have been studied to extract roof planes, and I am only really interested in getting the boundaries of the roof.
Once the @roofprint will be computed, I will use it to identify the best vertical plane to match the façade points, parallel to each edge of the @roofprint.
The details still need to be decided and tested, but I hope that this method will work on façades even if they contain few points, and other principles such as symmetry, or the orientation of the roof planes could help to make the best guesses possible with façades containing too few points or no point at all.
This combination of logical decisions and geometric computations should ensure that I can get a realistic result in every situation, compared to using machine learning.

Finally, assessing the results may be a difficult task.
Any dataset with correctly modelled roof overhangs would be useful both in training the semantic segmentation model and in evaluating the method.
However, without such high-quality ground-truths, I may have to build my own dataset of @footprint:pl and @roofprint:pl, in areas of varying difficulty, to assess the accuracy of the algorithm in different scenarios.
The robustness of not using machine learning for the last part could also mean that the focus should be on assessing how the algorithm performs when the classification given by the model on the point cloud is inaccurate or even misleading.
Therefore, there will likely be several iterations to get a robust algorithm in every possible configuration of point cloud and semantic segmentation.

= Preliminary results

#block-todo[Instructions][
  If you have preliminary results, you can show them here.
  This shows that you have actually started the work and you have not only been reading.
]

#block-discussion[Ideas][
  - Classification of AHN with 3DBAG on CloudCompare
  - Not much else?
]

I do not have yet many results to show, as most of the time until now was dedicated to studying literature to decide in which direction to go.
I did however look into the different datasets in France and in the Netherlands that will be interesting for this project, and can illustrate why the methodology was designed as explained in @sec:methodology.

First, the current @outline:pl in @bdtopo are misaligned with both aerial images and with the @lidarhd dataset.
This is visible in @fig:outlines-misalignment, especially compared to the point clouds.

#subpar.grid(
  figure(
    image(
      "../../weekly_notes/2025_12_08/alignment_BD_TOPO-Example_1-BD_ORTHO.png",
    ),
    caption: [First example with aerial images.],
  ),
  figure(
    image(
      "../../weekly_notes/2025_12_08/alignment_BD_TOPO-Example_2-BD_ORTHO.png",
    ),
    caption: [Second example with aerial images.],
  ),

  figure(
    image(
      "../../weekly_notes/2025_12_08/alignment_BD_TOPO-Example_1-LIDAR_HD.png",
    ),
    caption: [First example with @lidarhd.],
  ),
  figure(
    image(
      "../../weekly_notes/2025_12_08/alignment_BD_TOPO-Example_2-LIDAR_HD.png",
    ),
    caption: [Second example with @lidarhd.],
  ),

  columns: 2,
  caption: [The misalignment of the outlines (in purple) with aerial images and @lidarhd.],
  label: <fig:outlines-misalignment>,
)

Then, before starting to implement the classification of the @ahn with the @3dbag, I tried it with CloudCompare on a subset to check if it seemed reasonable and feasible.
First, I looked at the distance between the points and the buildings, keeping only the points classified a “Not classified” and “Building”.
The results are displayed in @fig:ahn-3dbag-distance, and show that the results are indeed promising, with most points from the buildings being at less than 1 m from the @3dbag buildings.


#subpar.grid(
  figure(
    image(
      "../../weekly_notes/2025_12_15/General-Buildings.png",
    ),
    caption: [First example: the buildings in @lod 2.2 from @3dbag.],
  ),
  figure(
    image(
      "../../weekly_notes/2025_12_15/Complex_example-Buildings.png",
    ),
    caption: [Second example: the buildings in @lod 2.2 from @3dbag.],
  ),

  figure(
    image(
      "../../weekly_notes/2025_12_15/General-Classification-White_building_Green_not_classified.png",
    ),
    caption: [First example: the point cloud from @ahn 4 filtered to keep only “Not classified” (green) and “Building” (white).],
  ),
  figure(
    image(
      "../../weekly_notes/2025_12_15/Complex_example-Classification-White_building_Green_not_classified.png",
    ),
    caption: [Second example: the point cloud from @ahn 4 filtered to keep only “Not classified” (green) and “Building” (white).],
  ),

  figure(
    image(
      "../../weekly_notes/2025_12_15/General-Distance-Blue_0m_Red_1m.png",
    ),
    caption: [First example: distance from @ahn 4 points to @3dbag buildings with 0 m for blue, 0.333 m for green, 0.666 m for yellow and 1 m for red. Values higher than 1 m are grey.],
  ),
  figure(
    image(
      "../../weekly_notes/2025_12_15/Complex_example-Distance-Blue_0m_Red_1m.png",
    ),
    caption: [Second example: distance from @ahn 4 points to @3dbag buildings with 0 m for blue, 0.333 m for green, 0.666 m for yellow and 1 m for red. Values higher than 1 m are grey.],
  ),

  columns: (1.1fr, 1fr),
  caption: [Experiment with the distances between @ahn 4 points and @3dbag buildings in @lod 2.2.],
  label: <fig:ahn-3dbag-distance>,
)

Finally, I tried to classify the points based on distances to the @3dbag with 3 classes (roof, facade and other) with `roof` being assigned to the point $p$ if $ "distance" (p, "roof") < min("distance"(p, "facade"), 1) $
This is possible because each polygon in the @3dbag buildings is classified as either roof, wall, or ground surface.
This gave the results shown in @fig:ahn-3dbag-classification.
This shows that this method is promising to automatically produce a training dataset, and it also raises a few caveats:
- Most building parts that are not included in the @lod 2.2 models are not classified in the buildings: balconies, chimneys, dormers and in general all the objects on the roofs or on the walls.
  But since our focus is on the façades and roof boundaries, this is not a problem.
- Roof overhangs and/or the boundaries of the roofs are sometimes/often classified as façades because the @lod 2.2 models don't expand far enough on the sides.
  I plan to improve this by expanding the roof polygons to simulate the overhangs.
- As expected, monuments and modified buildings perform poorly, but are rare enough and not the focus of this project.

#subpar.grid(
  figure(
    image(
      "../../weekly_notes/2025_12_15/Custom_class-Overview-Buildings.png",
    ),
    caption: [First example: the buildings in @lod 2.2 from @3dbag.],
  ),
  figure(
    image(
      "../../weekly_notes/2025_12_15/Custom_class-Closer-Buildings.png",
    ),
    caption: [Second example: the buildings in @lod 2.2 from @3dbag.],
  ),

  figure(
    image(
      "../../weekly_notes/2025_12_15/Custom_class-Overview-Classification.png",
    ),
    caption: [First example: the custom classification of the points (green for roof, red for façade and blue for other).],
  ),
  figure(
    image(
      "../../weekly_notes/2025_12_15/Custom_class-Closer-Classification.png",
    ),
    caption: [Second example: the custom classification of the points (green for roof, red for façade and blue for other).],
  ),

  columns: (1fr, 1fr),
  caption: [Experiment with classifying @ahn 4 points into façade, roof and other from @3dbag buildings in @lod 2.2.],
  label: <fig:ahn-3dbag-classification>,
)



#set page(flipped: true)

= Time planning

#{
  import "@preview/gantty:0.5.1": (
    dependencies.default-dependencies-drawer, dividers.default-dividers-drawer, drawers.default-drawer,
    field.default-field-drawer, gantt, header.default-headers-drawer, milestones.default-milestones-drawer,
    sidebar.default-sidebar-drawer, task.default-tasks-drawer,
  )
  set text(size: 10.2pt)

  let gantt-tasks = (
    (
      name: [Preparation of As],
      subtasks: (
        (
          name: [A1],
          start: "2025-12-23",
          end: "2026-01-23",
        ),
        (
          name: [A2],
          start: "2026-03-01",
          end: "2026-03-30",
        ),
        (
          name: [A3],
          start: "2026-05-01",
          end: "2026-06-01",
        ),
        (
          name: [A4],
          start: "2026-05-01",
          end: "2026-06-15",
        ),
      ),
    ),
    (
      name: [Literature Review],
      subtasks: (
        (
          name: [@footprint:cap and @roofprint],
          start: "2025-11-10",
          end: "2025-11-24",
        ),
        (
          name: [Semantic segmentation],
          start: "2025-11-17",
          end: "2025-12-01",
        ),
        (
          name: [Datasets],
          start: "2025-12-01",
          end: "2025-12-08",
        ),
      ),
    ),
    (
      name: [Point cloud semantic segmentation],
      subtasks: (
        (
          name: [Custom dataset experiments],
          start: "2025-12-08",
          end: "2025-12-15",
        ),
        (
          name: [Custom dataset with @cgal:short],
          start: "2026-01-01",
          end: "2026-01-19",
        ),
        (
          name: [Experiments with different models],
          start: "2026-01-12",
          end: "2026-03-16",
        ),
      ),
    ),
    (
      name: [@roofprint:cap and @footprint extraction],
      subtasks: (
        (
          name: [@roofprint:cap:pl from point clouds],
          start: "2026-02-02",
          end: "2026-02-23",
        ),
        (
          name: [@footprint:cap:pl from point clouds and @roofprint:pl],
          start: "2026-02-23",
          end: "2026-03-16",
        ),
      ),
    ),
    (
      name: [Assessment and improvements],
      subtasks: (
        (
          name: [Comparison to ground-truths],
          start: "2026-03-30",
          end: "2026-04-30",
        ),
        (
          name: [Side cases and robustness],
          start: "2026-03-30",
          end: "2026-04-30",
        ),
      ),
    ),
  )
  let gantt-milestones = (
    (name: "A1", date: "2026-01-23"),
    (name: "A2", date: "2026-03-30"),
    (name: "A3", date: "2026-06-01"),
    (name: "A4", date: "2026-06-15"),
    (name: "Start full-time at IGN", date: "2026-02-02"),
  )
  let gantt-tasks-formatted = (
    show-today: false,
    headers: ("month", "week"),
    tasks: gantt-tasks,
    milestones: gantt-milestones,
  )
  gantt(gantt-tasks-formatted, drawer: (
    sidebar: default-sidebar-drawer,
    field: default-field-drawer,
    headers: default-headers-drawer,
    dividers: default-dividers-drawer,
    tasks: default-tasks-drawer,
    dependencies: default-dependencies-drawer,
    milestones: default-milestones-drawer.with(today-content: none),
  ))
}

#set page(flipped: false)

= Tools and datasets used

#block-todo[Instructions][
  Since specific data and tools have to be used, it's good to present these concretely, so that the mentors know that you have a grasp of all aspects of the project.
]

#block-discussion[Ideas][
  - @cpp + @cgal for processing the AHN and 3DBAG data, and potentially the LIDARHD
  - @python + @pytorch for the DL model to classify point clouds
  - @cgal again quite likely to compute the footprints/roofprints from the classified point cloud
]

The main datasets that will be used are:
- Point clouds: @ahn for the Netherlands and @lidarhd for France.
  The real target is @lidarhd, but @ahn will be used for training in combination with other Dutch datasets and potentially to assess the final method.
  I may also use other point cloud datasets if I find relevant ones with the necessary separation of façade and roof points, such as the Vaihingen dataset.
- 3D models of buildings: @3dbag for the Netherlands and internal examples for France.
  These will be used mostly for the custom dataset and potentially as ground-truths for the @roofprint:pl and @footprint:pl if they can be extracted from them.

The main tools that will be used are:
- @cgal to implement geometric operations both to create the custom dataset and to perform the computation of the @roofprint:pl and @footprint:pl.
- @pytorch to train the semantic segmentation model.
  Libraries like #link("https://github.com/Pointcept/Pointcept")[Pointcept], #link("https://github.com/guochengqian/openpoints")[openpoints] or #link("https://github.com/torch-points3d/torch-points3d")[torch-points3d] could be useful to use existing architectures and speed up the process.
- CloudCompare to visualise results and perform quick experiments.
- High-performance clusters to train the models: #link("https://daic.tudelft.nl/")[DAIC] for TU Delft or #link("https://www.enseignementsup-recherche.gouv.fr/fr/supercalculateur-jean-zay-en-immersion-avec-les-equipes-de-l-idris-cnrs-97962")[Jean Zay] in France.
