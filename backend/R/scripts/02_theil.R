

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
path <- "data/socio-economical"

density <- process_theil(
  folder = "population/density",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "p_population", "area_km2", "p_density_hkm2"),
  drop_cols = c("p_density_hkm2"))

# income -----------------------------------------------------------------------
inc <- process_theil(
  folder = "economy/personal income tax",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "income", "tax"),
  drop_cols = c("tax", "X4")
)

inc <- inc %>% 
  pivot_wider(names_from = year, values_from = income)

inc <- inc %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

inc %>% filter(county == "Lluçanès")

write_json(inc, "Observatory-of-the-Mountains/frontend/data/income.json")                         

# rib --------------------------------------------------------------------------
rib <- read_csv(file.path(path, "economy/rib/real_investment_budget.csv"), skip = 12) %>% 
  rename(county = ...1) %>% 
  mutate(across(where(function(x) all(x %in% c(NA, ".", "-") | grepl("^[0-9.-]+$", x))), as.numeric)) %>% 
  filter(county %in% cat)

rib <- rib %>% pivot_longer(values_to = "rib", names_to = "year",  cols = c(2:23)) %>% 
  filter(year > 2014) %>% 
  mutate(year = as.numeric(year))
  
rib <- list(rib, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(rib = rib/p_population*1000000,
        region = ifelse(county %in% pyr, "Pyrenees",
                                  ifelse(county %in% cat, "Catalunya", NA))) %>% 
  select(rib, year, county, region) %>% 
  pivot_wider(names_from = year, values_from = rib) %>% 
  select(-(8:12))



write_json(rib, "Observatory-of-the-Mountains/frontend/data/rib.json")                         

# gdp --------------------------------------------------------------------------
gdp <- process_theil(
  folder = "economy/GDP",
  skip = 6,
  n_max = Inf,
  col_names = c("county", "e_GDP_mileur", "GDP_percapita_eur", "cat_index"),
  drop_cols = c("e_GDP_mileur", "cat_index"))

gdp <- gdp %>% 
  pivot_wider(names_from = year, values_from = "GDP_percapita_eur")

gdp <- gdp %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

l <- data.frame(
  county = "Lluçanès",
  `2013` = NA,
  `2014` = NA,
  `2015` = NA,
  `2016` = NA,
  `2017` = NA,
  `2018` = NA,
  `2019` = NA,
  `2020` = NA,
  `2021` = NA,
  `2022` = NA,
  region = "Catalunya"
)

gdp <- bind_rows(gdp, l) %>% 
  select(-(starts_with("X")))

write_json(gdp, "Observatory-of-the-Mountains/frontend/data/gdp.json")                         

# rural estate tax -------------------------------------------------------------
ret <- process_theil(
  folder = "economy/rural estate tax",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "e_ret_receipts_n", "e_ret_taxable_base", "e_ret_full_fee"),
  drop_cols = c("e_ret_receipts_n", "e_ret_full_fee"))

ret <- list(ret, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(ret = e_ret_taxable_base/p_population * 1000) %>% 
  select(county, year, ret)

ret <- ret %>% 
  pivot_wider(names_from = year, values_from = ret)

ret <- ret %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA))) %>% 
  filter(!is.na(region))

write_json(ret, "Observatory-of-the-Mountains/frontend/data/ret.json")  

# urban estate tax -------------------------------------------------------------
uet <- process_theil(
  folder = "economy/urban estate tax",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "e_uet_receipts_n", "e_uet_taxable_base", "e_uet_full_fee"),
  drop_cols = c("e_uet_receipts_n", "e_uet_full_fee"))

uet <- list(uet, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(uet = e_uet_taxable_base/p_population * 1000) %>% 
  select(county, year, uet)

uet <- uet %>% 
  pivot_wider(names_from = year, values_from = uet)

uet <- uet %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA))) %>% 
  filter(!is.na(region))

write_json(uet, "Observatory-of-the-Mountains/frontend/data/uet.json")  


# gdhi -------------------------------------------------------------------------
gdhi <- process_theil(
  folder = "economy/GDHI",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "e_GDHI", "GDHI_percapita_eur", "index"),
  drop_cols = c("e_GDHI", "index")
)

