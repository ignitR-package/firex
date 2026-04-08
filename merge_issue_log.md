## Merge Issue Log

1. `devtools::document()` -> missing exported functions
Old docs/tests still referenced removed API. Regenerated docs, cleaned references.

2. `get_layer.R` -> "`@examples` requires a value"
Empty roxygen examples block. Added small `\dontrun{}` example.

3. `query_stac_flexible()` example -> `load_stac_items()` missing
Old example from older code. Replaced with inline STAC-like example.

4. Tests -> `list_domains()`, `list_layers()`, `search_layers()` missing
Stale tests from deprecated functions. Removed/replaced with current API tests.

5. `get_layer()` test -> expected old message `"Layer 'id' is required"`
Validation message changed. Updated tests to current wording.

6. `wri_overview()` -> "STAC catalog not found"
Path helper still pointed at `wri-data-processing/stac`. Switched to `inst/extdata/stac` in dev and `extdata/stac` when installed.

7. `wri_overview()` -> "No items discovered for collection 'wri_ignitR'"
Collection STAC out of date. Updated `collection.json` to include `rel = "item"` links.

8. `wri_items_df()` -> extent columns wrong/missing
`xmin/ymin/xmax/ymax` not actually being read from item bbox. Fixed extraction from `item_obj$bbox`.

9. `get_layer()` + bbox helpers -> not fully connected
Normalized bbox not always reused. Added `is_valid_bbox()` output reuse + `check_extent_overlap()` call.

10. `check_extent_overlap()` -> incomplete
Finished as bbox-vs-layer-bbox helper. Structured `TRUE/FALSE` + `status/message`.

11. bbox validation messages -> unclear
Added labeled user input: `xmin`, `ymin`, `xmax`, `ymax`.

12. bbox length/type error -> not explicit enough
Changed to "must contain four numeric values: `c(xmin, ymin, xmax, ymax)`".

13. bbox wording -> mixed `xmin/xmax` and lon/lat
Standardized on `xmin`, `ymin`, `xmax`, `ymax`.

## Function Status Since Merge

Public-facing

- `get_layer()` -> kept, expanded
  Added `crs`; wired to `is_valid_bbox()` + `check_extent_overlap()`; cleaned examples/validation flow.

- `is_valid_bbox()` -> kept, expanded
  Absorbed `validate_bbox()` role; can normalize to EPSG:4326; returns logical + attrs.

- `validate_bbox()` -> removed
  Logic merged into `is_valid_bbox()`.

- `check_extent_overlap()` -> kept, simplified
  Now `bbox` vs `layer_bbox`; no STAC lookup inside.

- `layer_info()` -> kept
  Main benefit from STAC path + item discovery fixes.

- `query_stac_flexible()` -> kept
  Main change: example cleanup.

- `wri_overview()` -> kept
  Working again after STAC path/item-link fixes.

- `wri_overview_df()` -> kept
  Working again through repaired STAC pipeline.

- `print.wri_overview()` -> kept
  No major rewrite; benefits from repaired overview object.

Internal `wri_utils.R`

- `%||%` -> kept
  No major change.

- `.wri_require_rstac()` -> kept
  No major change.

- `.wri_prop1()` -> kept
  No major change.

- `wri_get_pkg_path()` -> kept
  Still dev-mode package-root resolver.

- `wri_resolve_stac_path()` -> changed
  Old path removed; now uses package `inst/extdata/stac` / installed `extdata/stac`.

- `wri_resolve_href()` -> kept
  No major change.

- `wri_links_by_rel()` -> kept
  No major change.

- `wri_item_assets_df()` -> kept
  No major change.

- `wri_read_stac_root()` -> kept
  No major change.

- `wri_read_stac_tree()` -> kept
  Started working once STAC path + collection links were fixed.

- `wri_items_df()` -> changed
  Correct bbox extent extraction from item STAC.

- `.wri_pick_raster_asset()` -> changed
  Hosted raster asset filtering cleaned up.

- `.make_result()` -> added
  Shared helper for logical return + `message/status/bbox` attrs.

Removed / stale names cleaned up

- `list_domains()` -> deleted / not present
  Removed stale tests/docs.

- `list_layers()` -> deleted / not present
  Removed stale tests/docs.

- `list_dimensions()` -> deleted / not present
  Removed stale docs.

- `list_data_types()` -> deleted / not present
  Removed stale docs.

- `search_layers()` -> deleted / not present
  Removed stale tests/docs.

- `catalog_summary()` -> deleted / not present
  Removed stale docs.

- `load_stac_items()` -> deleted / not present
  Removed stale example dependency.
