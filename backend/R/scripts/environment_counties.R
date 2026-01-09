
# packages ---------------------------------------------------------------------
library(tidyverse)
library(jsonlite)

# counties belonging to Pyrenees region
pyr <- c("Aran", "Alta Ribagorça", "Pallars Jussà", "Pallars Sobirà",
         "Alt Urgell", "Solsonès", "Cerdanya", "Ripollès", "Berguedà")

# counties belonging to Catalunya
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

# path to socio-economical data
path <- "../../data/environmental"

# function to read and process data
source("R/process_map.R")



# CLIMATE ----------------------------------------------------------------------
preci <- process_map(
  folder = "climate/precipitation",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "station", "altitude_m", "c_preci_mm",
                "c_wspeed_ms", "direction"),
  drop_cols = c("station", "altitude_m", "ave_rel_humidity_pct", "direction"),
  fun = mean
)

temp <- process_map(
  folder = "climate/temp",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "station", "altitude_m",
                "c_temp_ave", "c_temp_avemax", "c_temp_avemin", "abs_max", "abs_min"),
  drop_cols = c("station", "altitude_m", "abs_max", "abs_min"),
  fun = mean
)

climate <- list(preci, temp) %>% 
  reduce(full_join, by = c("county", "year"))

# WATER ------------------------------------------------------------------------
path <- "../../data/socio-economical"
density <- process_map(
  folder = "population/density",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "p_population", "area_km2", "density_hkm2"),
  drop_cols = c("density_hkm2"),
  fun = sum
) %>% 
  mutate(p_density_hkm2 = p_population/area_km2)

path <- "../../data/environmental"
water <- process_map(
  folder = "water/consump",
  skip = 9,
  n_max = Inf,
  col_names = c("county", "w_domestic_consump", "w_industry_consump", 
                "w_total_network", "w_own_sources", "w_total"),
  drop_cols = c(),
  fun = sum
)

water <- list(water, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(across(starts_with("w_"), ~ (.x*1000) /p_population)) 

# FOREST -----------------------------------------------------------------------
clearing <- process_map(
  folder = "forest/clearing",
  skip = 12,
  n_max = Inf,
  col_names = c("county", "f_cleared_ha", "f_cle_var_pct"),
  drop_cols = c("f_cle_var_pct"),
  fun = sum
)

refor <- process_map(
  folder = "forest/reforestation",
  skip = 12,
  n_max = Inf,
  col_names = c("county", "f_reforested_ha", "f_ref_var_pct"),
  drop_cols = c("f_ref_var_pct"),
  fun = sum
)

forest <- list(clearing, refor) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(f_relative_reforested = f_reforested_ha/f_cleared_ha * 100)

# LANDUSE ----------------------------------------------------------------------
land <- process_map(
  folder = "land",
  skip = 9,
  n_max = Inf,
  col_names = c("county", "l_forests", "l_bushes", "l_others", "l_novege", "l_crop_dry", "l_crop_irri", "l_urban"),
  drop_cols = c(),
  fun = sum
)

forest <- list(land, forest) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(across(c("f_reforested_ha", "f_cleared_ha"), ~ .x / l_forests * 100)) %>% 
  select(-starts_with("l_"))

land <- list(land, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(across(starts_with("l_"), ~ .x /(area_km2*100) * 100)) 

# FARM -------------------------------------------------------------------------

organic <- read_csv(file.path(path, "farm/organic_2020.csv"), 
                    skip = 7,
                    col_names = c("county", "fo_cereals for grain", "fo_legumes", "fo_roots and tubers", 
                                  "fo_crops harvested green", "fo_industrial crops", 
                                  "fo_vegetables, melongs and strawberries", "fo_seeds and seedlings for sale", 
                                  "fo_other herbaceous crops", "fo_outdoor woody crops", 
                                  "fo_permanent pasture lands", "fo_greenhouse crops", "fo_total_organic")) %>% 
  mutate(across(where(function(x) all(x %in% c(NA, ".", "-") | grepl("^[0-9.-]+$", x))), as.numeric))

org_pyr <- organic %>% 
  filter(county %in% pyr)

org_cat <- organic %>% 
  filter(county %in% non_pyr_cat)   %>% 
  summarise(across(where(is.numeric), sum, na.rm = T)) %>% 
  mutate(county = "Catalunya")

org <- bind_rows(org_pyr, org_cat) %>% 
  mutate(year = 2020)

total <- read_csv(file.path(path, "farm/total_2020.csv"), 
                  skip = 7,
                  col_names = c("county", "ft_greenhouse_crops", "ft_outdoor_herbaceous_crops", "ft_fallows", 
                                "ft_woody_crops", "ft_vegetable_gardens_for_own_consumption", "ft_total_cultivated_land", 
                                "ft_permanent_pastures", "ft_total_utilized_agricultural_area", "ft_forest_area", 
                                "ft_threshing,_floors,_buildings,_quarries,_courtyards,..", 
                                "ft_abandoned_agricultural_area", "ft_total")) %>% 
  mutate(across(where(function(x) all(x %in% c(NA, ".", "-") | grepl("^[0-9.-]+$", x))), as.numeric))

tot_pyr <- total %>% 
  filter(county %in% pyr)

tot_cat <- total %>% 
  filter(county %in% non_pyr_cat) %>% 
  summarise(across(where(is.numeric), sum, na.rm = T)) %>% 
  mutate(county = "Catalunya")


tot <- bind_rows(tot_pyr, tot_cat) %>% 
  mutate(year = 2020)

farm <- list (org, tot) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(org_pct = fo_total_organic/ft_total_utilized_agricultural_area * 100)

#pollution 
mun <- process_map(
  folder = "waste/municipal",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "glass", "papre", "lightweight", "organic", "pruning", "heavy_waste", "others", "w_mun"),
  drop_cols = c(2:8),
  fun = sum
)

ind <- process_map(
  folder = "waste/industrial",
  skip = 10,
  n_max = Inf,
  col_names = c("county", "esta", "speacial", "not_special", "w_ind"),
  drop_cols = c(2:4),
  fun = sum
)

waste <- list(mun, ind, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(w_mun = w_mun/p_population * 1000,
         w_ind = w_ind/p_population * 1000)




# bring all together
environment <- list(climate, water, forest, land, farm, waste) %>% 
  reduce(full_join, by = c("county", "year"))

environment <- environment %>%
  mutate(across(where(is.numeric), ~ round(., 2)))

write_json(environment, "C:/Users/Bianka/Documents/MSc-Internship/Observatory-of-the-Mountains/frontend/data/environment_counties.json", append = FALSE)



