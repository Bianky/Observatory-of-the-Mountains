
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
source("R/process.R")


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
  fun = sum) %>% 
  mutate(p_0_24 = p_0_15 + p_16_24,
         p_25_64 = p_25_44 + p_45_64,
         p_0_24_pct = round(p_0_24/Total*100, 2),
         p_25_64_pct = round(p_25_64/Total*100, 2),
         p_65imes_pct = round(p_65_i_mes/Total*100, 2))%>% 
  select(-Total, -p_0_15, -p_16_24, -p_25_44, -p_45_64, -p_65_i_mes, -p_25_64, -p_0_24)

men <- process(
  folder = "population/age",
  skip = 70,
  n_max = 56,
  col_names = c("county", "p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes", "p_men"),
  drop_cols = c("p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes"),
  fun = sum)

women <- process(
  folder = "population/age",
  skip = 133,
  n_max = Inf,
  col_names = c("county", "p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes", "p_women"),
  drop_cols = c("p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes"),
  fun = sum)


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

population <- list(density, age, gr, men, women) %>% 
  reduce(full_join, by = c("region", "year"))

# HOUSING ----------------------------------------------------------------------

old <- process(
  folder = "housing/old",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "h_value_old", "h_variation"),
  drop_cols = c("h_variation"),
  fun = mean
)

new <- process(
  folder = "housing/new",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "h_value_new", "h_variation"),
  drop_cols = c("h_variation"),
  fun = mean
)

housing <- list(old, new) %>% 
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
  n_max = 43,
  col_names = c("county", "e_gva_agri", "e_gva_industry", "e_gva_construction", "e_gva_servis", "total"),
  drop_cols = c("total"),
  fun = sum
)

gdhi <- process(
  folder = "economy/GDHI",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "e_GDHI", "GDHI_percapita_eur", "index"),
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

pit <- process(
  folder = "economy/personal income tax",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "e_pit_tasablebase_percontributor", "e_pit_resulting_quota"),
  drop_cols = c(),
  fun = mean
)

ret <- process(
  folder = "economy/rural estate tax",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "e_ret_receipts_n", "e_ret_taxable_base", "e_ret_full_fee"),
  drop_cols = c(),
  fun = mean
)

uet <- process(
  folder = "economy/urban estate tax",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "e_uet_receipts_n", "e_uet_taxable_base", "e_uet_full_fee"),
  drop_cols = c(),
  fun = mean
)

economy <- list(gdp, gva, gdhi, rib, pit, ret, uet) %>% 
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

active_men <- process(
  folder = "work/active",
  skip = 68,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "w_active_men"),
  drop_cols = c("a", "b", "c"),
  fun = sum
)


active_women <- process(
  folder = "work/active",
  skip = 130,
  n_max = Inf,
  col_names = c("county", "a", "b", "c", "w_active_women"),
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

inactive_men <- process(
  folder = "work/inactive",
  skip = 70,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "d", "w_inactive_men"),
  drop_cols = c("a", "b", "c", "d"),
  fun = sum
)

inactive_women <- process(
  folder = "work/inactive",
  skip = 132,
  n_max = Inf,
  col_names = c("county", "a", "b", "c", "d", "w_inactive_women"),
  drop_cols = c("a", "b", "c", "d"),
  fun = sum
)

unemp <- process(
  folder = "work/unemployment",
  skip = 8,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "w_unemp"),
  drop_cols = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"),
  fun = sum
)

unemp_men <- process(
  folder = "work/unemployment",
  skip = 72,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "w_unemp_men"),
  drop_cols = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"),
  fun = sum
)


unemp_women <- process(
  folder = "work/unemployment",
  skip = 136,
  n_max = Inf,
  col_names = c("county", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "w_unemp_women"),
  drop_cols = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"),
  fun = sum
)


work <- list(active, active_men, active_women, inactive, inactive_men, inactive_women, unemp, unemp_men, unemp_women) %>% 
  reduce(full_join, by = c("region", "year"))


# EDUCATION --------------------------------------------------------------------
# 15 and higher
edu <- process(
  folder = "education",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "edu_illeterate", "partial_primary", "edu_primary", "1_stage_secondary", "edu_2_stage_secondary_go", 
                "edu_2_stage_secondary_so", "higher-level", "edu_university_bach", "edu_university_bac_240c", "edu_university_mas", 
                "edu_university_doc", "total"),
  drop_cols = c("partial_primary","1_stage_secondary","higher-level"),
  fun = sum 
)

