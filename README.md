# firex R Package

This package provides utilities for querying a local STAC catalog and retrieving asset information, designed for wildfire resilience data workflows.

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
```r
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
items <- wri_overview()$data$items
water_status <- query_stac_flexible(items, wri_domain = "water", data_type = "status")
```

See [r-pkgs.org](https://r-pkgs.org/whole-game.html) for best practices.


## RAW DATA FILE STRUCTURE [DELETE IN FINAL VERSION]

```
├── air_quality
│   ├── air_quality_domain_score.tif
│   ├── air_quality_resilience.tif
│   ├── air_quality_resistance.tif
│   ├── air_quality_status.tif
│   ├── final_checks
│   │   ├── air_classification_merged.tif
│   │   ├── air_classified_alaska.tif
│   │   ├── air_classified_arizona.tif
│   │   ├── air_classified_british_columbia.tif
│   │   ├── air_classified_california.tif
│   │   ├── air_classified_colorado.tif
│   │   ├── air_classified_idaho.tif
│   │   ├── air_classified_montana.tif
│   │   ├── air_classified_nevada.tif
│   │   ├── air_classified_new_mexico.tif
│   │   ├── air_classified_oregon.tif
│   │   ├── air_classified_utah.tif
│   │   ├── air_classified_washington.tif
│   │   ├── air_classified_wyoming.tif
│   │   └── air_classified_yukon.tif
│   ├── indicators
│   │   ├── air_quality_resistance_asthma.tif
│   │   ├── air_quality_resistance_copd.tif
│   │   ├── air_quality_resistance_hospital_density.tif
│   │   ├── air_quality_resistance_vulnerable_populations.tif
│   │   ├── air_quality_resistance_vulnerable_workers.tif
│   │   ├── air_quality_status_aqi_100.tif
│   │   └── air_quality_status_aqi_300.tif
│   └── indicators_no_mask
│       ├── air_quality_resistance_asthma.tif
│       ├── air_quality_resistance_copd.tif
│       ├── air_quality_resistance_hospital_density.tif
│       ├── air_quality_resistance_vulnerable_populations.tif
│       ├── air_quality_resistance_vulnerable_workers.tif
│       ├── air_quality_status_aqi_100.tif
│       ├── air_quality_status_aqi_300.tif
│       └── archive
│           ├── air_quality_resistance_asthma.tif
│           ├── air_quality_resistance_copd.tif
│           ├── air_quality_resistance_vulnerable_populations.tif
│           └── air_quality_resistance_vulnerable_workers.tif
├── communities
│   ├── archive
│   │   ├── archive
│   │   │   ├── communities_recovery_greater_than_200k.tif
│   │   │   ├── communities_recovery_poverty.tif
│   │   │   └── communities_resistance_vol_fire_stations_test.tif
│   │   ├── communities_domain_score_unmasked.tif
│   │   ├── communities_recovery_unmasked.tif
│   │   ├── communities_resilience_unmasked.tif
│   │   ├── communities_resistance_unmasked.tif
│   │   ├── communities_status_unmasked.tif
│   │   └── final_layers_no_mask
│   │       ├── communities_domain_score.tif
│   │       ├── communities_recovery.tif
│   │       ├── communities_resilience.tif
│   │       └── communities_resistance.tif
│   ├── communities_domain_score.tif
│   ├── communities_recovery.tif
│   ├── communities_resilience.tif
│   ├── communities_resistance.tif
│   ├── final_checks
│   │   ├── communities_classification_merged.tif
│   │   ├── communities_classified_alaska.tif
│   │   ├── communities_classified_arizona.tif
│   │   ├── communities_classified_british_columbia.tif
│   │   ├── communities_classified_california.tif
│   │   ├── communities_classified_colorado.tif
│   │   ├── communities_classified_idaho.tif
│   │   ├── communities_classified_montana.tif
│   │   ├── communities_classified_nevada.tif
│   │   ├── communities_classified_new_mexico.tif
│   │   ├── communities_classified_oregon.tif
│   │   ├── communities_classified_utah.tif
│   │   ├── communities_classified_washington.tif
│   │   ├── communities_classified_wyoming.tif
│   │   ├── communities_classified_yukon.tif
│   │   ├── communities_dif.tif
│   │   └── communities_gaps_in_domain_score.tif
│   ├── indicators
│   │   ├── communities_recovery_income.tif
│   │   ├── communities_recovery_incorporation.tif
│   │   ├── communities_recovery_owners.tif
│   │   ├── communities_resistance_age_65_plus.tif
│   │   ├── communities_resistance_cwpps.tif
│   │   ├── communities_resistance_disability.tif
│   │   ├── communities_resistance_egress.tif
│   │   ├── communities_resistance_firewise_communities.tif
│   │   ├── communities_resistance_no_vehicle.tif
│   │   └── communities_resistance_volunteer_fire_stations.tif
│   └── indicators_no_mask
│       ├── archive
│       │   ├── communities_recovery_income.tif
│       │   ├── communities_recovery_owners.tif
│       │   ├── communities_resistance_age_65_plus.tif
│       │   ├── communities_resistance_disability.tif
│       │   ├── communities_resistance_firewise_communities.tif
│       │   ├── communities_resistance_no_vehicle.tif
│       │   └── communities_resistance_volunteer_fire_stations.tif
│       ├── communities_recovery_income.tif
│       ├── communities_recovery_incorporation.tif
│       ├── communities_recovery_owners.tif
│       ├── communities_resistance_age_65_plus.tif
│       ├── communities_resistance_cwpps.tif
│       ├── communities_resistance_disability.tif
│       ├── communities_resistance_egress.tif
│       ├── communities_resistance_firewise_communities.tif
│       ├── communities_resistance_no_vehicle.tif
│       └── communities_resistance_volunteer_fire_stations.tif
├── ds.json
├── infrastructure
│   ├── final_checks
│   │   ├── infrastructure_classification_merged.tif
│   │   ├── infrastructure_classified_alaska.tif
│   │   ├── infrastructure_classified_arizona.tif
│   │   ├── infrastructure_classified_british_columbia.tif
│   │   ├── infrastructure_classified_california.tif
│   │   ├── infrastructure_classified_colorado.tif
│   │   ├── infrastructure_classified_idaho.tif
│   │   ├── infrastructure_classified_montana.tif
│   │   ├── infrastructure_classified_nevada.tif
│   │   ├── infrastructure_classified_new_mexico.tif
│   │   ├── infrastructure_classified_oregon.tif
│   │   ├── infrastructure_classified_utah.tif
│   │   ├── infrastructure_classified_washington.tif
│   │   ├── infrastructure_classified_wyoming.tif
│   │   └── infrastructure_classified_yukon.tif
│   ├── indicators
│   │   ├── infrastructure_resistance_building_codes.tif
│   │   ├── infrastructure_resistance_d_space.tif
│   │   ├── infrastructure_resistance_egress.tif
│   │   ├── infrastructure_resistance_fire_resource_density.tif
│   │   ├── infrastructure_resistance_wildland_urban_interface_test.tif
│   │   └── infrastructure_resistance_wildland_urban_interface.tif
│   ├── indicators_no_mask
│   │   ├── infrastructure_resistance_building_codes.tif
│   │   ├── infrastructure_resistance_d_space.tif
│   │   ├── infrastructure_resistance_egress.tif
│   │   ├── infrastructure_resistance_fire_resource_density.tif
│   │   ├── infrastructure_resistance_wildland_urban_interface_test.tif
│   │   └── infrastructure_resistance_wildland_urban_interface.tif
│   ├── infrastructure_domain_score.tif
│   ├── infrastructure_recovery.tif
│   ├── infrastructure_resilience.tif
│   ├── infrastructure_resistance.tif
│   └── infrastructure_status.tif
├── livelihoods
│   ├── archive
│   │   └── final_layers_no_mask
│   │       ├── livelihoods_domain_score.tif
│   │       ├── livelihoods_recovery.tif
│   │       ├── livelihoods_resilience.tif
│   │       ├── livelihoods_resistance.tif
│   │       └── livelihoods_status.tif
│   ├── final_checks
│   │   ├── livelihoods_classification_merged.tif
│   │   ├── livelihoods_classified_alaska.tif
│   │   ├── livelihoods_classified_arizona.tif
│   │   ├── livelihoods_classified_british_columbia.tif
│   │   ├── livelihoods_classified_california.tif
│   │   ├── livelihoods_classified_colorado.tif
│   │   ├── livelihoods_classified_idaho.tif
│   │   ├── livelihoods_classified_montana.tif
│   │   ├── livelihoods_classified_nevada.tif
│   │   ├── livelihoods_classified_new_mexico.tif
│   │   ├── livelihoods_classified_oregon.tif
│   │   ├── livelihoods_classified_utah.tif
│   │   ├── livelihoods_classified_washington.tif
│   │   ├── livelihoods_classified_wyoming.tif
│   │   └── livelihoods_classified_yukon.tif
│   ├── indicators
│   │   ├── livelihoods_recovery_diversity_of_jobs.tif
│   │   ├── livelihoods_resistance_job_vulnerability.tif
│   │   ├── livelihoods_status_housing_burden.tif
│   │   ├── livelihoods_status_median_income.tif
│   │   └── livelihoods_status_unemployment.tif
│   ├── indicators_no_mask
│   │   ├── archive
│   │   │   ├── livelihoods_recovery_diversity_of_jobs.tif
│   │   │   ├── livelihoods_resistance_job_vulnerability.tif
│   │   │   ├── livelihoods_status_housing_burden.tif
│   │   │   ├── livelihoods_status_median_income.tif
│   │   │   └── livelihoods_status_unemployment.tif
│   │   ├── livelihoods_recovery_diversity_of_jobs.tif
│   │   ├── livelihoods_resistance_job_vulnerability.tif
│   │   ├── livelihoods_status_housing_burden.tif
│   │   ├── livelihoods_status_median_income.tif
│   │   └── livelihoods_status_unemployment.tif
│   ├── livelihoods_domain_score.tif
│   ├── livelihoods_recovery.tif
│   ├── livelihoods_resilience.tif
│   ├── livelihoods_resistance.tif
│   ├── livelihoods_status.tif
│   └── retro_2005
│       ├── indicators
│       │   └── livelihoods_status_housing_burden.tif
│       └── indicators_no_mask
│           └── livelihoods_status_housing_burden.tif
├── natural_habitats
│   ├── final_checks
│   │   ├── natural_habitats_classified_alaska.tif
│   │   ├── natural_habitats_classified_arizona.tif
│   │   ├── natural_habitats_classified_british_columbia.tif
│   │   ├── natural_habitats_classified_california.tif
│   │   ├── natural_habitats_classified_colorado.tif
│   │   ├── natural_habitats_classified_idaho.tif
│   │   ├── natural_habitats_classified_merged.tif
│   │   ├── natural_habitats_classified_montana.tif
│   │   ├── natural_habitats_classified_nevada.tif
│   │   ├── natural_habitats_classified_new_mexico.tif
│   │   ├── natural_habitats_classified_oregon.tif
│   │   ├── natural_habitats_classified_utah.tif
│   │   ├── natural_habitats_classified_washington.tif
│   │   ├── natural_habitats_classified_wyoming.tif
│   │   └── natural_habitats_classified_yukon.tif
│   ├── indicators_mask
│   │   ├── natural_habitats_recovery_diversity.tif
│   │   ├── natural_habitats_recovery_ppt.tif
│   │   ├── natural_habitats_recovery_tree_traits.tif
│   │   ├── natural_habitats_resistance_density.tif
│   │   ├── natural_habitats_resistance_NDVI.tif
│   │   ├── natural_habitats_resistance_npp.tif
│   │   ├── natural_habitats_resistance_tree_traits.tif
│   │   ├── natural_habitats_resistance_vpd.tif
│   │   ├── natural_habitats_status_extent_change_2005.tif
│   │   └── natural_habitats_status_percent_protected.tif
│   ├── indicators_no_mask
│   │   ├── natural_habitats_recovery_diversity.tif
│   │   ├── natural_habitats_recovery_ppt.tif
│   │   ├── natural_habitats_recovery_tree_traits.tif
│   │   ├── natural_habitats_resistance_density.tif
│   │   ├── natural_habitats_resistance_NDVI.tif
│   │   ├── natural_habitats_resistance_npp.tif
│   │   ├── natural_habitats_resistance_tree_traits.tif
│   │   ├── natural_habitats_resistance_vpd.tif
│   │   ├── natural_habitats_status_extent_change_2005.tif
│   │   └── natural_habitats_status_percent_protected.tif
│   ├── natural_habitats_domain_score.tif
│   ├── natural_habitats_recovery.tif
│   ├── natural_habitats_resilience.tif
│   ├── natural_habitats_resistance.tif
│   └── natural_habitats_status.tif
├── sense_of_place
│   ├── archive
│   │   └── iconic_species_old
│   │       ├── final_checks
│   │       │   ├── species_classified_alaska.tif
│   │       │   ├── species_classified_arizona.tif
│   │       │   ├── species_classified_british_columbia.tif
│   │       │   ├── species_classified_california.tif
│   │       │   ├── species_classified_colorado.tif
│   │       │   ├── species_classified_idaho.tif
│   │       │   ├── species_classified_merged.tif
│   │       │   ├── species_classified_montana.tif
│   │       │   ├── species_classified_nevada.tif
│   │       │   ├── species_classified_new_mexico.tif
│   │       │   ├── species_classified_oregon.tif
│   │       │   ├── species_classified_utah.tif
│   │       │   ├── species_classified_washington.tif
│   │       │   ├── species_classified_wyoming.tif
│   │       │   └── species_classified_yukon.tif
│   │       ├── sense_of_place_iconic_species_domain_score.tif
│   │       ├── sense_of_place_iconic_species_recovery.tif
│   │       ├── sense_of_place_iconic_species_resilience.tif
│   │       ├── sense_of_place_iconic_species_resistance.tif
│   │       └── sense_of_place_iconic_species_status.tif
│   ├── iconic_places
│   │   ├── final_checks
│   │   │   ├── places_classification_merged.tif
│   │   │   ├── places_classified_alaska.tif
│   │   │   ├── places_classified_arizona.tif
│   │   │   ├── places_classified_british_columbia.tif
│   │   │   ├── places_classified_california.tif
│   │   │   ├── places_classified_colorado.tif
│   │   │   ├── places_classified_idaho.tif
│   │   │   ├── places_classified_montana.tif
│   │   │   ├── places_classified_nevada.tif
│   │   │   ├── places_classified_new_mexico.tif
│   │   │   ├── places_classified_oregon.tif
│   │   │   ├── places_classified_utah.tif
│   │   │   ├── places_classified_washington.tif
│   │   │   ├── places_classified_wyoming.tif
│   │   │   └── places_classified_yukon.tif
│   │   ├── indicators
│   │   │   ├── sense_of_place_iconic_places_recovery_degree_of_protection.tif
│   │   │   ├── sense_of_place_iconic_places_recovery_national_parks.tif
│   │   │   ├── sense_of_place_iconic_places_resistance_egress.tif
│   │   │   ├── sense_of_place_iconic_places_resistance_fire_resource_density.tif
│   │   │   ├── sense_of_place_iconic_places_resistance_national_parks.tif
│   │   │   ├── sense_of_place_iconic_places_resistance_structures.tif
│   │   │   ├── sense_of_place_iconic_places_resistance_wui.tif
│   │   │   └── sense_of_place_iconic_places_status_presence.tif
│   │   ├── sense_of_place_iconic_places_domain_score.tif
│   │   ├── sense_of_place_iconic_places_recovery.tif
│   │   ├── sense_of_place_iconic_places_resilience.tif
│   │   └── sense_of_place_iconic_places_resistance.tif
│   └── iconic_species
│       ├── final_checks
│       │   ├── species_classification_merged.tif
│       │   ├── species_classified_alaska.tif
│       │   ├── species_classified_arizona.tif
│       │   ├── species_classified_british_columbia.tif
│       │   ├── species_classified_california.tif
│       │   ├── species_classified_colorado.tif
│       │   ├── species_classified_idaho.tif
│       │   ├── species_classified_montana.tif
│       │   ├── species_classified_nevada.tif
│       │   ├── species_classified_new_mexico.tif
│       │   ├── species_classified_oregon.tif
│       │   ├── species_classified_utah.tif
│       │   ├── species_classified_washington.tif
│       │   ├── species_classified_wyoming.tif
│       │   └── species_classified_yukon.tif
│       ├── indicators
│       │   ├── sense_of_place_iconic_species_area_recovery.tif
│       │   ├── sense_of_place_iconic_species_status_75_extinction_rescaled.tif
│       │   ├── sense_of_place_iconic_species_traits_recovery.tif
│       │   └── sense_of_place_iconic_species_traits_resistance.tif
│       ├── sense_of_place_iconic_species_domain_score.tif
│       ├── sense_of_place_iconic_species_recovery.tif
│       ├── sense_of_place_iconic_species_resilience.tif
│       ├── sense_of_place_iconic_species_resistance.tif
│       └── sense_of_place_iconic_species_status.tif
├── species
│   ├── final_checks
│   │   ├── species_classification_merged.tif
│   │   ├── species_classified_alaska.tif
│   │   ├── species_classified_arizona.tif
│   │   ├── species_classified_british_columbia.tif
│   │   ├── species_classified_california.tif
│   │   ├── species_classified_colorado.tif
│   │   ├── species_classified_idaho.tif
│   │   ├── species_classified_montana.tif
│   │   ├── species_classified_nevada.tif
│   │   ├── species_classified_new_mexico.tif
│   │   ├── species_classified_oregon.tif
│   │   ├── species_classified_utah.tif
│   │   ├── species_classified_washington.tif
│   │   ├── species_classified_wyoming.tif
│   │   ├── species_classified_yukon.tif
│   │   ├── species_dif.tif
│   │   └── species_gaps_in_domain_score.tif
│   ├── indicators
│   │   ├── species_recovery_range_area.tif
│   │   ├── species_recovery_traits.tif
│   │   └── species_resistance_traits.tif
│   ├── species_domain_score.tif
│   ├── species_recovery.tif
│   ├── species_resilience.tif
│   ├── species_resistance.tif
│   └── species_status.tif
├── water
│   ├── final_checks
│   │   ├── water_classification_merged.tif
│   │   ├── water_classified_alaska.tif
│   │   ├── water_classified_arizona.tif
│   │   ├── water_classified_british_columbia.tif
│   │   ├── water_classified_california.tif
│   │   ├── water_classified_colorado.tif
│   │   ├── water_classified_idaho.tif
│   │   ├── water_classified_montana.tif
│   │   ├── water_classified_nevada.tif
│   │   ├── water_classified_new_mexico.tif
│   │   ├── water_classified_oregon.tif
│   │   ├── water_classified_utah.tif
│   │   ├── water_classified_washington.tif
│   │   ├── water_classified_wyoming.tif
│   │   ├── water_classified_yukon.tif
│   │   └── water_gaps_in_domain_score.tif
│   ├── indicators
│   │   ├── archive
│   │   │   ├── drought_plan_scores.tif
│   │   │   ├── streamflow_status_scores_2024_old.tif
│   │   │   ├── streamflow_status_scores_2024.tif
│   │   │   ├── water_resistance_water_treatment_masked.tif
│   │   │   ├── water_resistance_water_treatment.tif
│   │   │   ├── water_status_surface_water_gf_test.tif
│   │   │   ├── water_status_surface_water_gf.tif
│   │   │   ├── water_status_surface_water_quantity.tif
│   │   │   ├── water_status_surface_water.tif
│   │   │   ├── water_status_surface_water_timing.tif
│   │   │   └── water_treatment_scores_2024.tif
│   │   ├── water_resistance_drought_plans.tif
│   │   ├── water_resistance_water_treatment.tif
│   │   ├── water_status_surface_water_quantity.tif
│   │   └── water_status_surface_water_timing.tif
│   ├── water_domain_score.tif
│   ├── water_resilience.tif
│   ├── water_resistance.tif
│   ├── water_status-old.tif
│   └── water_status.tif
└── WRI_score.tif
```
