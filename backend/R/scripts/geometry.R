
library(tidyverse)
library(sf)

# geometry ---------------------------------------------------------------------
shp_pyr <- st_read("../../data/counties/pyrenees_extent.shp") %>% 
  st_transform(4326) %>% 
  select(geometry) %>% 
  mutate(region = "Pyrenees")
shp_cat <- st_read("../../data/counties/catalunya_extent.shp") %>% 
  st_transform(4326) %>% 
  select(geometry) %>% 
  mutate(region = "Catalunya")

geometry <- bind_rows(shp_cat, shp_pyr)

st_write(geometry, "../../data/socio-economical/geometry.geojson")