gdhi <- gdhi %>% 
  pivot_wider(names_from = year, values_from = "GDHI_percapita_eur")

gdhi <- gdhi %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(gdhi, "Observatory-of-the-Mountains/frontend/data/gdhi.json")  


# unemployment -----------------------------------------------------------------
unemp <- process_theil(
  folder = "work/unemployment",
  skip = 8,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "w_unemp"),
  drop_cols = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"))

unemp <- list(unemp, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(unemp = w_unemp/p_population * 100) %>% 
  select(county, year, unemp) %>% 
  pivot_wider(names_from = year, values_from = unemp)

unemp <- unemp %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(unemp, "Observatory-of-the-Mountains/frontend/data/unemp.json")  



unemp_men <- process_theil(
  folder = "work/unemployment",
  skip = 72,
  n_max = 54,
  col_names = c("county", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "w_unemp_men"),
  drop_cols = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"))

men <- process_theil(
  folder = "population/age",
  skip = 70,
  n_max = 56,
  col_names = c("county", "p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes", "p_men"),
  drop_cols = c("p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes"))

unemp_men <- list(unemp_men, men) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(unemp = w_unemp_men/p_men * 100) %>% 
  select(county, year, unemp) %>% 
  pivot_wider(names_from = year, values_from = unemp)

unemp_men <- unemp_men %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(unemp_men, "Observatory-of-the-Mountains/frontend/data/unemp_men.json")  




unemp_women <- process_theil(
  folder = "work/unemployment",
  skip = 136,
  n_max = Inf,
  col_names = c("county", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "w_unemp_women"),
  drop_cols = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"))

women <- process_theil(
  folder = "population/age",
  skip = 133,
  n_max = Inf,
  col_names = c("county", "p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes", "p_women"),
  drop_cols = c("p_0_15", "p_16_24", "p_25_44", "p_45_64", "p_65_i_mes"))

unemp_women <- list(unemp_women, women) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(unemp = w_unemp_women/p_women * 100) %>% 
  select(county, year, unemp) %>% 
  pivot_wider(names_from = year, values_from = unemp)

unemp_women <- unemp_women %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(unemp_women, "Observatory-of-the-Mountains/frontend/data/unemp_women.json")  






# education --------------------------------------------------------------------
edu <- process_theil(
  folder = "education",
  skip = 7,
  n_max = Inf,
  col_names = c("county", "edu_illeterate", "partial_primary", "edu_primary", "1_stage_secondary", "edu_2_stage_secondary_go", 
                "edu_2_stage_secondary_so", "higher-level", "edu_university_bach", "edu_university_bac_240c", "edu_university_mas", 
                "edu_university_doc", "total"),
  drop_cols = c("partial_primary","1_stage_secondary","higher-level"))

edu <- edu %>% 
  mutate(edu_university = edu_university_bach + edu_university_bac_240c + edu_university_mas + edu_university_doc,
         edu_university_pct = edu_university/total*100) %>% 
  select(county, year, edu_university_pct)

edu <- edu %>% 
  pivot_wider(names_from = year, values_from = edu_university_pct)

edu <- edu %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(edu, "Observatory-of-the-Mountains/frontend/data/edu.json")  

# housing ----------------------------------------------------------------------
old <- process_theil(
  folder = "housing/old",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "h_value_old", "h_variation"),
  drop_cols = c("h_variation")
)

old <- old %>% 
  pivot_wider(names_from = year, values_from = "h_value_old")

old <- old %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(old, "Observatory-of-the-Mountains/frontend/data/old.json")  

new <- process_theil(
  folder = "housing/new",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "h_value_new", "h_variation"),
  drop_cols = c("h_variation")
)

new <- new %>% 
  pivot_wider(names_from = year, values_from = "h_value_new")

new <-new %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(new, "Observatory-of-the-Mountains/frontend/data/new.json")  



# path to environmental data
path <- "../../data/environmental"

 # water -----------------------------------------------------------------------
water <- process_theil(
  folder = "water/consump",
  skip = 9,
  n_max = Inf,
  col_names = c("county", "w_domestic", "w_industry", 
                "w_total_network", "w_own_sources", "w_total"),
  drop_cols = c("w_total_network", "w_own_sources"))

water <- list(water, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(across(starts_with("w_"), ~ (.x*1000) /p_population)) 

w_domestic <- water %>% 
  select(w_domestic, year, county)  %>% 
  pivot_wider(names_from = year, values_from = "w_domestic") %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(w_domestic, "Observatory-of-the-Mountains/frontend/data/w_domestic.json")  


w_industry <- water %>% 
  select(w_industry, year, county)  %>% 
  pivot_wider(names_from = year, values_from = "w_industry") %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(w_industry, "Observatory-of-the-Mountains/frontend/data/w_industry.json")  


w_total <- water %>% 
  select(w_total, year, county)  %>% 
  pivot_wider(names_from = year, values_from = "w_total") %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(w_total, "Observatory-of-the-Mountains/frontend/data/w_total.json")  

land <- process_theil(
  folder = "land",
  skip = 9,
  n_max = Inf,
  col_names = c("county", "l_forests", "l_bushes", "l_others", "l_novege", "l_crop_dry", "l_crop_irri", "l_urban"),
  drop_cols = c())


land <- list(land, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(l_agri = l_crop_dry + l_crop_irri,
         across(starts_with("l_"), ~ .x /(area_km2*100) * 100))

land <- land %>% 
  filter(!(year == 2024)) %>% 
  group_by(county) %>% 
  arrange(year) %>% 
  mutate(l_forest_roc = ((l_forests - lag(l_forests)) / lag(l_forests)) * 100 / (year - lag(year)),
         l_bushes_roc = ((l_bushes - lag(l_bushes)) / lag(l_bushes)) * 100 / (year - lag(year)),
         l_agri_roc = ((l_agri - lag(l_agri)) / lag(l_agri)) * 100 / (year - lag(year)),
         l_novege_roc = ((l_novege - lag(l_novege)) / lag(l_novege)) * 100 / (year - lag(year)),
         l_urban_roc = ((l_urban - lag(l_urban)) / lag(l_urban)) * 100 / (year - lag(year)),
         l_others_roc = ((l_others - lag(l_others)) / lag(l_others)) * 100 / (year - lag(year))) %>% 
  ungroup() %>% 
  rowwise() %>% 
  mutate(lc_sum = sum(abs(c_across(ends_with("_roc"))))) %>% 
  select(county, year, lc_sum)

land <- land %>% 
  pivot_wider(names_from = year, values_from = "lc_sum") %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))


write_json(land, "Observatory-of-the-Mountains/frontend/data/land.json")  

# mun waste --------------------------------------------------------------------
# ind waste --------------------------------------------------------------------
mun <- process_theil(
  folder = "waste/municipal",
  skip = 8,
  n_max = Inf,
  col_names = c("county", "glass", "papre", "lightweight", "organic", "pruning", "heavy_waste", "others", "w_mun"),
  drop_cols = c(2:8))

ind <- process_theil(
  folder = "waste/industrial",
  skip = 10,
  n_max = Inf,
  col_names = c("county", "esta", "speacial", "not_special", "w_ind"),
  drop_cols = c(2:4))

waste <- list(mun, ind, density) %>% 
  reduce(full_join, by = c("county", "year")) %>% 
  mutate(w_mun = w_mun/p_population * 1000,
         w_ind = w_ind/area_km2 * 1000)

w_mun <- waste %>% 
  select(w_mun, county, year) %>% 
  pivot_wider(names_from = year, values_from = "w_mun") %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(w_mun, "Observatory-of-the-Mountains/frontend/data/w_mun.json")  

w_ind <- waste %>% 
  select(w_ind, county, year) %>% 
  pivot_wider(names_from = year, values_from = "w_ind") %>% 
  mutate(region = ifelse(county %in% pyr, "Pyrenees",
                         ifelse(county %in% cat, "Catalunya", NA)))

write_json(w_ind, "Observatory-of-the-Mountains/frontend/data/w_ind.json")  
