
# packages
library(tidyverse)
library(sf)
library(patchwork)
library(patchwork)
library(classInt)


geometry <- st_read("data/counties/divisions-administratives-v2r1-comarques-5000-20250730.shp") %>% 
  st_transform(4326) %>% 
  select(NOMCOMAR, geometry) %>% 
  rename(county = NOMCOMAR)

geometry$county[geometry$county == "Val d'Aran"] <- "Aran"

geometry_regions <- st_read("data/counties/geometry_regions.geojson") %>% 
  st_transform(4326)
  
  
rib <- rib %>% 
  select(county, region, `2020`) %>% 
  rename(rib_2020 = `2020`)

unemp <- unemp %>% 
  select(county, `2023`) %>% 
  rename(unemp_2023 = `2023`)

new <- new %>% 
  select(county, `2015`) %>% 
  rename(new_2015 = `2015`)


socio <- list(rib, unemp, new, geometry) %>% 
  reduce(full_join, by = "county") %>% 
  st_as_sf()

st_geometry(socio) <- "geometry"


paletteer_dynamic("cartography::sand.pal", 20)

# breaks for 5 quantiles
brks_1 <- classIntervals(socio$rib_2020[!is.na(socio$rib_2020)], n = 5, style = "quantile")$brks

socio_1 <- ggplot(socio) +
  geom_sf(aes(fill = cut(rib_2020, breaks = brks_1, include.lowest = TRUE)), color = "grey") +
  geom_sf(
    data = subset(geometry_regions),
    fill = NA,
    color = "black",
    linewidth = .7
  ) + 
  scale_fill_manual(
    name = "RIB (€)",
    values = paletteer::paletteer_dynamic("cartography::sand.pal", 5)
  ) +  theme_minimal() +
  theme(legend.position = c(0.82, 0.22),
        legend.key.size = unit(1.2, "cm"),
        legend.title = element_text(size = 17),
        legend.text  = element_text(size = 15))

brks_2 <- classIntervals(socio$new_2015[!is.na(socio$new_2015)], n = 5, style = "quantile")$brks

labels_2 <- paste0(
  round(brks_2[-length(brks_2)], 2),
  " - ",
  round(brks_2[-1], 2)
)
socio_2 <- ggplot(socio) +
  geom_sf(aes(fill = cut(new_2015, breaks = brks_2, include.lowest = TRUE, labels = labels_2)), color = "grey") +
  geom_sf(
    data = subset(geometry_regions),
    fill = NA,
    color = "black",
    linewidth = .7
  ) + 
  scale_fill_manual(
    name = "new house price (€/m²)",
    values = paletteer::paletteer_dynamic("cartography::sand.pal", 5)
  ) +   theme_minimal() +
  theme(legend.position = c(0.82, 0.22),
        legend.key.size = unit(1.2, "cm"),
        legend.title = element_text(size = 17),
        legend.text  = element_text(size = 15)) 

brks_3 <- classIntervals(socio$unemp_2023[!is.na(socio$unemp_2023)], n = 5, style = "quantile")$brks

socio_3 <- ggplot(socio) +
  geom_sf(aes(fill = cut(unemp_2023, breaks = brks_3, include.lowest = TRUE)), color = "grey") +
  geom_sf(
    data = subset(geometry_regions),
    fill = NA,
    color = "black",
    linewidth = .7
  ) + 
  scale_fill_manual(
    name = "unemployment (%)",
    values = paletteer::paletteer_dynamic("cartography::sand.pal", 5)
  ) +   theme_minimal() +
  theme(legend.position = c(0.82, 0.22),
        legend.key.size = unit(1.2, "cm"),
        legend.title = element_text(size = 17),
        legend.text  = element_text(size = 15))



comb_02 <- socio_1 + socio_2 + socio_3 + plot_layout(ncol = 3)
comb_02

land <- land %>% 
  select(county, region, `2022`) %>% 
  rename(land_2022 = `2022`)

w_ind <- w_ind %>% 
  select(county, `2016`) %>% 
  rename(wind_2016 = `2016`)

w_dom <- w_domestic %>% 
  select(county, `2023`) %>% 
  rename(wdom_2023 = `2023`)

ec <- list(land, w_ind, w_dom, geometry) %>% 
  reduce(full_join, by = "county")%>% 
  st_as_sf()

st_geometry(ec) <- "geometry"

library(palatteer)
paletteer_dynamic("cartography::kaki.pal", 20)

library(scales)
# breaks for 5 quantiles
brks_4 <- classIntervals(ec$land_2022[!is.na(ec$land_2022)], n = 5, style = "quantile")$brks

envi_1 <- ggplot(ec) +
  geom_sf(aes(fill = cut(land_2022, breaks = brks_4, include.lowest = TRUE)), color = "grey") +
  geom_sf(
    data = subset(geometry_regions),
    fill = NA,
    color = "black",
    linewidth = .7
  ) + 
  scale_fill_manual(
    name = "land conversion (%)",
    values = paletteer::paletteer_dynamic("cartography::kaki.pal", 5)
  ) +
  theme_minimal() +
  theme(legend.position = c(0.82, 0.22),
        legend.key.size = unit(1.2, "cm"),
        legend.title = element_text(size = 17),
        legend.text  = element_text(size = 15))

brks_5 <- classIntervals(ec$wind_2016[!is.na(ec$wind_2016)], n = 5, style = "quantile")$brks

labels_5 <- paste0(
  round(brks_5[-length(brks_5)], 2),
  " - ",
  round(brks_5[-1], 2)
)

envi_2 <- ggplot(ec) +
  geom_sf(aes(fill = cut(wind_2016, breaks = brks_5, include.lowest = TRUE, labels = labels_5)), 
          color = "grey") +
  geom_sf(
    data = subset(geometry_regions),
    fill = NA,
    color = "black",
    linewidth = .7
  ) + 
  scale_fill_manual(
    name = "industrial waste (kg)",
    values = paletteer::paletteer_dynamic("cartography::kaki.pal", 5)
  ) +  theme_minimal() +
  theme(legend.position = c(0.82, 0.22),
        legend.key.size = unit(1.2, "cm"),
        legend.title = element_text(size = 17),
        legend.text  = element_text(size = 15))

brks_6 <- classIntervals(ec$wdom_2023[!is.na(ec$wdom_2023)], n = 5, style = "quantile")$brks

envi_3 <- ggplot(ec) +
  geom_sf(aes(fill = cut(wdom_2023, breaks = brks_6, include.lowest = TRUE)), color = "grey") +
  geom_sf(data = subset(geometry_regions),fill = NA,color = "black",linewidth = .7) + 
  scale_fill_manual(
    name = "domestic water consum (m³)",
    values = paletteer::paletteer_dynamic("cartography::kaki.pal", 5)
  ) +  theme_minimal() +
  theme(legend.position = c(0.82, 0.22),
        legend.key.size = unit(1.2, "cm"),
        legend.title = element_text(size = 17),
        legend.text  = element_text(size = 15)) 


comb_01 <- socio_1 + socio_2 + socio_3 + envi_1 + envi_2 + envi_3 + plot_layout(ncol = 3)
comb_01

comb <- comb_02 + comb_01 + plot_layout(ncol = 3)
comb
