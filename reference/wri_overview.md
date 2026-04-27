# Read the WRI STAC catalog

Reads the local STAC catalog and returns a `wri_overview` object.

## Usage

``` r
wri_overview(fresh = TRUE)
```

## Arguments

- fresh:

  Logical. If TRUE (default), rebuilds the catalog from disk. If FALSE,
  not implemented yet (reserved for caching).

## Value

An object of class `wri_overview`.
