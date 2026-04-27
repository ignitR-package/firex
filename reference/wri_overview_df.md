# Get WRI catalog as a data frame

Returns a flattened data frame of all STAC items and their metadata.

## Usage

``` r
wri_overview_df(fresh = TRUE)
```

## Arguments

- fresh:

  Logical. If TRUE (default), rebuilds the catalog from disk.

## Value

A data frame with one row per asset (COG/layer).
