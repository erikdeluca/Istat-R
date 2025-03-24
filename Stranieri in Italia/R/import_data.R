library(countrycode)
library(eurostat)
library(tidyverse)
library(sf)
library(maps)

# unzip the data
# unzip("data/residenti_stranieri_in_italia.zip",  exdir = "data")
# unzip("data/residenti_in_italia.zip",  exdir = "data")

# rename the files
# file.rename("data/DCIS_POPRES1 - Popolazione residente al 1° gennaio - intero ds.csv", "data/residenti_in_italia.csv")
# file.rename("data/DCIS_POPSTRCIT1 - Stranieri residenti al 1° gennaio - Cittadinanza - intero ds.csv", "data/residenti_stranieri_in_italia.csv")
# 

# load the data -----------------------------------------------------------------------------------------------

# stranieri in italia
read_delim("data/residenti_stranieri_in_italia.csv", delim = "|") |> 
  tibble() |> 
  janitor::clean_names() |>
  janitor::remove_empty(c("rows", "cols")) |>
  janitor::remove_constant() -> df_stranieri
  # mutate(across(where(is.character), as.factor)) |>
  # filter(value > 30) 

# residenti in italia
read_delim("data/residenti_in_italia.csv", delim = ",") |>
  tibble() |>
  janitor::clean_names() |>
  janitor::remove_empty(c("rows", "cols")) |>
  janitor::remove_constant() |>
  # mutate(across(where(is.character), as.factor)) |>
  # filter(value > 30) |> 
  select(itter107, time, sesso, value) -> df_residenti

# join the two datasets
left_join(
  df_stranieri,
  df_residenti,
  by = c("itter107", "time", "sesso"),
  suffix = c("", "_residenti")
) |> 
mutate(
  ratio = value / value_residenti
) |> 
  select(itter107, territorio, sesso, iso, paese_di_cittadinanza, time, value, ratio) -> df

# read the continents and the macroregions
df |> 
  distinct(iso, nome = paese_di_cittadinanza) |>
  mutate(
    iso = case_when(
      nome == "Kosovo" ~ "XK",
      nome == "Namibia" ~ "NA",
      nome == "Regno unito" ~ "GB",
      TRUE ~ iso
    ),
    category = case_when(
      iso %in% c("EU28", "WORLD", "999") ~ "macroregion", # 999 apolide
      str_detect(iso, "_") ~ "macroregion",
      TRUE ~ "country"
    ),
    name = countrycode(iso, origin = "iso2c", destination = "country.name.en"),
    name = ifelse(is.na(name), nome, name),
    name_map = case_when(
      name == "United Kingdom" ~ "UK",
      name == "United States" ~ "USA",
      name == "Czechia" ~ "Czech Republic",
      name == "Bosnia & Herzegovina" ~ "Bosnia and Herzegovina",
      name == "Côte d’Ivoire" ~ "Ivory Coast",
      name == "Congo - Kinshasa" ~ "Democratic Republic of the Congo",
      name == "Congo - Brazzaville" ~ "Republic of Congo",
      name == "Myanmar (Burma)" ~ "Myanmar",
      name == "Palestinian Territories" ~ "Palestine",
      TRUE ~ name
    ),
    emoji = countrycode(iso, origin = "iso2c", destination = "unicode.symbol"),
    continent = countrycode(iso, origin = "iso2c", destination = "continent"),
    region = countrycode(iso, origin = "iso2c", destination = "region"),
    region23 = countrycode(iso, origin = "iso2c", destination = "region23"),
    iso = case_when(
      iso == "GB" ~ "UK",
      TRUE ~ iso
    )
  ) -> mapping_world_locations

mapping_italian_locations <- df |> 
  distinct(code = itter107) |> 
  left_join(df |> select(itter107, name = territorio), by = c("code" = "itter107")) |> 
  distinct(code, name) |> 
  mutate(
    category = case_when(
      str_detect(code, "^[A-Z]{3}$") ~ "macroregione",
      str_detect(code, "^[A-Z]{3}[0-9]{1}$") ~ "regione",
      str_detect(code, "^[A-Z]{3}[0-9]{2}$") ~ "provincia",
      str_detect(code, "^[0-9]{6}$") ~ "comune",
    )
  ) |> 
  filter(!is.na(name))

# MAPS -----------------------------------------------------------------------------------------------
# Get the borders of the world countries
world_borders <- map_data("world", exact = F)

world_borders <- st_as_sf(world_borders, coords = c("long", "lat"), crs = 4326, remove = FALSE) %>%
  arrange(group, order) %>%  # Assicurati che i punti siano nell'ordine corretto
  group_by(region, group) %>%
  summarise(geometry = st_combine(geometry), .groups = 'drop') %>%
  st_cast("POLYGON")

world_borders <- st_cast(world_borders, "MULTIPOLYGON")

italian_borders <- get_eurostat_geospatial(resolution = 60) |> 
  filter(CNTR_CODE %in% c("IT"))


## get the countries that are not in the world map
mapping_world_locations |> 
  left_join(df |> summarise(value = max(value), .by = paese_di_cittadinanza), by = c("nome" = "paese_di_cittadinanza")) |>
  anti_join(map_data("world", exact = F), by = c("name_map" = "region")) |>
  filter(category == "country") |>
  arrange(desc(value))

# map_data("world", exact = F) |>
#   distinct(region) |>
#   filter(!region %in% mapping_world_locations$name_map) |>
#   arrange(region)

# resize  the df to work in shinyapp.com and github.com
df |> 
  filter(
    # !(ratio < 1e-8 & territorio != "Italia"),
    value > 5
    ) -> df_small


write_rds(df, "Stranieri in Italia/data/residenti_in_italia.rds")
write_rds(df_small, "Stranieri in Italia/data/residenti_in_italia_small.rds")
write_rds(italian_borders, "Stranieri in Italia/data/italian_borders.rds")
write_rds(world_borders, "Stranieri in Italia/data/world_borders.rds")
write_rds(mapping_world_locations, "Stranieri in Italia/data/mapping_world_locations.rds")
write_rds(mapping_italian_locations, "Stranieri in Italia/data/mapping_italian_locations.rds")


