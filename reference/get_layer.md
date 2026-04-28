# Get a WRI raster layer

Retrieves a hosted WRI raster asset and optionally crops it to a spatial
area of interest. The area of interest can be supplied in several
formats: a numeric bounding box, a file path to a shapefile or GeoJSON,
an `sf` object, or a `terra` spatial object (`SpatVector`, `SpatRaster`,
or `SpatExtent`).

## Usage

``` r
get_layer(id, aoi = NULL, aoi_crs = NULL)
```

## Arguments

- id:

  Character. Layer id to retrieve. See
  [`wri_overview_df`](https://ignitr-package.github.io/firex/reference/wri_overview_df.md)
  for available ids.

- aoi:

  Area of interest used to crop the layer. Accepted inputs:

  - `NULL` — returns the full global layer (default).

  - Numeric vector `c(xmin, ymin, xmax, ymax)` — bounding box; `aoi_crs`
    is required.

  - Character path to a shapefile (`.shp`) or GeoJSON file.

  - An `sf` or `sfc` object.

  - A
    [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html),
    [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html),
    or
    [`terra::SpatExtent`](https://rspatial.github.io/terra/reference/SpatExtent-class.html).

- aoi_crs:

  Character or integer CRS specification (e.g. `"EPSG:4326"` or `4326`).
  Required when `aoi` is a numeric bounding box or a CRS-less spatial
  object; must be omitted when `aoi` already carries a CRS.

## Value

A
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
cropped to `aoi`, or the full layer when `aoi = NULL`.

## See also

[`resolve_to_bbox`](https://ignitr-package.github.io/firex/reference/resolve_to_bbox.md),
[`normalize_crs`](https://ignitr-package.github.io/firex/reference/normalize_crs.md),
[`wri_overview_df`](https://ignitr-package.github.io/firex/reference/wri_overview_df.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Full layer
wri <- get_layer("WRI_score")

# Numeric bbox (WGS 84)
wri_norcal <- get_layer("WRI_score",
                        aoi     = c(-122, 37, -121, 38),
                        aoi_crs = "EPSG:4326")

# Shapefile path
shp <- system.file("demos/data/Eaton_Perimeter_20250121.shp",
                   package = "firex")
wri_eaton <- get_layer("WRI_score", aoi = shp)
} # }
```
