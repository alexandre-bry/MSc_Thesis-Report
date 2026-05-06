#import "../common_imports.typ": *
#show: isprs-heading

= Related Work <hea:related-work>

#block-todo[Things to mention][
  - Related work on roof overhangs
  - Related work on roof estimation from airborne LiDAR data?
]

The topic of roof overhangs reconstruction is not widely covered in the literature, with only a few papers addressing issues related to roof overhangs.
The difference between @footprint:pl and @roofprint:pl is often not acknowledged, with the term @outline:pl often used interchangeably.

The most common method to estimate roof overhangs consists in sweeping vertical planes perpendicularly to the @roofprint edges or to the @footprint edges depending on what was computed first.
Then, a best-fitting plane is determined among these planes with different criteria.
In @Panday2012, a correlation score is computed for each plane, and the best result is kept only if it represents a sharp enough peak compared to its neighbours.
For each edge of the @footprint, #cite(<Dahlke2015>, form: "prose") computes the median height on segments parallel to the edge using a precise 2.5D @dsm with a resolution between 5 and 20 cm.
Then, they use the inflection point of the height variation as the roofprint edge.
In #cite(<Frommholz2017>, form: "normal"), the @roofprint is projected onto the 5 cm resolution @dsm and the zero-crossings of the second-order derivative of height variation are used to estimate the size of the roof overhang.

Other methods are proposed by #cite(<Goebbels2023>, form: "prose") to extend @lod 2 models by identifying potential overhang edges from the @footprint:pl and computing the size of the overhangs from either oblique images or point clouds.
Using obliques images and assuming angles of 45°, they identify the roof overhang in the texture using either edges detection or colour regions, and compute the size of the overhang from this.
The method with point clouds extends the roof planes and identify the inliers with a threshold.

Some interesting machine-learning methods were also proposed to compute building @outline:pl from point clouds and could potentially be used to compute both @footprint:pl and @roofprint:pl.
#cite(<Girard2020>, form: "prose") uses a machine learning model to compute, for each pixel of a RGB aerial image, a classification of building and building edges, as well as a frame field defining tangents and normals of the buildings.
Then a multi-step geometric process is used to construct @roofprint:pl as polygons.
#cite(<Dai2025>, form: "prose") uses a deep learning model that inputs a point cloud and outputs @footprint:pl as a binary raster.
The model uses sparse voxel representations for the point cloud and decoder/encoder architectures with a specific 3D attention module.
#cite(<Saadaoui2025>, form: "prose") on the other hand uses an almost full deep learning pipeline to produce @roofprint:pl as polygons, getting rid of the constraints of rasterization.
A first model identifies building pixels, followed by a residual autoencoder to regularize the segmentation, and finally a lightweight CNN that extracts building corners that can be used for polygonization.

Regarding data, to our knowledge, there is a lack of datasets featuring @als data combined with both @footprint:pl and @roofprint:pl, making it difficult to evaluate the results of the methods that we propose.
The only mention of a similar dataset that we found is #cite(<Dai2025>, form: "prose") stating that they will release a dataset with more than 3000 building @footprint:pl based on the @als dataset called DALES #cite(<Varney2020>, form: "normal").
However, it is not yet available at the time of writing this.

