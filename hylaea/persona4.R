# =============================================================================
# community_wri.R - Easy wildfire risk data for community planning groups
#
# These functions are designed for Firewise, CWPP, and FireSmart groups
# who need wildfire risk maps for their planning documents — no GIS
# experience required!
#
# Quick start:
#   1. See what places you can choose: browse_places()
#   2. Get data for your area:         get_wri_for_place("Your County, CA")
#
# =============================================================================


# Internal lookup table of pre-computed California counties and US states.
# Each entry contains a human-readable name and a bounding box in EPSG:4326.
# County boxes are approximate; for exact boundaries use a shapefile.

.wri_places <- list(

  # --- California Counties ---
  "Alameda County, CA"       = c(-122.33, 37.45, -121.47, 37.91),
  "Alpine County, CA"        = c(-120.07, 38.51, -119.35, 38.96),
  "Amador County, CA"        = c(-120.85, 38.17, -120.31, 38.60),
  "Butte County, CA"         = c(-122.06, 39.52, -121.01, 40.15),
  "Calaveras County, CA"     = c(-120.85, 37.89, -120.05, 38.45),
  "Colusa County, CA"        = c(-122.76, 38.99, -121.87, 39.80),
  "Contra Costa County, CA"  = c(-122.44, 37.71, -121.55, 38.07),
  "Del Norte County, CA"     = c(-124.21, 41.46, -123.52, 41.98),
  "El Dorado County, CA"     = c(-120.87, 38.52, -119.91, 39.07),
  "Fresno County, CA"        = c(-120.87, 36.14, -118.37, 37.58),
  "Glenn County, CA"         = c(-122.80, 39.52, -121.97, 40.00),
  "Humboldt County, CA"      = c(-124.41, 40.00, -123.41, 41.47),
  "Imperial County, CA"      = c(-115.47, 32.52, -114.13, 33.43),
  "Inyo County, CA"          = c(-118.38, 35.79, -117.02, 37.96),
  "Kern County, CA"          = c(-119.57, 34.79, -117.63, 35.80),
  "Kings County, CA"         = c(-120.35, 35.79, -119.45, 36.60),
  "Lake County, CA"          = c(-123.06, 38.69, -122.20, 39.37),
  "Lassen County, CA"        = c(-121.37, 40.17, -120.00, 41.18),
  "Los Angeles County, CA"   = c(-118.94, 33.70, -117.65, 34.82),
  "Madera County, CA"        = c(-120.06, 36.74, -119.02, 37.58),
  "Marin County, CA"         = c(-122.94, 37.85, -122.33, 38.23),
  "Mariposa County, CA"      = c(-120.25, 37.25, -119.18, 38.07),
  "Mendocino County, CA"     = c(-124.00, 38.77, -122.75, 39.80),
  "Merced County, CA"        = c(-120.83, 36.74, -120.06, 37.63),
  "Modoc County, CA"         = c(-121.52, 41.18, -120.00, 42.00),
  "Mono County, CA"          = c(-119.70, 37.46, -117.83, 38.52),
  "Monterey County, CA"      = c(-121.97, 35.79, -120.22, 36.92),
  "Napa County, CA"          = c(-122.66, 38.17, -122.06, 38.86),
  "Nevada County, CA"        = c(-121.34, 39.01, -120.51, 39.46),
  "Orange County, CA"        = c(-118.11, 33.38, -117.41, 33.95),
  "Placer County, CA"        = c(-121.48, 38.72, -120.00, 39.32),
  "Plumas County, CA"        = c(-121.37, 39.46, -120.10, 40.47),
  "Riverside County, CA"     = c(-117.67, 33.43, -114.43, 34.08),
  "Sacramento County, CA"    = c(-121.86, 38.02, -121.02, 38.73),
  "San Benito County, CA"    = c(-121.58, 36.55, -120.87, 37.00),
  "San Bernardino County, CA"= c(-117.65, 34.00, -114.12, 35.81),
  "San Diego County, CA"     = c(-117.60, 32.53, -116.08, 33.51),
  "San Francisco County, CA" = c(-122.52, 37.70, -122.35, 37.84),
  "San Joaquin County, CA"   = c(-121.59, 37.48, -120.82, 38.08),
  "San Luis Obispo County, CA"=c(-121.34, 34.88, -119.47, 35.80),
  "San Mateo County, CA"     = c(-122.52, 37.10, -122.10, 37.71),
  "Santa Barbara County, CA" = c(-120.17, 34.12, -118.94, 35.17),
  "Santa Clara County, CA"   = c(-122.20, 37.13, -121.21, 37.48),
  "Santa Cruz County, CA"    = c(-122.33, 36.85, -121.58, 37.29),
  "Shasta County, CA"        = c(-122.94, 40.17, -121.37, 40.78),
  "Sierra County, CA"        = c(-120.51, 39.46, -120.00, 39.79),
  "Siskiyou County, CA"      = c(-122.90, 40.78, -121.37, 42.00),
  "Solano County, CA"        = c(-122.40, 38.07, -121.59, 38.55),
  "Sonoma County, CA"        = c(-123.53, 38.12, -122.35, 38.85),
  "Stanislaus County, CA"    = c(-121.02, 37.22, -120.06, 37.89),
  "Sutter County, CA"        = c(-121.94, 38.73, -121.37, 39.18),
  "Tehama County, CA"        = c(-122.94, 39.80, -121.37, 40.17),
  "Trinity County, CA"       = c(-123.51, 40.07, -122.46, 41.18),
  "Tulare County, CA"        = c(-119.57, 35.79, -118.37, 36.74),
  "Tuolumne County, CA"      = c(-120.25, 37.70, -119.18, 38.52),
  "Ventura County, CA"       = c(-119.47, 33.95, -118.64, 34.50),
  "Yolo County, CA"          = c(-122.40, 38.30, -121.59, 38.87),
  "Yuba County, CA"          = c(-121.59, 39.01, -121.02, 39.46),

  # --- US States ---
  "Alabama"     = c(-88.47, 30.22, -84.89, 35.01),
  "Arizona"     = c(-114.82, 31.33, -109.04, 37.00),
  "Arkansas"    = c(-94.62, 33.00, -89.64, 36.50),
  "California"  = c(-124.41, 32.53, -114.13, 42.01),
  "Colorado"    = c(-109.06, 36.99, -102.04, 41.00),
  "Connecticut" = c(-73.73, 40.98, -71.79, 42.05),
  "Delaware"    = c(-75.79, 38.45, -75.05, 39.84),
  "Florida"     = c(-87.63, 24.52, -79.97, 31.00),
  "Georgia"     = c(-85.61, 30.36, -80.84, 35.00),
  "Idaho"       = c(-117.24, 41.99, -111.04, 49.00),
  "Illinois"    = c(-91.51, 36.97, -87.02, 42.51),
  "Indiana"     = c(-88.10, 37.77, -84.78, 41.76),
  "Iowa"        = c(-96.64, 40.37, -90.14, 43.50),
  "Kansas"      = c(-102.05, 36.99, -94.59, 40.00),
  "Kentucky"    = c(-89.57, 36.49, -81.97, 39.15),
  "Louisiana"   = c(-94.04, 28.93, -88.82, 33.02),
  "Maine"       = c(-71.08, 43.06, -66.95, 47.46),
  "Maryland"    = c(-79.49, 37.91, -74.99, 39.72),
  "Massachusetts"=c(-73.51, 41.24, -69.93, 42.89),
  "Michigan"    = c(-90.42, 41.70, -82.42, 48.19),
  "Minnesota"   = c(-97.24, 43.50, -89.49, 49.38),
  "Mississippi" = c(-91.65, 30.17, -88.10, 35.01),
  "Missouri"    = c(-95.77, 35.99, -89.10, 40.61),
  "Montana"     = c(-116.05, 44.36, -104.04, 49.00),
  "Nebraska"    = c(-104.05, 40.00, -95.31, 43.00),
  "Nevada"      = c(-120.00, 35.00, -114.03, 42.00),
  "New Hampshire"=c(-72.56, 42.70, -70.70, 45.31),
  "New Jersey"  = c(-75.56, 38.93, -73.90, 41.36),
  "New Mexico"  = c(-109.05, 31.33, -103.00, 37.00),
  "New York"    = c(-79.76, 40.50, -71.86, 45.02),
  "North Carolina"=c(-84.32, 33.84, -75.46, 36.59),
  "North Dakota"= c(-104.05, 45.94, -96.55, 49.00),
  "Ohio"        = c(-84.82, 38.40, -80.52, 42.33),
  "Oklahoma"    = c(-103.00, 33.62, -94.43, 37.00),
  "Oregon"      = c(-124.57, 41.99, -116.46, 46.26),
  "Pennsylvania"= c(-80.52, 39.72, -74.69, 42.27),
  "Rhode Island"= c(-71.91, 41.15, -71.12, 42.02),
  "South Carolina"=c(-83.35, 32.05, -78.54, 35.22),
  "South Dakota"= c(-104.06, 42.48, -96.44, 45.94),
  "Tennessee"   = c(-90.31, 34.98, -81.65, 36.68),
  "Texas"       = c(-106.65, 25.84, -93.51, 36.50),
  "Utah"        = c(-114.05, 37.00, -109.04, 42.00),
  "Vermont"     = c(-73.44, 42.73, -71.46, 45.02),
  "Virginia"    = c(-83.68, 36.54, -75.24, 39.47),
  "Washington"  = c(-124.73, 45.54, -116.92, 49.00),
  "West Virginia"=c(-82.64, 37.20, -77.72, 40.64),
  "Wisconsin"   = c(-92.89, 42.49, -86.25, 47.31),
  "Wyoming"     = c(-111.06, 40.99, -104.05, 45.01)
)


