# =============================================================================
# Public: Data frame access
# =============================================================================

#' Get WRI catalog as a data frame
#'
#' Returns a flattened data frame of all STAC items and their metadata.
#'
#' @param fresh Logical. If TRUE (default), rebuilds the catalog from disk.
#'
#' @return A data frame with one row per asset (COG/layer).
#' @export
wri_overview_df <- function(fresh = TRUE) {

  x <- wri_overview(fresh = fresh)
  x$wri_df
}
