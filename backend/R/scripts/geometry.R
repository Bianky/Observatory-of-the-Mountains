
library(tidyverse)
library(sf)

# counties belonging to Pyrenees region
pyr <- c("Aran", "Alta Ribagorça", "Pallars Jussà", "Pallars Sobirà",
         "Alt Urgell", "Solsonès", "Cerdanya", "Ripollès", "Berguedà", "Val d'Aran")

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

st_write(geometry, "../../data/counties/geometry.geojson")

shp_counties <- st_read("../../data/counties/divisions-administratives-v2r1-comarques-5000-20250730.shp") %>% 
  st_transform(4326) %>% 
  select(NOMCOMAR, geometry) %>% 
  rename(county = NOMCOMAR) %>% 
  filter(county %in% pyr)

shp_counties$county[shp_counties$county == "Val d'Aran"] <- "Aran"

shp_cat <- shp_cat %>% 
  rename(county = region)

shp_counties <- bind_rows(shp_counties, shp_cat)

st_write(shp_counties, "../../data/counties/shp_counties_cat.geojson")
