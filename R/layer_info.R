# =============================================================================
# Public: Single-layer metadata access
# =============================================================================

#' Get metadata for one WRI layer
#'
#' Returns metadata for a single layer from the WRI STAC catalog.
#'
#' @param layer_id Character. The layer/item id to look up, e.g. `"WRI_score"`.
#' @param fresh Logical. If TRUE (default), rebuilds the catalog from disk.
#'   If FALSE, not implemented yet.
#'
#' @return A one-row data frame containing metadata for the requested layer.
#' @export
layer_info <- function(layer_id, fresh = TRUE) {

  if (missing(layer_id) || !is.character(layer_id) || length(layer_id) != 1 || !nzchar(layer_id)) {
    stop("`layer_id` must be a single non-empty character string.", call. = FALSE)
  }

  if (!isTRUE(fresh)) {
    stop(
      "`fresh = FALSE` is not implemented yet. The catalog is always rebuilt from disk.",
      call. = FALSE
    )
  }

  data <- wri_read_stac_tree()
  wri_df <- wri_items_df(data)

  hits <- wri_df[wri_df$id == layer_id, , drop = FALSE]

  if (nrow(hits) == 0) {
    available_ids <- sort(unique(wri_df$id))
    stop(
      "Layer not found: `", layer_id, "`.\n\n",
      "Example available layer ids:\n  ",
      paste(utils::head(available_ids, 10), collapse = ", "),
      if (length(available_ids) > 10) "\n  ..." else "",
      call. = FALSE
    )
  }

  hits
}

