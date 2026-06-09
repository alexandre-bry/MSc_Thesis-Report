#import "../common_imports.typ": *
#show: isprs-heading

= Conclusion and future work

== Conclusion

To our knowledge, this method is innovative for several reasons.
First, we introduced a simple but efficient way to create new valid polygons from existing polygons with our polygon deformation algorithm.
Our method successively leverages the strengths of existing @outline:pl while preserving a lot of freedom in the deformation of the polygons, allowing not only for global translations and scaling but also more complex local deformations.
Then, we also introduced new and simple yet effective ways to extract information from @als point clouds for @roofprint:pl and @footprint:pl.
Our identification of points on roof edges is promising and relying only on having a correct classification of high vegetation.
As for the @footprint:pl, one of our most important conclusions is the necessity to clearly identify the roof first, because one of the main challenges of producing @footprint:pl is to identify points on the façades, and knowing the exact shape of the roof transforms this into a simple geometric operation.

Then, we also underlined the importance of making correct distinctions between @roofprint:pl and @footprint:pl and more generally to define precisely what we include or not in our 2D representations of buildings.
The complexity and diversity of buildings even sometimes in a single region requires careful definition of what is included or not in their 2D models. 

== Future work

There are many elements of the method which could be improved to produce more robust and understandable results.

An interesting property of most buildings that is not used by this method is the symmetry.
#cite(<Panday2012>, form: "prose") use it to assume that roof overhangs are the same on opposite sides when the roofs are slanted.
This could help computing better estimations by increasing the amount of data that can be used, either by averaging the results on both sides, or by making a reasonable guess if a side is empty based on the other side.
Symmetry is also applicable in many cases to other aspects of buildings such as the slopes of the roofs or the directions of the roof edges.

Some improvements that would very likely improve the results and should be doable in a decent amount of time are related to the polygon deformation algorithm.
This still lacks three key properties to be fully satisfying: continuity, preservation of shared vertices and relations between disconnected polygons.
First, discontinuity comes from having a binary decision on shifting or not each edge, instead of gradually shifting edges as little as possible when the polygon would become invalid.
Then, vertices shared by two polygons are currently lost when their respective edges in each polygon are not shared.
Solving this would imply adding new constraints to the deformation algorithm, as when a vertex is shared by three or more edges, moving one edge requires to move the two other edges by the exact same shift.
Finally, nothing currently prevents two polygons to end up overlapping.
This happens for example when a small building moves too far and ends up matching with the points of another larger building.
This is however undesirable and could be prevented by considering also the neighbouring buildings during the optimisation.

More complex modifications of the polygon deformation method could involve relaxing some of the constraints that were introduced in the algorithm.
For example, one could allow small rotations of the edges or even of the whole @outline:pl if it results in much better scores.
Another idea would be to allow the algorithm to insert new edges, for example by extruding a part of an edge.
These two ideas come from the observation of actual situations where the @bdtopo could have been improved with one of these two techniques.
However, allowing this kind of changes opens the door for very difficult considerations regarding the complexity of the @outline:pl and necessary regularisation.

Another aspect that could significantly improve the results would be better and more reliable ways to classify the point clouds or extract the points of interest.
There are two main directions for this.
The first one would be to try to improve the way roof edge points are currently identified, to make it more robust to vegetation, better at differentiating façade and roof edges, or even more robust to transparent surfaces.
One idea that we had was to identify straight segments corresponding to roof surfaces as in #citep(<Wu2016>), in order to consider the end of the segments as potential roof edges.
The other path would be to focus more generally on @als point cloud semantic segmentation, in order to classify separately at least roofs, façades and ground, and even potentially other classes such as balconies or stairs.
There are a few great datasets which consider these differences in their classification, starting with the oldest: Vaihingen ISPRS by #citep(<Rottensteiner2012>) DublinCity by #citep(<Zolanvari2019>), Hessigheim 3D by #citep(<Koelle2021>) and CENAGIS-ALS by #citep(<Zachar2023>).
These datasets with detailed classification are however difficult to produce, and methods that perform well on the rare classes of façades, balconies or chimneys are still to be developed.

Finally, this whole work revealed limitations in the way building @outline:pl are currently represented and considered.
Roof overhangs and balconies often expand outside of the @outline of the buildings at ground level.
Looking at it in 2D from above, a given position may contain both ground and roof, or balcony and roof, or even all of them at the same time.
The roof overhangs of one building can also be above the roof of another building.
Therefore, representing all these objects using a strict partition of space in 2D prevents accurate representations of all these elements at the same time.
Creating representations that allow for robust and clear delineation of ground, @roofprint:pl, @footprint:pl, balconies and potentially other outdoor elements, by allowing adjacent @roofprint:pl and @footprint:pl to either overlap or share edges depending on the situation is to our knowledge still an open question.
Such a representation of space would certainly benefit from integrating some vertical information about the different objects and could then pave the way for the creation of more detailed 3D models of buildings from @als point clouds.
