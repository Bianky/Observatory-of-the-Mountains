
# package
library(tidyverse)
library(jsonlite)

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
path <- "data/environmental"

# function to read and process data
source("R/functions/process.R")


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
path <- "data/socio-economical"
density <- process(
  folder = "population/density",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "p_population", "area_km2", "density_hkm2"),
  drop_cols = c("density_hkm2"),
  fun = sum
) %>% 
  mutate(p_density_hkm2 = p_population/area_km2)

path <- "data/environmental"
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

fire <- process(
  folder = "fires",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "fires", "fires_tree_ha", "fires_scrub_ha", "f_fires_ha"),
  drop_cols = c("fires", "fires_tree_ha", "fires_scrub_ha"),
  fun = sum
)


forest <- list(clearing, refor, fire, density) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(f_relative_reforested = f_reforested_ha/f_cleared_ha * 100,
         f_fire = round(f_fires_ha/(area_km2*100) * 100, 2))

# LANDUSE ----------------------------------------------------------------------
land <- process(
  folder = "land",
  skip = 9,
  n_max = Inf,
  col_names = c("county", "l_forests", "l_bushes", "l_others", "l_novege", "l_crop_dry", "l_crop_irri", "l_urban"),
  drop_cols = c(),
  fun = sum
)


land <- list(land, density) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(l_agri = l_crop_dry + l_crop_irri,
         across(starts_with("l_"), ~ .x /(area_km2*100) * 100))
  
land <- land %>% 
  filter(!(year == 2024)) %>% 
  group_by(region) %>% 
  arrange(year) %>% 
  mutate(l_forest_roc = ((l_forests - lag(l_forests)) / lag(l_forests)) * 100 / (year - lag(year)),
         l_bushes_roc = ((l_bushes - lag(l_bushes)) / lag(l_bushes)) * 100 / (year - lag(year)),
         l_agri_roc = ((l_agri - lag(l_agri)) / lag(l_agri)) * 100 / (year - lag(year)),
         l_novege_roc = ((l_novege - lag(l_novege)) / lag(l_novege)) * 100 / (year - lag(year)),
         l_urban_roc = ((l_urban - lag(l_urban)) / lag(l_urban)) * 100 / (year - lag(year)),
         l_others_roc = ((l_others - lag(l_others)) / lag(l_others)) * 100 / (year - lag(year))) %>% 
  ungroup() %>% 
  rowwise() %>% 
  mutate(lc_sum = sum(abs(c_across(ends_with("_roc"))))) 

#pollution 
mun <- process(
  folder = "waste/municipal",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "glass", "papre", "lightweight", "organic", "pruning", "heavy_waste", "others", "w_mun"),
  drop_cols = c(2:8),
  fun = sum
)

ind <- process(
  folder = "waste/industrial",
  skip = 10,
  n_max = Inf,
  col_names = c("county", "esta", "speacial", "not_special", "w_ind"),
  drop_cols = c(2:4),
  fun = sum
)

waste <- list(mun, ind, density) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(w_mun = w_mun/p_population * 1000,
         w_ind = w_ind/p_population * 1000)


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
  filter(county %in% pyr) %>% 
  summarise(across(where(is.numeric), sum)) %>% 
  mutate(region = "Pyrenees")

org_cat <- organic %>% 
  filter(county %in% cat) %>% 
  summarise(across(where(is.numeric), sum)) %>% 
  mutate(region = "Catalunya")

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
  filter(county %in% pyr) %>% 
  summarise(across(where(is.numeric), sum)) %>% 
  mutate(region = "Pyrenees")

tot_cat <- total %>% 
  filter(county %in% cat) %>% 
  summarise(across(where(is.numeric), sum)) %>% 
  mutate(region = "Catalunya")

tot <- bind_rows(tot_pyr, tot_cat) %>% 
  mutate(year = 2020)

farm <- list (org, tot) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(org_pct = fo_total_organic/ft_total_utilized_agricultural_area * 100)

# bring all together
environment <- list(climate, water, forest, land, farm, waste) %>% 
  reduce(full_join, by = c("region", "year"))

write_json(environment, "Observatory-of-the-Mountains/frontend/data/environment.json", append = FALSE)



