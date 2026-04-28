# Get a WRI raster layer

Get a WRI raster layer

## Usage

``` r
get_layer(id, aoi = NULL, aoi_crs = NULL)
```

## Arguments

- id:

  Character. Layer id to retrieve.

- bbox:

  Numeric vector `c(xmin, ymin, xmax, ymax)` in the supplied `crs`. If
  `NULL`, returns the full layer.

- crs:

  Character. Coordinate reference system of `bbox`. Defaults to
  `"EPSG:4326"`.

## Value

A
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html).

## Examples

``` r
if (FALSE) { # \dontrun{
bbox <- c(-122, 37, -121, 38)
rast <- get_layer("WRI_score", bbox = bbox)
} # }
```
