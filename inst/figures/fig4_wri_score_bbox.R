library(firex)
library(terra)

save_figure <- function(output_path = file.path(tempdir(), "fig4_wri_score_bbox.png")) {
  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

  sb_bbox <- c(-120.7, 34.4, -119.4, 35.1)
  wri <- get_layer("WRI_score", aoi = sb_bbox, aoi_crs = "EPSG:4326")

  png(output_path, width = 1000, height = 800, res = 150)
  old_par <- par(no.readonly = TRUE)
  on.exit({
    par(old_par)
    dev.off()
  }, add = TRUE)

  plot(
    wri,
    main = "WRI Score - Santa Barbara County",
    col = hcl.colors(100, "YlOrRd", rev = TRUE),
    zlim = c(0, 1)
  )

  invisible(output_path)
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 1L) {
  stop("Supply at most one output path.", call. = FALSE)
}
output_path <- if (length(args) == 1L) args[[1]] else file.path(tempdir(), "fig4_wri_score_bbox.png")
message("Saved figure to: ", save_figure(output_path))