#' Browse available places for WRI data retrieval
#'
#' Prints a friendly list of all pre-loaded California counties and US states
#' you can use with \code{get_wri_for_place()}. Copy a name exactly as shown.
#'
#' @param filter Optional character string to search by name (case-insensitive).
#'   Leave blank to see everything.
#'
#' @return Invisibly returns a character vector of matching place names.
#'   The main purpose is the printed output.
#'
#' @examples
#' # See everything
#' browse_places()
#'
#' # Search for a specific area
#' browse_places("Butte")
#' browse_places("CA")
#'
#' @export
browse_places <- function(filter = NULL) {

  all_names <- names(.wri_places)

  if (!is.null(filter)) {
    all_names <- all_names[grepl(filter, all_names, ignore.case = TRUE)]
  }

  ca_counties <- all_names[grepl(", CA$", all_names)]
  states      <- all_names[!grepl(", CA$", all_names)]

  cat("================================================\n")
  cat("  WRI Data — Available Places\n")
  cat("  Use the exact name below with get_wri_for_place()\n")
  cat("================================================\n\n")

  if (length(ca_counties) > 0) {
    cat("--- California Counties (", length(ca_counties), ") ---\n", sep = "")
    cat(paste(" ", ca_counties, collapse = "\n"), "\n\n")
  }

  if (length(states) > 0) {
    cat("--- US States (", length(states), ") ---\n", sep = "")
    cat(paste(" ", states, collapse = "\n"), "\n\n")
  }

  if (length(ca_counties) == 0 && length(states) == 0) {
    cat("No places matched your search: '", filter, "'\n", sep = "")
    cat("Try browse_places() with no filter to see everything.\n")
  }

  invisible(all_names)
}


