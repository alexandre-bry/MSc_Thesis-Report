#import "../common_imports.typ": *

= Conclusion <hea:conclusion>

How to generate coherent building @roofprint:pl and @footprint:pl from high-density @als point clouds and existing imprecise @outline:pl?

- How to identify and use the points on roof edges in @als point clouds?
- How to identify and use the points in an @als point cloud that contain information about the façades despite their sparsity?
- How to deform an imprecise @outline with global and local transformations while preserving the angles of the edges?

To answer the main research question, I proposed a method to turn imprecise @outline:pl into @roofprint:pl and @footprint:pl sequentially from @als data.
The same general idea is used for the two @outline:pl: first identify the points containing information about the @outline, and then iteratively deform the initial imprecise @outline to fit with the selected points.
The resulting @roofprint:pl were tested successfully on the French national datasets @bdtopo and @lidarhd, while the @footprint:pl were only qualitatively assessed and still require further work.

Regarding points on roof edges, I showed how most of them can be identified with simple topology-aware operations on @als point clouds.
These points can then be used to compute a roofprint in 2D, without having to manipulate the points in 3D for the optimisation of the polygon.
It is however necessary to compute for each point on the roof edge the orientation of the building it corresponds to, in order to prevent the points from a given building to be used by another building.

As for the points containing information about the façades, I showed that it becomes significantly easier to identify them once a 3D roof model is obtained using the @roofprint computed previously.
This allows to simply select all the points below the roof, a simple solution that works well despite the sparsity of the @als data on the façades.
Therefore, the order in which creating the @roofprint and the @footprint is of great importance.
Being able to use at the same time the points on the ground and the points on the façades proved to be challenging but very promising, as the points hitting the ground under the roof are very valuable and sometimes the only available information about the façade.

The question of preserving the interesting properties of the input @outline:pl was tackled by developing a robust deformation algorithm enforcing the necessary constraints.
This algorithm is capable of preserving the angles of the edges and the validity of the polygons while still leaving a lot of freedom for deformations.
This algorithm proved to be very effective to tackle at the same time globally translating the @outline:pl and locally modifying the relations between neighbouring edges.
By iteratively focussing on edges one by one, it also reduces a complex problem with 2 dimensions of freedom per point into a succession of 1-dimensional problems.

This thesis overall fits perfectly into the programme of the MSc Geomatics for the Built Environment.
Buildings and their different representations are at the core of some courses.
The combination of different data sources is also at the core of the programme, in this case high-density @als point clouds, which are becoming increasingly available in several countries, with the existing building @outline:pl datasets, which many countries have in one form or another.
Developing this whole method took a lot of the knowledge acquired during the master, such as how @lidar works and how it affects the structure and properties of @als point clouds, how validity of polygons is crucial to many applications, and how current methods to reconstruct 3D models of buildings work.

#citen(<Albers2016>)
