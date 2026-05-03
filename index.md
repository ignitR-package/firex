# firex R Package

This package provides utilities for querying a local STAC catalog and
retrieving asset information, designed for wildfire resilience data
workflows.

## Key Features

- Hard-coded local STAC catalog path
- Functions to list, filter, and extract properties from STAC items
- Asset URL extraction for COG and other file types
- Ready for extension to remote STAC APIs and COG tile retrieval

## Development Workflow

- Use `devtools::document()` to generate documentation
- Use `devtools::check()` to run package checks
- Use `testthat` for unit testing
- Use `usethis::use_r()` to add new R scripts
- Use `pkgdown` to build package website

## Example Usage

``` r

library(firex)

# Browse the catalog — see all domains, dimensions, and available layers
wri_overview()

# Get the full catalog as a data frame (one row per asset)
df <- wri_overview_df()

# Look up metadata for a specific layer
layer_info("WRI_score")

# Retrieve a raster layer (full extent)
rast <- get_layer("WRI_score")

# Retrieve a raster layer cropped to a bounding box (xmin, ymin, xmax, ymax)
bbox <- c(-122, 37, -121, 38)
rast <- get_layer("WRI_score", bbox = bbox)

# Query STAC items by property
catalog <- wri_overview()
items <- lapply(catalog$data$items, function(x) x$item)
water_status <- query_stac_flexible(items, wri_domain = "water", data_type = "status")
```

See [r-pkgs.org](https://r-pkgs.org/whole-game.html) for best practices.
