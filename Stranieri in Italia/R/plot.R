collapse_names <- function(names) str_trunc(paste(names, collapse = ", "), side = "right", width = 40)

plot_for_country <- function(df, country = "Romania", sex = "totale", number_items = 10, italian_category = "comune")
{
  df |>
    left_join(mapping_italian_locations, by = c(itter107 = "code", territorio = "name")) |>  
    filter(
      category == italian_category,
      paese_di_cittadinanza %in% country,
      sesso == sex,
      time == max(time)
      ) |> 
    filter(territorio %in% fct_lump_n(territorio, w = value, n = number_items)) |> 
    ggplot() +
    geom_bar(aes(y = reorder(territorio, value, .fn = sum), x = value, fill = paese_di_cittadinanza), stat = "identity") +
    scale_x_continuous(labels = scales::number_format(accuracy = 1, scale_cut = scales::cut_short_scale())) +
    scale_fill_brewer(palette = "Set2") +
    labs(
      title = paste0("Cittadini provenienti da ", collapse_names(country), " in Italia"),
      subtitle = paste0("Top ", number_items, " per ", italian_category),
      x = "Numero di residenti",
      y = "",
      fill = "Paese di cittadinanza",
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
    )
}

# plot_for_country(df, country = c("Romania", "Albania", "Pakistan", "Marocco", "Colombia", "Cina"))


plot_for_italian_place <- function(df, italian_place = "Trieste", sex = "totale", number_items = 10,
                                   world_category = "country", italian_category = "provincia")
{
  df |>
    left_join(mapping_world_locations, by = "iso") |>
    left_join(mapping_italian_locations, by = c(itter107 = "code", territorio = "name"), suffix = c("_world", "_italy")) |>  
    filter(
      category_world == world_category,
      territorio %in% italian_place,
      sesso == sex,
      time == max(time),
      category_italy == italian_category,
    ) |> 
    filter(paese_di_cittadinanza %in% fct_lump_n(paese_di_cittadinanza, w = value, n = number_items)) |>   
    ggplot() +
    geom_bar(aes(y = reorder(paese_di_cittadinanza, value, .fn = sum), x = value, fill = territorio), stat = "identity") +
    scale_x_continuous(labels = scales::number_format(accuracy = 1, scale_cut = scales::cut_short_scale())) +
    # scale_fill_manual(
    #   values = c("maschi" = "skyblue1", "femmine" = "thistle1"),
    #   name = "Sesso"
    # ) +
    scale_fill_brewer(palette = "Set2") +
    labs(
      title = paste0("Cittadini stranieri in ", collapse_names(italian_place)),
      subtitle = paste0("Top ", number_items),
      x = "Numero di residenti",
      y = "",
      color = "Paese di cittadinanza",
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
    )
}

# plot_for_italian_place(df, c("Trieste", "Gorizia", "Udine", "Pordenone"), "totale", 15, "country", "provincia") |> print()


