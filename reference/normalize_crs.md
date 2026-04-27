# Normalize a CRS specification

Accepts CRS in several common formats and returns a terra-recognized
form.

## Usage

``` r
normalize_crs(crs)
```

## Arguments

- crs:

  One of: an integer EPSG code (e.g. `4326`); a character string (e.g.
  `"EPSG:4326"`, `"4326"`, a PROJ string, or a WKT string); or a
  SpatVector, SpatRaster, or SpatExtent whose CRS will be pulled. Pass
  `NULL` to return `NULL`.

## Value

A length-1 logical with `"status"`, `"message"`, and `"crs"` attributes.
On success, `"crs"` contains the normalized CRS string.
