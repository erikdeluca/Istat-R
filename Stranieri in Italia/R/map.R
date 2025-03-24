library(leaflet)
library(sf)
library(maps)
library(plotly)

source("R/label_number.R")

# Function for creating a Leaflet map for Italian locations
map_for_italian_place_leaflet <- function(df,
                                          italian_place = c("Trieste", "Udine"),
                                          sex = "totale",
                                          italian_category = "provincia",
                                          world_category = "country",
                                          accuracy_ratio = 0.01) 
{
  data <-
    df |> 
    left_join(mapping_world_locations, by = "iso") %>%
    left_join(mapping_italian_locations, by = c("itter107" = "code", "territorio" = "name"), suffix = c("_world", "_italy")) %>%
    filter(
      category_world == world_category,
      territorio %in% italian_place,
      sesso == sex,
      time == max(time),
      category_italy == italian_category
    ) %>%
    mutate(
      var = value,
      across(ratio, \(x) ifelse(x < 0.0001, "< 0.01%", scales::percent(x, accuracy = accuracy_ratio))),
      across(value, \(x) number(x, scale_cut = cut_short_scale(), accuracy = 1)),
      label_per_city = paste0(str_to_sentence(italian_category), ": ", territorio, "<br>",
                              "Numero di residenti: ", value, "<br>",
                              "Rapporto: ", ratio),
      .by = c(name_map, territorio)
    ) |> 
    summarise(
      var = sum(var, na.rm = TRUE),
      label = paste(label_per_city, collapse = "<br>"),
      .by = c(name_map)
    ) |> 
    mutate(
      label = str_c("<b>", name_map, "</b> <br>", label),
      .by = name_map
    ) |> 
    # mutate(across(label, HTML)) |> 
    # mutate(across(label, \(x) str_replace_all(x, "<br>", "\n"))) |>
    # mutate(across(label, gt::md)) |>
    left_join(world_borders, by = c("name_map" = "region")) |>  
    filter(!is.na(group)) %>%
    st_as_sf()
  
  data$label <- purrr::map(
    data$label,
    HTML
  )
  
  world_leaflet = sf::as_Spatial(data)
  
  pal <- colorNumeric(
    palette = "BuPu",  
    domain = log(world_leaflet$var)
  )
  
  leaflet() %>%
    addProviderTiles("CartoDB.Positron") %>% 
    addPolygons(
      data = world_leaflet,
      color = ~pal(log(var)),
      fill = TRUE,
      label = ~label,
      opacity = 1
    )
}

# map_for_italian_place_leaflet(df, c("Trieste", "Udine", "Milano"), "totale", "provincia")


map_for_country_ggplot <- function(df,
                                   country = c("Romania", "Albania", "Pakistan", "Marocco"),
                                   italian_category = "provincia",
                                   sex = "totale",
                                   use_ratio = TRUE,
                                   accuracy_ratio = 0.01
                                   )
{
  var_name <- ifelse(use_ratio, "ratio", "value")
  
  data <- df |> 
    left_join(mapping_italian_locations, by = c(itter107 = "code", territorio = "name")) |>  
    filter(
      category == italian_category,
      paese_di_cittadinanza %in% country,
      sesso == sex,
      time == max(time)
    ) |>
    mutate(
      var = !!sym(var_name),
      label = paste0(paese_di_cittadinanza, ": ",
                     number(value, scale_cut = cut_short_scale(), accuracy = 1), " (",
                     ifelse(ratio < 0.0001, "< 0.01%", scales::percent(ratio, accuracy = accuracy_ratio)),
                     ")"),
      territorio= str_replace(territorio, " / ", "-"), # for Bolzano
    ) |> 
    reframe(
      var = sum(var, na.rm = TRUE),
      label = paste0(territorio, "<br>", paste(label, collapse = "<br>")),
      .by = c(territorio, itter107)
      ) 
  
  p <- italian_borders %>%
    mutate(across(c(NAME_LATN, NUTS_NAME), ~str_replace_all(., "/", "-"))) |>
    left_join(data, by = c("NUTS_NAME" = "territorio")) |>
    filter(
      LEVL_CODE == case_when(
        italian_category == "provincia" ~ 3,
        italian_category == "regione" ~ 2,
        italian_category == "macroregione" ~ 1
      ),
    ) |> 
    ggplot() +
    geom_sf(aes(fill = var, text = label), size = 0.4) +
    scale_fill_viridis_c(
      option = "cividis",
      name = "Valore",
      direction = -1,
      na.value = "white",
      labels = \(x) if (use_ratio) scales::percent(x, accuracy = accuracy_ratio) else number(x, accuracy = 1, scale_cut = cut_short_scale()),
      trans = "log",
      breaks = scales::log_breaks()
    ) +
    theme_void() +
    labs(
      title = paste0("paese di provenienza per ", italian_category)
    )
  
  ggplotly(p, tooltip = "text") |> 
    plotly::layout(
      xaxis = list(showline = FALSE, zeroline = FALSE),
      yaxis = list(showline = FALSE, zeroline = FALSE)
    ) 
}

# map_for_country_ggplot(df, c("Romania", "Colombia"), "regione", "totale", use_ratio = T)

# data |> distinct(itter107, territorio) |> arrange(territorio) |>  print(n = 100)
# 
# italian_borders %>%
#   mutate(across(c(NAME_LATN, NUTS_NAME), ~str_replace_all(., "/", "-"))) |>
#   left_join(data, by = c("NUTS_NAME" = "territorio")) |>
#   filter(
#     LEVL_CODE == case_when(
#       italian_category == "provincia" ~ 3,
#       italian_category == "regione" ~ 2,
#       italian_category == "macroregione" ~ 1
#     )
#   ) |> filter(is.na(value))

