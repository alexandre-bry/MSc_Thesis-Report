#import "../common_imports.typ": *
#show: isprs-heading

= Related work <hea:related-work>

The topic of roof overhangs reconstruction is not widely covered in the literature, with only a few papers addressing issues related to roof overhangs.
The difference between @footprint:pl and @roofprint:pl is often not acknowledged, with the term @outline:pl often used interchangeably, or even @roofprint:pl being called @footprint:pl.

On the other hand, the extraction of building @outline:pl from @als data has been intensively studied, with the output being most of the time @roofprint:pl.
Many methods try to extract them directly without any other input.
Among these methods, some use variations of famous geometric algorithms such as the Hough transform #citen(<Widyaningrum2019>), the medial axis transform #citen(<Widyaningrum2020>), the alpha-shape #citen(<Liu2024>), triangulations #citen(<Awrangjeb2016>), or even combinations of those #citen(<Albers2016>).
More recently, many deep-learning methods have emerged using for example generative adversarial networks #citen(<Kong2022>), or U-net architectures with attention modules #citen(<Dai2025>).
However, most of these methods struggle to produce clean polygons directly and therefore need to end with regularisation steps.
This is also often true for methods that use images as an input (in combination or not with @als data), as going from rasters to clean and accurate polygons is not trivial.
Therefore, starting from already clean polygonal @outline:pl to improve them can significantly improve the quality of the final @outline:pl.

Regarding roof overhangs, the most common method to estimate them among the few related articles consists in taking the vertical plane that passes through the existing edge, and sweep it in the perpendicular direction.
Depending on what was computed first, the existing edge can be a @roofprint edges or a @footprint edge.
Then, a best-fitting plane is determined among these planes with different criteria, by matching with the available data.
In #cite(<Panday2012>, form: "prose"), a correlation score is computed for each plane using a point cloud, and the best result is kept only if it represents a sharp enough peak compared to its neighbours.
For each edge of the @footprint, #cite(<Dahlke2015>, form: "prose") computes the median height on segments parallel to the edge using a precise 2.5D @dsm with a resolution between 5 and 20 cm.
Then, they use the inflection point of the height variation as the @roofprint edge.
In #cite(<Frommholz2017>, form: "prose"), the @roofprint is projected onto the 5 cm resolution @dsm and the zero-crossings of the second-order derivative of height variation are used to estimate the size of the roof overhang.

Other methods are proposed by #cite(<Goebbels2023>, form: "prose") to extend #lod-version(2.2) models by identifying potential overhang edges from the @footprint:pl and computing the size of the overhangs from either oblique images or point clouds.
Using obliques images and assuming angles of 45°, they identify the roof overhang in the texture using either edges detection or colour regions, and compute the size of the overhang from this.
The method with point clouds extends the roof planes and identifies the inliers with a threshold.

Some interesting machine-learning methods were also proposed to compute building @outline:pl from point clouds and could potentially be used to compute both @footprint:pl and @roofprint:pl.
#cite(<Girard2020>, form: "prose") uses a machine learning model to compute, for each pixel of a RGB aerial oblique image, a classification of building and building edges, as well as a frame field defining tangents and normals of the buildings.
Then a multi-step geometric process is used to construct @roofprint:pl as polygons.
With this kind of aerial data as an input, reconstructing @roofprint:pl is easier than @footprint:pl due to half of the façades being occluded.
#cite(<Dai2025>, form: "prose") uses a deep learning model that inputs a point cloud and outputs @footprint:pl as a binary raster.
The model uses sparse voxel representations for the point cloud and decoder/encoder architectures with a specific 3D attention module.
#cite(<Saadaoui2025>, form: "prose") on the other hand uses an almost full deep learning pipeline to produce @roofprint:pl as polygons, getting rid of the constraints of rasterization.
A first model identifies building pixels, followed by a residual auto-encoder to regularise the segmentation, and finally a lightweight CNN that extracts building corners that can be used for polygonization.

Registration of building outlines based on point cloud data has already been studied by #cite(<Boussik2026>, form: "prose").
Different kinds of transformations were assessed: rigid transformations combining global translations and rotations, non-rigid transformations with individual displacements of the vertices, and semi-rigid transformations with individual displacements of edges along their normals.
Semi-rigid transformations of the polygons gave the best results in their case studies and guided us towards this choice.
However, we introduced a different approach to clustering the edges to prevent self-intersections.
In their method, they cluster the edges beforehand based on angles to prevent self-intersections for neighbour edges which are almost parallel.
We softened the constraint by clustering dynamically when displacements break the validity of the polygon, therefore allowing for more precise modifications of the polygons in cases of rounded @outline:pl.
As illustrated by #citep(<Oosterom2005>), the validity of polygons is a very complex topic, but in this paper, we focus solely on preventing rings from self-intersecting, and assume that the method can be extended with more complex validity checks if necessary.

Regarding reference data, to the best of our knowledge, there is a lack of datasets featuring @als data combined with both @footprint:pl and @roofprint:pl, making it difficult to evaluate the results of the methods that we propose.
The only mention of a similar dataset that we found is #cite(<Dai2025>, form: "prose") stating that they will release a dataset with more than 3000 building @footprint:pl based on the @als dataset called DALES #cite(<Varney2020>, form: "normal").
However, it is not yet available at the time of writing this paper.
