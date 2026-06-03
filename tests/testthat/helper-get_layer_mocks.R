# Minimal stand-in for a row returned by layer_info().
# Tests can vary one field at a time while preserving the shape get_layer()
# expects from the real STAC metadata table.
fake_layer_row <- function(id = "fake_layer",
                           asset_type = "image/tiff; application=geotiff",
                           is_hosted = "TRUE",
                           bbox = c(-180, -90, 180, 90),
                           href = "https://example.com/fake.tif") {
  data.frame(
    id = id,
    collection = "test",
    asset_name = "data",
    asset_href = href,
    asset_type = asset_type,
    datetime = NA_character_,
    proj_code = "EPSG:5070",
    data_type = "test",
    wri_domain = "test",
    wri_dimension = "test",
    is_hosted = is_hosted,
    xmin = bbox[1],
    ymin = bbox[2],
    xmax = bbox[3],
    ymax = bbox[4],
    stringsAsFactors = FALSE
  )
}
