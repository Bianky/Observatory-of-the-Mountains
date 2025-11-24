
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
path <- "../../data/socio-economical"

# function to read and process data
source("R/fucntions/process.R")


# POPULATION -------------------------------------------------------------------
density <- process(
  folder = "population/density",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "p_population", "area_km2", "density_hkm2"),
  drop_cols = c("density_hkm2"),
  fun = sum
) %>% 
  mutate(p_density_hkm2 = p_population/area_km2)

age <- process(
  folder = "population/age",
  skip = 7,
  n_max = 56,
  col_names = c("county", "p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes", "Total"),
  drop_cols = c(),
  fun = sum
) %>% 
  mutate(p_0_24 = p_0_15 + p_16_24,
         p_25_64 = p_25_44 + p_45_64,
         p_0_24_pct = p_0_24/Total*100,
         p_25_64_pct = p_25_64/Total*100,
         p_65imes_pct = p_65_i_mes/Total*100) %>% 
  select(-Total, -p_0_15, -p_16_24, -p_25_44, -p_45_64, -p_65_i_mes, -p_25_64, -p_0_24)


gr <- read_csv(file.path(path, "population/growth rate/pop_growth_rate.csv"), skip = 10) %>% 
  rename(county = ...1) %>% 
  mutate(across(where(function(x) all(x %in% c(NA, ".", "-") | grepl("^[0-9.-]+$", x))), as.numeric))

gr_pyr <- gr %>% 
  filter(county %in% pyr) %>% 
  summarise(across(where(is.numeric), mean)) %>% 
  mutate(region = "Pyrenees")

gr_cat <- gr %>% 
  filter(county == "Catalunya") %>% 
  select(-county) %>% 
  mutate(region = "Catalunya")

gr <- bind_rows(gr_pyr, gr_cat) %>% 
  pivot_longer(cols = 1:25, names_to = "year", values_to = "p_growthrate") %>% 
  mutate(year = as.numeric(year)) %>% 
  filter(year > 2014) 

population <- list(density, age, gr) %>% 
  reduce(full_join, by = c("region", "year"))

# ECONOMY ----------------------------------------------------------------------

gdp <- process(
  folder = "economy/GDP",
  skip = 6,
  n_max = Inf,
  col_names = c("county", "e_GDP_mileur", "GDP_percapita_eur", "cat_index"),
  drop_cols = c("GDP_percapita_eur", "cat_index"),
  fun = sum
)

gva <- process(
  folder = "economy/GVA",
  skip = 7,
  n_max = 44,
  col_names = c("county", "e_gva_agri", "e_gva_industry", "e_gva_construction", "e_gva_servis", "total"),
  drop_cols = c("total"),
  fun = sum
)

gdhi <- process(
  folder = "economy/GDHI",
  skip = 7,
  n_max = 44,
  col_names = c("county", "e_GDHI_mileur", "GDHI_percapita_eur", "index"),
  drop_cols = c("GDHI_percapita_eur", "index"),
  fun = sum
)

rib <- read_csv(file.path(path, "economy/rib/real_investment_budget.csv"), skip = 12) %>% 
  rename(county = ...1) %>% 
  mutate(across(where(function(x) all(x %in% c(NA, ".", "-") | grepl("^[0-9.-]+$", x))), as.numeric))

rib_pyr <- rib %>% 
  filter(county %in% pyr) %>% 
  summarise(across(where(is.numeric), sum)) %>% 
  mutate(region = "Pyrenees")

rib_cat <- rib %>% 
  filter(county == "Catalunya") %>% 
  select(-county) %>% 
  mutate(region = "Catalunya")

rib <- bind_rows(rib_pyr, rib_cat) %>% 
  pivot_longer(cols = 1:22, names_to = "year", values_to = "e_rib") %>% 
  mutate(year = as.numeric(year)) %>% 
  filter(year > 2014) 

economy <- list(gdp, gva, gdhi, rib) %>% 
  reduce(full_join, by = c("region", "year"))

# WORK -------------------------------------------------------------------------

active <- process(
  folder = "work/active",
  skip = 6,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "w_active"),
  drop_cols = c("a", "b", "c"),
  fun = sum
)

inactive <- process(
  folder = "work/inactive",
  skip = 8,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "d", "w_inactive"),
  drop_cols = c("a", "b", "c", "d"),
  fun = sum
)

unemp <- process(
  folder = "work/unemployment",
  skip = 7,
  n_max = 55,
  col_names = c("county", "a", "b", "c", "d", "e", "w_unemp"),
  drop_cols = c("a", "b", "c", "d", "e"),
  fun = sum
)

work <- list(active, inactive, unemp) %>% 
  reduce(full_join, by = c("region", "year"))

# bring all together
socioeconomy <- list(population, economy, work) %>% 
  reduce(full_join, by = c("region", "year"))

write_json(socioeconomy, file.path(path, "socio-economy.json"), append = FALSE)
