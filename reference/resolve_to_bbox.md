# Resolve an area-of-interest to a bounding box

Accepts an area of interest in several common formats and returns its
axis-aligned bounding box as a numeric vector
`c(xmin, ymin, xmax, ymax)` in the input CRS.

## Usage

``` r
resolve_to_bbox(aoi, aoi_crs = NULL)
```

## Arguments

- aoi:

  Area of interest. Accepted inputs:

  - Numeric vector `c(xmin, ymin, xmax, ymax)` — bounding box; `aoi_crs`
    is required.

  - Character path to a shapefile (`.shp`) or GeoJSON file.

  - An `sf` or `sfc` object.

  - A
    [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html),
    [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html),
    or
    [`terra::SpatExtent`](https://rspatial.github.io/terra/reference/SpatExtent-class.html).

- aoi_crs:

  Character or integer CRS specification (e.g. `"EPSG:4326"` or `4326`).
  Required when `aoi` is a numeric vector or a CRS-less spatial object;
  must be omitted when `aoi` already carries a CRS.

## Value

A length-1 logical. On success (`TRUE`) carries `"bbox"` (numeric
`c(xmin, ymin, xmax, ymax)`) and `"crs"` attributes. On failure
(`FALSE`) carries a `"message"` attribute describing the problem.

## Examples

``` r
result <- resolve_to_bbox(c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")
#> Error in resolve_to_bbox(c(-122, 37, -121, 38), aoi_crs = "EPSG:4326"): could not find function "resolve_to_bbox"
isTRUE(result)        # TRUE
#> Error: object 'result' not found
attr(result, "bbox")  # c(-122, 37, -121, 38)
#> Error: object 'result' not found
attr(result, "crs")   # "EPSG:4326"
#> Error: object 'result' not found
```
