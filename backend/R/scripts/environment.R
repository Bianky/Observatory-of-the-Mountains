
# package
library(tidyverse)

# counties belonging to Pyrenees region
pyr <- c("Aran", "Alta Ribagorça", "Pallars Jussà", "Pallars Sobirà",
         "Alt Urgell", "Solsonès", "Cerdanya", "Ripollès", "Berguedà")

# counteis belonging to Catalunya
cat <- c("Alt Camp", "Alt Empordà", "Alt Penedès", "Alt Urgell", "Alta Ribagorça",
         "Anoia", "Aran", "Bages", "Baix Camp", "Baix Ebre", "Baix Empordà",
         "Baix Llobregat", "Baix Penedès", "Barcelonès", "Berguedà", "Cerdanya",
         "Conca de Barberà", "Garraf", "Garrigues", "Garrotxa", "Gironès",
         "Maresme", "Moianès", "Montsià", "Noguera", "Osona",
         "Pallars Jussà", "Pallars Sobirà", "Pla d'Urgell", "Pla de l'Estany",
         "Priorat", "Ribera d'Ebre", "Ripollès", "Segarra", "Segrià",
         "Selva", "Solsonès", "Tarragonès", "Terra Alta", "Urgell",
         "Vallès Occidental", "Vallès Oriental", "Lluçanès"
)

# path to environmental data
path <- "../../data/environmental"

# function to read and process data
source("R/process.R")


# CLIMATE ----------------------------------------------------------------------
preci <- process(
  folder = "climate/precipitation",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "station", "altitude_m", "c_preci_mm",
                "c_wspeed_ms", "direction"),
  drop_cols = c("station", "altitude_m", "ave_rel_humidity_pct", "direction"),
  fun = mean
)

temp <- process(
  folder = "climate/temp",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "station", "altitude_m",
                "c_temp_ave", "c_temp_avemax", "c_temp_avemin", "abs_max", "abs_min"),
  drop_cols = c("station", "altitude_m", "abs_max", "abs_min"),
  fun = mean
)

climate <- list(preci, temp) %>% 
  reduce(full_join, by = c("region", "year"))

# WATER ------------------------------------------------------------------------
path <- "../../data/socio-economical"
density <- process(
  folder = "population/density",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "p_population", "area_km2", "density_hkm2"),
  drop_cols = c("density_hkm2"),
  fun = sum
) %>% 
  mutate(p_density_hkm2 = p_population/area_km2)

path <- "../../data/environmental"
water <- process(
  folder = "water/consump",
  skip = 9,
  n_max = Inf,
  col_names = c("county", "w_domestic_consump", "w_industry_consump", 
                "w_total_network", "w_own_sources", "w_total"),
  drop_cols = c(),
  fun = sum
)

water <- list(water, density) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(across(starts_with("w_"), ~ (.x*1000) /p_population)) 

# FOREST -----------------------------------------------------------------------
clearing <- process(
  folder = "forest/clearing",
  skip = 12,
  n_max = Inf,
  col_names = c("county", "f_cleared_ha", "f_cle_var_pct"),
  drop_cols = c("f_cle_var_pct"),
  fun = sum
)

refor <- process(
  folder = "forest/reforestation",
  skip = 12,
  n_max = Inf,
  col_names = c("county", "f_reforested_ha", "f_ref_var_pct"),
  drop_cols = c("f_ref_var_pct"),
  fun = sum
)

forest <- list(clearing, refor) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(f_relative_reforested = f_reforested_ha/f_cleared_ha * 100)

# LANDUSE ----------------------------------------------------------------------
land <- process(
  folder = "land",
  skip = 9,
  n_max = Inf,
  col_names = c("county", "l_forests", "l_bushes", "l_others", "l_novege", "l_crop_dry", "l_crop_irri", "l_urban"),
  drop_cols = c(),
  fun = sum
)

forest <- list(land, forest) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(across(c("f_reforested_ha", "f_cleared_ha"), ~ .x / l_forests * 100)) %>% 
  select(-starts_with("l_"))

land <- list(land, density) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(across(starts_with("l_"), ~ .x /(area_km2*100) * 100)) 

# bring all together
environment <- list(climate, water, forest, land) %>% 
  reduce(full_join, by = c("region", "year"))

write_json(environment, file.path(path, "environment.json"), append = FALSE)



