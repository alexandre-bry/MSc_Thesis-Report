// Documentation: https://typst.app/universe/package/glossy

#let _glossaryTerms = (
  "File formats": (
    json: (
      short: "JSON",
      long: "JavaScript Object Notation",
      description: [A format for the storage of key-value pairs, arrays and other serialisable values, where objects can be nested arbitrarily allowing for the creation of complex hierarchies.],
    ),
    cityjson: (
      short: "CityJSON",
      description: [A @json\-based encoding for storing 3D city models based on the @citygml standard.],
      url: "https://www.cityjson.org/",
    ),
    geojson: (
      short: "GeoJSON",
      description: [A @json\-based open format for encoding a variety of geographic data structures.],
      url: "https://geojson.org/",
    ),
  ),
  "Software": (
    cpp: (
      short: "C++",
      description: [A high-level, general-purpose programming language, focussed on performance, efficiency, and flexibility.],
      url: "https://en.wikipedia.org/wiki/C%2B%2B",
    ),
    python: (
      short: "Python",
      description: [A widely used, high-level, general-purpose programming language, featuring many libraries in the domain of geospatial and geometric data processing.],
      url: "https://www.python.org/",
    ),
    cgal: (
      short: "CGAL",
      long: "Computational Geometry Algorithms Library",
      description: [An open source software project that provides easy access to efficient and reliable geometric algorithms in the form of a @cpp library.],
      url: "https://www.cgal.org/",
    ),
    pytorch: (
      short: "PyTorch",
      description: [An optimized tensor library for deep learning using GPUs and CPUs],
      url: "https://pytorch.org/",
    ),
    roofer: (
      short: "roofer",
      description: [An algorithm to reconstruct a 3D building model from a point cloud and a 2D roofprint polygon in different @lod:pl up to 2.2.],
      url: "https://github.com/3DBAG/roofer",
    ),
    helios: (
      short: "HELIOS++",
      long: "Heidelberg LiDAR Operations Simulator ++",
      description: [A general-purpose Python package for simulation of terrestrial, mobile and airborne laser scanning surveys.],
      url: "https://github.com/3dgeo-heidelberg/helios",
    ),
  ),
  "Entities": (
    tudelft: (
      short: "TU Delft",
      long: "Delft University of Technology",
      description: [The Dutch university in which this project was carried on.],
      url: "https://www.tudelft.nl/en/",
    ),
    ign: (
      short: "IGN",
      long: "Institut national de l'information géographique et forestière",
      description: [The reference public operator for geographic and forest information in France.],
      url: "https://www.ign.fr/institut/identity-card",
    ),
  ),
  "Datasets": (
    bag: (
      short: "BAG",
      long: "Basisregistratie Adressen en Gebouwen",
      description: [The Dutch dataset of buildings @outline:pl with addresses and other attributes.],
      url: "https://www.kadaster.nl/zakelijk/registraties/basisregistraties/bag",
    ),
    "3dbag": (
      short: "3DBAG",
      article: "the",
      description: [An open 3D building data set that is generated fully automatically based on LiDAR data and covers the whole of the Netherlands.],
      url: "https://docs.3dbag.nl/en/",
    ),
    ahn: (
      short: "AHN",
      long: "Actueel Hoogtebestand Nederland",
      description: [A programme to produce high-density point clouds on the whole Dutch territory, with a new version every few years.],
      url: "https://www.ahn.nl/",
    ),
    bdtopo: (
      short: "BD TOPO",
      description: [The French dataset that contains (among many other types of objects) the buildings @outline:pl, combining @footprint:pl and @roofprint:pl.],
    ),
    lidarhd: (
      short: "LiDAR HD",
      description: [The first project to collect high-density point clouds on the whole territory of France (except Guyane).],
      url: "https://www.ign.fr/institut/programme-lidar-hd-vers-une-nouvelle-cartographie-3d-du-territoire",
    ),
  ),
  "Vocabulary": (
    footprint: (
      short: "footprint",
      plural: "footprints",
      description: [The 2D outer boundary defined by the vertical projection of the outer walls/façades of a building.],
    ),
    roofprint: (
      short: "roofprint",
      plural: "roofprints",
      description: [The 2D outer boundary defined by the vertical projection of the roof of a building.],
    ),
    outline: (
      short: "outline",
      plural: "outlines",
      description: [Used to talk about either a roofprint or a footprint or when they are mixed and the differentiation cannot be made.],
    ),
    lod: (
      short: "LoD",
      plural: "LoDs",
      long: "Level of Detail",
      description: [A concept to differentiate multi-scale representations of semantic 3D city models. It is in practice principally used to indicate the geometric detail of a model, primarily of buildings.],
      url: "https://3d.bk.tudelft.nl/lod/",
    ),
    als: (
      short: "ALS",
      long: "Airborne Laser Scanning",
      description: [
        Aircraft-mounted lidar that emits laser pulses toward the ground, capturing millions of georeferenced points for large-scale terrain and vegetation models.
      ],
      url: "https://en.wikipedia.org/wiki/Lidar",
    ),
    mls: (
      short: "MLS",
      long: "Mobile Laser Scanning",
      description: [
        Vehicle-mounted lidar that records dense point clouds while moving, used for detailed street-level 3-D mapping.
      ],
      url: "https://en.wikipedia.org/wiki/Lidar",
    ),
    tls: (
      short: "TLS",
      long: "Terrestrial Laser Scanning",
      description: [
        Tripod-mounted static lidar that scans surroundings from fixed positions, ideal for high-resolution models of structures and heritage sites.
      ],
      url: "https://en.wikipedia.org/wiki/Lidar",
    ),
    dtm: (
      short: "DTM",
      long: "Digital Terrain Model",
      description: [A digital representation of the bare-earth surface, excluding all natural and man-made features such as vegetation, buildings, and other above-ground objects.],
    ),
    dsm: (
      short: "DSM",
      long: "Digital Surface Model",
      description: [A gridded digital representation of the highest point at every cell location, including all natural and man-made features such as vegetation, buildings, and other above-ground objects.],
    ),
  ),
)


#let glossaryTerms = (:)
#for (group, terms) in _glossaryTerms {
  for (key, term) in terms {
    if ("url" in term.keys()) {
      term.description = [#term.description More information at #link(term.url).]
    }
    term.group = group
    glossaryTerms.insert(key, term)
  }
}

#let gloss-url(key) = {
  return glossaryTerms.at(key).url
}
#let gloss-ref-and-footnote(key) = {
  [#ref(label(key))#footnote[#link(gloss-url(key))]]
}
