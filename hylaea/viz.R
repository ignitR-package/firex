#################################################################
#                    SCRIPT TO MAKE FIGURE 1                    #
#       (Map of WWRI average score & flower plots)              #
#################################################################

# ---- 1. Load Libraries ----
library(here)
library(terra)
library(tidyterra)
library(tidyverse)
library(ggspatial)
library(rnaturalearth)
library(sf)
library(tigris)
library(rlang)
library(RColorBrewer)

options(tigris_use_cache = TRUE)

# ---- 2. Configuration ----
base_dir <- "/home/shares/wwri-wildfire/final_layers/2024"

paths <- list(
  rasters = list(
    sop_places     = file.path(base_dir, "sense_of_place/iconic_places", "sense_of_place_iconic_places_domain_score.tif"),
    sop_species    = file.path(base_dir, "sense_of_place/iconic_species", "sense_of_place_iconic_species_domain_score.tif"),
    air            = file.path(base_dir, "air_quality",  "air_quality_domain_score.tif"),
    water          = file.path(base_dir, "water",        "water_domain_score.tif"),
    biodiversity   = file.path(base_dir, "species", "species_domain_score.tif"),
    habitats       = file.path(base_dir, "natural_habitats", "natural_habitats_domain_score.tif"),
    livelihoods    = file.path(base_dir, "livelihoods",  "livelihoods_domain_score.tif"),
    infrastructure = file.path(base_dir, "infrastructure", "infrastructure_domain_score.tif"),
    communities    = file.path(base_dir, "communities",  "communities_domain_score.tif")
  ),
  output = list(
    avg_score_tif   = "/home/shares/wwri-wildfire/cat/average_score.tif",
    map_png         = "/home/shares/wwri-wildfire/cat/wwri_plot.png",
    summary_csv     = "/home/shares/wwri-wildfire/cat/summary-statistics/whole-region-summary-stats.csv",
    flower_plot_dir = "/home/shares/wwri-wildfire/cat/flower_plots"
  )
)

western_states <- c(
  "California", "Oregon", "Washington", "Nevada", "Idaho",
  "Montana", "Wyoming", "Colorado", "Utah", "Arizona",
  "New Mexico", "Alaska"
)
canada_provinces <- c("British Columbia", "Yukon")

# ---- 2a. Flower plot weights (keep SOP sub-layers separate) ----
goal_weights <- c(
  livelihoods   = 1.0,
  sop_places    = 0.5,
  sop_species   = 0.5,
  biodiversity  = 1.0,
  habitats      = 1.0,
  water         = 1.0,
  air           = 1.0,
  infrastructure = 1.0,
  communities   = 1.0
)

custom_colors <- c(
  infrastructure = "#AA104E",
  communities    = "#E16A5C",
  livelihoods    = "#F8B267",
  sop_places     = "#78C6A2",
  sop_species    = "#78C6A2",
  biodiversity   = "#4AB3B0",
  habitats       = "#15746F",
  water          = "#1F456E",
  air            = "#2B153D"
)

goal_order <- c("livelihoods", "sop_places", "sop_species", "biodiversity",
                "habitats", "water", "air", "infrastructure", "communities")

# ---- 3. Helper Functions ----

# 3.1 Create average raster (merge SOP for map)
create_average_score <- function(raster_paths, out_tif) {
  # Merge SOP layers for the map
  sop <- app(c(rast(raster_paths$sop_places), rast(raster_paths$sop_species)),
             fun = mean, na.rm = TRUE)
  names(sop) <- "sop"

  # Load other layers (excluding SOP)
  other_paths <- raster_paths[!(names(raster_paths) %in% c("sop_places","sop_species"))]
  others <- map(other_paths, rast)

  # Stack rasters and compute mean
  rstack <- rast(c(list(sop), others))

  avg <- app(
    rstack,
    fun = mean,
    na.rm = TRUE,
    filename  = out_tif,
    overwrite = TRUE,
    wopt      = list(datatype = "FLT4S", gdal = c("COMPRESS=DEFLATE"))
  )

  message("Average score raster written to: ", out_tif)
  return(avg)
}

# 3.2 Prepare boundaries
prepare_boundaries <- function(west_states, ca_provs) {
  us_states <- ne_states(country = "United States of America", returnclass = "sf") %>%
    filter(name %in% west_states)
  ca_all    <- ne_states(country = "Canada", returnclass = "sf") %>%
    filter(name %in% ca_provs)
  rbind(us_states, ca_all)
}

