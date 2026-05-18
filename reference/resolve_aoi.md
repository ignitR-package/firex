# Resolve an area of interest

Converts supported area-of-interest inputs to a \`terra\` polygon,
bounding box, extent, and CRS.

## Usage

``` r
resolve_aoi(aoi, aoi_crs = NULL)
```

## Arguments

- aoi:

  Area of interest. Accepted inputs include \`NULL\`, a numeric vector
  \`c(xmin, ymin, xmax, ymax)\`, a character file path readable by
  \`terra::vect()\` or \`terra::rast()\`, or an object supported by
  \`terra::ext()\`.

- aoi_crs:

  Optional character or integer CRS specification for \`aoi\`, such as
  \`"EPSG:4326"\` or \`4326\`.

## Value

A length-1 logical with result metadata stored in attributes, including
\`"aoi"\`, \`"bbox"\`, \`"extent"\`, \`"crs"\`, \`"type"\`, and
\`"message"\` when validation fails.
