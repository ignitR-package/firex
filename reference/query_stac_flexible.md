# Query STAC items flexibly by any property

Query STAC items flexibly by any property

## Usage

``` r
query_stac_flexible(items, ...)
```

## Arguments

- items:

  List of STAC items

- ...:

  Named property-value pairs to filter by

## Value

Filtered list of items

## Examples

``` r
items <- list(
  list(properties = list(wri_domain = "water", data_type = "status")),
  list(properties = list(wri_domain = "land", data_type = "status"))
)
query_stac_flexible(items, wri_domain = "water", data_type = "status")
#> [[1]]
#> [[1]]$properties
#> [[1]]$properties$wri_domain
#> [1] "water"
#> 
#> [[1]]$properties$data_type
#> [1] "status"
#> 
#> 
#> 
```