# 3.3 Plot raster
plot_raster_with_boundaries <- function(rast_obj, boundaries_sf, quant_limits, out_png) {
  layer_nm <- names(rast_obj)[1]
  fill_var <- sym(layer_nm)
  p <- ggplot() +
    geom_spatraster(data = rast_obj, aes(fill = !!fill_var)) +
    scale_fill_gradientn(
      colors   = rev(brewer.pal(9, "YlOrRd")),
      limits   = quant_limits,
      oob      = scales::squish,
      na.value = "transparent"
    ) +
    geom_sf(data = boundaries_sf, fill = NA, color = "black", size = 0.2) +
    theme_void() +
    theme(
      legend.position      = "bottom",
      plot.margin          = margin(0,0,0,0),
      panel.background     = element_rect(fill = "transparent", colour = NA),
      plot.background      = element_rect(fill = "transparent", colour = NA),
      legend.background    = element_rect(fill = "transparent", colour = NA)
    )
  ggsave(out_png, plot = p, width = 6, height = 8, dpi = 300)
  message("Map saved to: ", out_png)
  return(p)
}

# 3.4 Flower plot
make_flower_plot <- function(stats_df, zone_name, weights, colors, order_vec) {
  df <- stats_df %>%
    filter(zone == zone_name) %>%
    rename(goal = raster, score = value) %>%
    mutate(goal = factor(goal, levels = order_vec)) %>%
    arrange(goal) %>%
    mutate(
      weight = weights[as.character(goal)],
      pos    = cumsum(weight) - (weight / 2)
    )

  center_score <- round(weighted.mean(df$score, df$weight, na.rm = TRUE))

  ggplot(df, aes(x = pos, width = weight)) +
    geom_bar(aes(y = 100), stat = "identity", fill = NA, color = "grey60", size = 0.2) +
    geom_bar(aes(y = score, fill = goal), stat = "identity", color = "white") +
    coord_polar(theta = "x", start = pi/2) +
    scale_fill_manual(values = colors, breaks = order_vec) +
    theme_void() +
    theme(legend.position = "none") +
    geom_bar(aes(y = 1), stat = "identity", fill = NA, color = "grey80", size = 0.5) +
    annotate("point", x = 0, y = 0, size = 25, shape = 21, fill = "white") +
    annotate("text", x = 0, y = 0, label = center_score,
             size = 12, family = "Helvetica", fontface = "bold", color = "grey30")
}

# ---- 4. Main Workflow ----

# 4.1 Average raster for map
avg_raster <- create_average_score(
  raster_paths = paths$rasters,
  out_tif = paths$output$avg_score_tif
)

avg_path <- paths$output$avg_score_tif
Sys.sleep(2)
if (!file.exists(avg_path)) stop(glue::glue("Raster not found at: {avg_path}")) else message(glue::glue("Raster found at: {avg_path}"))

# 4.2 Compute raster quantiles for color scaling
set.seed(42)
samp_vals <- spatSample(avg_raster, size = 1e6, method = "random", as.raster = FALSE)[,1]
quant_limits <- quantile(samp_vals, c(0.001, 0.999), na.rm = TRUE)

# 4.3 Prepare map boundaries & plot
boundaries_sf <- st_transform(
  prepare_boundaries(western_states, canada_provinces),
  crs(avg_raster)
)
map_plot <- plot_raster_with_boundaries(
  avg_raster, boundaries_sf, quant_limits,
  paths$output$map_png
)

# 4.4 Whole-region stats for flower plot (keep SOP sub-layers separate)
score_stack <- rast(unlist(paths$rasters))
names(score_stack) <- names(paths$rasters)

whole_region_stats <- map_dfr(
  names(score_stack),
  ~ tibble(
    zone      = "Entire Study Region",
    raster    = .x,
    value     = global(score_stack[[.x]], fun = "mean", na.rm = TRUE)[1,1],
    zone_type = "whole_region"
  )
) %>% mutate(weight = goal_weights[raster])

write_csv(whole_region_stats, paths$output$summary_csv)
message("Whole-region summary stats saved to: ", paths$output$summary_csv)

# 4.5 Flower plot
zonal_results <- read_csv(paths$output$summary_csv)
zone_name <- zonal_results$zone[1]

flower_plot <- make_flower_plot(
  stats_df  = zonal_results,
  zone_name = zone_name,
  weights   = goal_weights,
  colors    = custom_colors,
  order_vec = goal_order
)

safe_name <- paste0(str_replace_all(zone_name, "[^A-Za-z0-9]", "_"), ".png")
out_file  <- file.path(paths$output$flower_plot_dir, safe_name)

ggsave(
  filename = out_file,
  plot     = flower_plot,
  width    = 3,
  height   = 3,
  dpi      = 900,
  bg       = "transparent"
)

message("Flower plot for ", zone_name, " saved to: ", out_file)
