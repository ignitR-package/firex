# Check whether a bounding box falls within a layer extent

Checks whether a requested bounding box is fully contained within the
extent of a layer bounding box.

## Usage

``` r
check_extent_overlap(bbox, layer_bbox)
```

## Arguments

- bbox:

  Numeric vector in the form `c(xmin, ymin, xmax, ymax)` in EPSG:4326.

- layer_bbox:

  Numeric vector in the form `c(xmin, ymin, xmax, ymax)` describing the
  layer extent in EPSG:4326.

## Value

A length-1 logical. Returns `TRUE` when `bbox` is fully contained within
the requested layer extent and `FALSE` otherwise. The return value
carries `"status"`, `"message"`, and `"bbox"` attributes that can be
inspected later.

## Details

Overlap outcomes:

- Full overlap - returns `TRUE`

- Partial overlap - returns `FALSE` with a message describing which side
  of the layer extent the bbox exceeds

- No overlap - returns `FALSE` with a message that the bbox does not
  overlap the layer extent
