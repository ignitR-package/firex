# Get a WRI raster layer

Retrieves a hosted WRI raster asset and optionally crops it to a spatial
area of interest.

## Usage

``` r
get_layer(id, aoi = NULL, aoi_crs = NULL)
```

## Arguments

- id:

  Character. Layer id to retrieve. See \[wri_overview_df()\] for
  available ids.

- aoi:

  Optional area of interest used to crop the layer. Accepted inputs:

  - \`NULL\`, to return the full layer.

  - Numeric vector \`c(xmin, ymin, xmax, ymax)\`.

  - Character file path readable by \`terra::vect()\` or
    \`terra::rast()\`, such as a shapefile, GeoJSON, GeoPackage, or
    raster file.

  - \`terra\` objects: \`SpatVector\`, \`SpatRaster\`, \`SpatExtent\`,
    \`SpatVectorProxy\`, \`SpatVectorCollection\`,
    \`SpatRasterCollection\`, or \`SpatRasterDataset\`.

  - \`sf\` or \`sfc\` objects.

  - \`sp\` spatial objects.

  - \`raster\` package objects: \`RasterLayer\`, \`RasterStack\`,
    \`RasterBrick\`, or \`Extent\`.

  - A \`bbox\` object or matrix accepted by \`terra::ext()\`.

  CRS-less AOIs, such as numeric bounding boxes and extents, require
  \`aoi_crs\`.

- aoi_crs:

  Optional character or integer CRS specification for \`aoi\`, such as
  \`"EPSG:4326"\` or \`4326\`.

## Value

A \[terra::SpatRaster\] cropped to \`aoi\`, or the full layer when \`aoi
= NULL\`.
