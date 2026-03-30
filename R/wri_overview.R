# =============================================================================
# Public: Catalog access
# =============================================================================

#' Read the WRI STAC catalog
#'
#' Reads the local STAC catalog and returns a `wri_overview` object.
#'
#' @param fresh Logical. If TRUE (default), rebuilds the catalog from disk.
#'   If FALSE, not implemented yet (reserved for caching).
#'
#' @return An object of class `wri_overview`.
#' @export
wri_overview <- function(fresh = TRUE) {

  if (!isTRUE(fresh)) {
    stop(
      "`fresh = FALSE` is not implemented yet. The catalog is always rebuilt from disk.",
      call. = FALSE
    )
  }

  data <- wri_read_stac_tree()

  structure(
    list(
      path = data$catalog_path,
      built_at = Sys.time(),
      data = data
    ),
    class = "wri_overview"
  )
}
