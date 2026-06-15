#import "../common_imports.typ": *

= Conclusion <hea:conclusion>

#review-ravi[try to explicity get back to the research questions posed in the introduction]

With this thesis, I proposed a method to generate @roofprint:pl and @footprint:pl sequentially from @als data.
The same general idea is used for the two @outline:pl: first identify the points containing information about the @outline, and then iteratively deform the initial imprecise @outline to fit with the selected points.

I showed how simple topology-aware operations on @als point clouds are capable of identifying most of the points on roof edges.
I also showed how identifying points for the façades becomes significantly easier despite their sparsity once a 3D roof model is obtained using the @roofprint computed previously.
Therefore, the order in which creating the @roofprint and the @footprint is of great importance.
Being able to use at the same time the points on the ground and the points on the façades proved to be challenging but very promising, as the points hitting the ground under the roof are very valuable and sometimes the only available information about the façade.

To preserve the interesting properties of the input @outline:pl, I also developed a robust deformation algorithm that is capable of preserving the angles of the edges and the validity of the polygons while still leaving a lot of freedom for deformations.
This algorithm proved to be very effective to tackle at the same time globally translating the @outline:pl and locally modifying the relations between neighbouring edges.

This thesis overall fits perfectly into the programme of the MSc Geomatics for the Built Environment.
Buildings and their different representations are at the core of some courses.
The combination of different data sources is also at the core of the programme, in this case high-density @als point clouds, which are becoming increasingly available in several countries, with the existing building @outline:pl datasets, which many countries have in one form or another.
Developing this whole method took a lot of the knowledge acquired during the master, such as how @lidar works and how it affects the structure and properties of @als point clouds, how validity of polygons is crucial to many applications, and how current methods to reconstruct 3D models of buildings work.
