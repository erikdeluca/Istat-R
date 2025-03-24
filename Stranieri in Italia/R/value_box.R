library(bslib)
library(bsicons)

top_value_box <- function(df, category_italy = "regione", category_world = "country", sesso = "totale", group_by_var = "territorio", accuracy = 0.01, ratio = FALSE) {
  
  if(ratio) var <- "ratio" else var <- "value"
  
  text <- df |>
    left_join(mapping_world_locations, by = "iso") |>
    left_join(mapping_italian_locations, by = c("itter107" = "code", "territorio" = "name"), suffix = c("_world", "_italy")) |>
    filter(
      time == max(time),
      category_italy == !!category_italy,
      paese_di_cittadinanza != "Italia",
      sesso == !!sesso,
      category_world == !!category_world
    ) |>
    summarise(
      var = sum(!!sym(var)),
      .by = !!sym(group_by_var)
    ) |> 
    filter(var == max(var)) |>
    transmute(
      number = ifelse(
        ratio,
        # scales::percent(var, scale = 1000, suffix = "‰"),
        scales::percent(var),
        number(var, scale_cut = cut_short_scale(), accuracy = accuracy)
      ),
      text = paste0(!!sym(group_by_var), ": ", number)
      ) |>
    pull(text)
  
  return(text)
}

# top_value_box(df, category_italy = "regione", group_by_var = "territorio", ratio = T)

print_value_box <- function(title = "title", text = "text", icon = bs_icon("music-note-beamed"), theme = value_box_theme(bg = "#ffffff", fg = "#000000"), more_text = NULL) {
  bslib::value_box(
    title = title,
    value = text,
    showcase = icon,
    theme = theme,
    # max_height = "150px",
    more_text
  )
}

# print_value_box(
#   title = "Cittadini stranieri in Italia",
#   text = top_value_box(df, "regione", "country", "totale", "territorio", ratio = F),
#   icon = bs_icon("people-fill"),
#   theme = value_box_theme(bg = "#dee2ff", fg = "#000000")
# )