# Available WRI layers on KNB
.wri_layers <- c(
  "WRI_score",
  "air_quality_domain_score",
  "air_quality_resilience",
  "air_quality_resistance",
  "communities_domain_score",
  "communities_resilience",
  "communities_resistance",
  "communities_resistance_cwpps",
  "communities_resistance_egress",
  "communities_resistance_firewise_communities",
  "infrastructure_domain_score",
  "infrastructure_resilience",
  "infrastructure_resistance",
  "livelihoods_domain_score",
  "livelihoods_resilience",
  "livelihoods_resistance",
  "livelihoods_status",
  "natural_habitats_domain_score",
  "water_domain_score",
  "water_resilience",
  "water_resistance",
  "water_status"
)

.wri_base_url <- "https://knb.ecoinformatics.org/data/wri-data-processing/cogs/"


#' List available WRI data layers
#'
#' Prints all available layers you can download with \code{get_wri_for_place()}.
#'
#' @examples
#' list_layers()
#'
#' @export
list_layers <- function() {
  cat("================================================\n")
  cat("  Available WRI Layers\n")
  cat("  Use the exact name with get_wri_for_place(layer = ...)\n")
  cat("================================================\n\n")
  cat(paste(" ", .wri_layers, collapse = "\n"), "\n\n")
  cat("Default layer: WRI_score (overall wildfire resilience)\n")
  invisible(.wri_layers)
}