education <- edu %>% 
  mutate(edu_secondary = `edu_2_stage_secondary_go` + `edu_2_stage_secondary_so`,
         edu_university = edu_university_bach + edu_university_bac_240c + edu_university_mas + edu_university_doc) %>% 
  mutate(edu_illiterate_pct = round(edu_illeterate/total*100, 2),
         edu_primary_pct = round(edu_primary/total*100, 2),
         edu_secondary_pct = round(edu_secondary/total*100, 2),
         edu_university_pct = round(edu_university/total*100, 2)) %>% 
  select(region, year, edu_illiterate_pct, edu_primary_pct, edu_secondary_pct, edu_university_pct)


# ENGAGEMENT -------------------------------------------------------------------

assoc <- process(
  folder = "engagement/associations",
  skip = 11,
  n_max = Inf,
  col_names = c("county", "social_assis", "culture", "teaching_research", "rights", "sectors", "space", "health", "others", "eng_assoc"),
  drop_cols = c(2:9),
  fun = sum 
)

found <- process(
  folder = "engagement/foundations",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "assistance", "cultural", "teachers", "scientific", "eng_found"),
  drop_cols = c(2:5),
  fun = sum 
)

engagement <- list(assoc, found)%>% 
  reduce(full_join, by = c("region", "year"))


# bring all together
socioeconomy <- list(population, economy, work, education, engagement, housing) %>% 
  reduce(full_join, by = c("region", "year")) %>% 
  mutate(p_men_pct = p_men/p_population*100,
         p_women_pct = p_women/p_population*100,
         e_GDP_pc               = round(if_else(region == "Pyrenees", e_GDP_mileur / 9,  e_GDP_mileur / 43) * 1e6, 2),
         e_GDP_pi               = round(e_GDP_mileur / p_population * 1e6, 2),
           
         e_gva_agri_pc          = round(if_else(region == "Pyrenees", e_gva_agri / 9,  e_gva_agri / 43) * 1e6, 2),
         e_gva_agri_pi          = round(e_gva_agri / p_population * 1e6, 2),
           
         e_gva_industry_pc      = round(if_else(region == "Pyrenees", e_gva_industry / 9,  e_gva_industry / 43) * 1e6, 2),
         e_gva_industry_pi      = round(e_gva_industry / p_population * 1e6, 2),
           
         e_gva_construction_pc  = round(if_else(region == "Pyrenees", e_gva_construction / 9, e_gva_construction / 43) * 1e6, 2),
         e_gva_construction_pi  = round(e_gva_construction / p_population * 1e6, 2),
           
         e_gva_servis_pc        = round(if_else(region == "Pyrenees", e_gva_servis / 9, e_gva_servis / 43) * 1e6, 2),
         e_gva_servis_pi        = round(e_gva_servis / p_population * 1e6, 2),
           
         e_GDHI_pc              = round(e_GDHI, 2),
         e_GDHI_pi              = round(e_GDHI / p_population * 1000, 2),
         w_active               = round(w_active / p_population * 100, 2),
         w_active_men           = round(w_active_men / p_men * 100, 2),
         w_active_women         = round(w_active_women / p_women * 100, 2),
         w_inactive             = round(w_inactive / p_population * 100, 2),
         w_inactive_men         = round(w_inactive_men / p_men * 100, 2),
         w_inactive_women       = round(w_inactive_women / p_women * 100, 2),
         w_unemp                = round(w_unemp / p_population * 100, 2),
         w_unemp_men            = round(w_unemp_men / p_men * 100, 2),
         w_unemp_women          = round(w_unemp_women / p_women * 100, 2),
         e_rib_pc               = if_else(`region` == "Pyrenees", e_rib/9, e_rib/43),
         e_rib_pi               = round(e_rib/p_population*1000000, 2),
         e_rib                  = e_rib,
         eng_found_pc           = if_else(`region` == "Pyrenees", eng_found/9, eng_found/43),
         eng_assoc_pc           = if_else(`region` == "Pyrenees", eng_assoc/9, eng_assoc/43)
         )

socioeconomy <- socioeconomy %>%
  mutate(across(where(is.numeric), ~ round(., 2)))

write_json(socioeconomy, "C:/Users/Bianka/Documents/MSc-Internship/Observatory-of-the-Mountains/frontend/data/socio-economy.json", append = FALSE)
