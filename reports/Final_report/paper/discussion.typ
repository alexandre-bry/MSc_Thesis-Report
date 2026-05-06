#import "../common_imports.typ": *
#show: isprs-heading

= Discussion

#block-todo[Things to mention][
  - Strengths of the method:
    - Preserves the quality of the initial building outlines
    - Can take any kind of outline as an input
    - Robust to outliers and to partial occlusions thanks to the preservation of the initial building outlines
  - Limitations of the method:
    - Relies a lot on the quality of the initial outlines
    - Identification of points of interest requires to exclude vegetation points because they would otherwise be picked
    - Struggles with adjacent buildings for the 3D part
    - A significant number of parameters to set (weights for the energies, distances for the proximity scores, threshold for the identification of roof edge points and for inward directions, etc.)
  - Potential improvements:
    - Training a semantic segmentation machine learning model to identify wall points, roof points and ground points
    - Automating the parameter tuning process
    - Give more freedom to the edge shifting algorithm to improve the outlines when possible (incorrect topology, slightly wrong angles, etc.)
]

An interesting property of most buildings that is not used by this method is the symmetry. #cite(<Panday2012>, form: "prose") used it to assume that roof overhangs are the same on opposite sides when the roofs are slanted, which could help computing better estimations.
If there are points on both sides, it increases the amount of data that can be used and an average of both sides can be a better estimation, while if there are points on only one side, it can be used to make a reasonable guess of the overhang on the opposite side.
