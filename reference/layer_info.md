# Get metadata for one WRI layer

Returns metadata for a single layer from the WRI STAC catalog.

## Usage

``` r
layer_info(layer_id, fresh = TRUE)
```

## Arguments

- layer_id:

  Character. The layer/item id to look up, e.g. \`"WRI_score"\`.

- fresh:

  Logical. If TRUE (default), rebuilds the catalog from disk. If FALSE,
  not implemented yet.

## Value

A one-row data frame containing metadata for the requested layer.
