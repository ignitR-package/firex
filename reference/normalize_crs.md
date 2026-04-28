# Normalize a CRS specification

Validates a coordinate reference system supplied in any of the common
shorthand formats and returns a canonicalized string that `terra`
recognizes. Useful for checking a CRS value before passing it to
[`get_layer`](https://ignitr-package.github.io/firex/reference/get_layer.md)
or
[`resolve_to_bbox`](https://ignitr-package.github.io/firex/reference/resolve_to_bbox.md).

## Usage

``` r
normalize_crs(crs)
```

## Arguments

- crs:

  One of:

  - An integer EPSG code (e.g. `4326`).

  - A character string: `"EPSG:4326"`, a bare numeric string (`"4326"`),
    a PROJ string, or a WKT string.

  - `NULL` — treated as "no CRS" and returns `TRUE` with no `"crs"`
    attribute.

## Value

A length-1 logical. On success (`TRUE`) carries a `"crs"` attribute
containing the normalized CRS string. On failure (`FALSE`) carries a
`"message"` attribute describing why the input was not recognized.

## Examples

``` r
r <- normalize_crs(4326)
#> Error in normalize_crs(4326): could not find function "normalize_crs"
isTRUE(r)          # TRUE
#> Error: object 'r' not found
attr(r, "crs")     # "EPSG:4326"
#> Error: object 'r' not found

r2 <- normalize_crs("32611")
#> Error in normalize_crs("32611"): could not find function "normalize_crs"
attr(r2, "crs")    # "EPSG:32611"
#> Error: object 'r2' not found

r_bad <- normalize_crs("not-a-crs")
#> Error in normalize_crs("not-a-crs"): could not find function "normalize_crs"
isTRUE(r_bad)      # FALSE
#> Error: object 'r_bad' not found
attr(r_bad, "message")
#> Error: object 'r_bad' not found
```
