# Integration Milestones and Issues

This file tracks the major integration milestones in `firex` and the package-level
issues we hit while making each phase work. Updated through 2026-04-29.

## Tier I: Merge Issues

This section is the old `merge_issue_log.md`, relabeled to reflect the first
integration pass after the merge.

1. `devtools::document()` -> missing exported functions
Old docs/tests still referenced removed API. Regenerated docs and cleaned references.

2. `get_layer.R` -> "`@examples` requires a value"
Empty roxygen examples block. Added a small `\dontrun{}` example.

3. `query_stac_flexible()` example -> `load_stac_items()` missing
Old example from older code. Replaced with an inline STAC-like example.

4. Tests -> `list_domains()`, `list_layers()`, `search_layers()` missing
Stale tests from deprecated functions. Removed or replaced them with current API tests.

5. `get_layer()` test -> expected old message `"Layer 'id' is required"`
Validation message changed. Updated tests to current wording.

6. `wri_overview()` -> "STAC catalog not found"
Path helper still pointed at `wri-data-processing/stac`. Switched to `inst/extdata/stac`
in dev and `extdata/stac` when installed.

7. `wri_overview()` -> "No items discovered for collection 'wri_ignitR'"
Collection STAC was out of date. Updated `collection.json` to include `rel = "item"` links.

8. `wri_items_df()` -> extent columns wrong or missing
`xmin/ymin/xmax/ymax` were not actually being read from the item bbox. Fixed extraction
from `item_obj$bbox`.

9. `get_layer()` + bbox helpers -> not fully connected
Normalized bbox was not always reused. Added `is_valid_bbox()` output reuse and
`check_extent_overlap()`.

10. `check_extent_overlap()` -> incomplete
Finished as a bbox-vs-layer-bbox helper with structured `TRUE/FALSE` and
`status/message` output.

11. bbox validation messages -> unclear
Added labeled user input: `xmin`, `ymin`, `xmax`, `ymax`.

12. bbox length/type error -> not explicit enough
Changed to "must contain four numeric values: `c(xmin, ymin, xmax, ymax)`".

13. bbox wording -> mixed `xmin/xmax` and lon/lat
Standardized on `xmin`, `ymin`, `xmax`, `ymax`.

## Tier I Outcomes

- `get_layer()` stayed public and gained bbox validation, overlap checks, and cleaner examples.
- `is_valid_bbox()` absorbed the old `validate_bbox()` role and now returns structured attrs.
- `check_extent_overlap()` was simplified to pure bbox-vs-layer logic.
- `wri_overview()`, `wri_overview_df()`, and `layer_info()` recovered once the STAC path
  and item-link issues were fixed.
- Stale function names and tests tied to deleted APIs were removed.

## Tier II: Functionality Integration

1. `rstac` was moved into required imports to support query functions.

2. SpatExtent is a bbox struct, not a geometry feature so terra::vect() and crs assignment don't work on it directly. Added as.polygons() to handle SpatExtent inputs, which converts it to a spatial object before vectorizing.

3. Message text was expanded to include more detail about reprojected bbox coordinates so CRS mismatch failures are easier to interpret.

4. For conflicted CRS, sent user error message if `aoi` had a crs and `aoi_crs` was provided, and did not check that the two were different. Implemented a check to compare the two crs and only error if there is a true conflict.