#' Get Wildfire Resilience Index data for your community's area
#'
#' This is the main function for community groups. Just tell it where you are
#' and it will download the WRI data for that region. No GIS experience needed!
#'
#' @param place Character. The name of a California county or US state, exactly
#'   as shown by \code{browse_places()}. Examples: "Butte County, CA" or "Oregon".
#'
#' @param layer Character. Which WRI data layer to download. Default is
#'   "WRI_score" (the overall wildfire resilience score). Use \code{list_layers()}
#'   to see all available options.
#'
#' @return A terra::SpatRaster with WRI data for your area, ready to map or
#'   analyze.
#'
#' @examples
#' \dontrun{
#' # Step 1: Find your area
#' browse_places()
#' browse_places("Plumas")
#'
#' # Step 2: Download the data
#' my_data <- get_wri_for_place("Plumas County, CA")
#'
#' # Step 3: Make a quick map
#' terra::plot(my_data, main = "Wildfire Resilience Index — Plumas County")
#'
#' # Use a different layer
#' list_layers()
#' water <- get_wri_for_place("Plumas County, CA", layer = "water_domain_score")
#' }
#'
#' @export
get_wri_for_place <- function(place, layer = "WRI_score") {

  # --- Validate place ---
  if (!place %in% names(.wri_places)) {
    close <- names(.wri_places)[grepl(place, names(.wri_places), ignore.case = TRUE)]
    if (length(close) > 0) {
      stop(
        "Place not found: '", place, "'\n\n",
        "Did you mean one of these?\n",
        paste("  -", close, collapse = "\n"), "\n\n",
        "Use browse_places() to see all options. Copy the name exactly as shown."
      )
    } else {
      stop(
        "Place not found: '", place, "'\n\n",
        "Use browse_places() to see all available places.\n",
        "Copy the name exactly, including spaces and capitalization."
      )
    }
  }

  # --- Validate layer ---
  if (!layer %in% .wri_layers) {
    stop(
      "Layer not found: '", layer, "'\n\n",
      "Use list_layers() to see all available layers."
    )
  }

  # --- Build COG URL ---
  cog_url <- paste0(.wri_base_url, layer, ".tif")
  vsicurl_path <- paste0("/vsicurl/", cog_url)

  # --- Get bbox and transform to EPSG:5070 ---
  bbox_4326 <- .wri_places[[place]]

  # Transform bbox corners from WGS84 to EPSG:5070 (native COG CRS)
  corners <- sf::st_as_sf(
    data.frame(
      x = c(bbox_4326[1], bbox_4326[3]),
      y = c(bbox_4326[2], bbox_4326[4])
    ),
    coords = c("x", "y"),
    crs = 4326
  )
  corners_5070 <- sf::st_transform(corners, 5070)
  coords_5070  <- sf::st_coordinates(corners_5070)
  bbox_5070    <- terra::ext(
    min(coords_5070[, "X"]), max(coords_5070[, "X"]),
    min(coords_5070[, "Y"]), max(coords_5070[, "Y"])
  )

  # --- Fetch and crop ---
  message("Downloading WRI data for: ", place, " (layer: ", layer, ")")
  message("This may take 15-60 seconds depending on your internet connection...")

  Sys.setenv(GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR")
  Sys.setenv(CPL_VSIL_CURL_ALLOWED_EXTENSIONS = ".tif")

  r <- terra::rast(vsicurl_path)
  result <- terra::crop(r, bbox_5070, snap = "out")

  message("Done! Your data is ready.")
  message("Quick tip: Use terra::plot(your_data) to make a map.")

  result
}
