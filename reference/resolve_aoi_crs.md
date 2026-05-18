# Resolve an area-of-interest CRS

Validates a supplied CRS and checks whether an area-of-interest object
already carries one.

## Usage

``` r
resolve_aoi_crs(aoi, aoi_crs = NULL)
```

## Arguments

- aoi:

  Area of interest to inspect for an existing CRS.

- aoi_crs:

  Optional character or integer CRS specification, such as
  \`"EPSG:4326"\` or \`4326\`.

## Value

A length-1 logical with the resolved CRS stored in the \`"crs"\`
attribute on success, or a validation message stored in \`"message"\` on
failure.
