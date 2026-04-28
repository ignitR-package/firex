# Check if a bounding box is valid

Check if a bounding box is valid

## Usage

``` r
is_valid_bbox(bbox, crs = "EPSG:4326")
```

## Arguments

- bbox:

  numeric vector. Expected format: `c(xmin, ymin, xmax, ymax)` in the
  supplied `crs`.

- crs:

  character. Coordinate reference system of the bounding box. Default is
  `"EPSG:4326"`.

## Value

A length-1 logical with `"status"`, `"message"`, and `"bbox"`
attributes. On success, the `"bbox"` attribute contains the validated
bounding box in EPSG:4326.

## Examples

``` r
is_valid_bbox(c(-120, 34, -119, 35))  # TRUE
#> [1] TRUE
#> attr(,"status")
#> [1] "valid"
#> attr(,"bbox")
#> [1] -120   34 -119   35
is_valid_bbox(c(-119, 34, -120, 35))  # FALSE
#> [1] FALSE
#> attr(,"message")
#> [1] "You supplied bbox = c(xmin = -119, ymin = 34, xmax = -120, ymax = 35). `xmin` must be less than `xmax`. "
#> attr(,"status")
#> [1] "invalid"
#> attr(,"bbox")
#> [1] -119   34 -120   35
```
