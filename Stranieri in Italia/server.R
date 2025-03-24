server <- function(input, output) {

  output$plot_for_italian_place <- renderPlot({
    message("plotting city")

    plot_for_italian_place(df, input$city, sex =  input$gender_per_city, number_items =  10, italian_category =  "provincia", world_category = "country")
  })

  output$map_for_italian_place <- renderLeaflet({
    map_for_italian_place_leaflet(
      df,
      italian_place = input$city,
      sex = "totale",
      italian_category = "provincia",
    )
  })
  
  output$map_for_country <- renderPlotly({
    message("Rendering plotly map")
    map_for_country_ggplot(
      df,
      country = input$country,
      italian_category = input$italian_category,
      sex = input$gender_per_country,
      use_ratio = input$ratio_country,
    )
  })
  
  output$plot_for_country <- renderPlot({
    message("plotting country")
    message("country ", input$country)
    message("gender ", input$gender)
    
    plot_for_country(df, input$country, input$gender_per_country, 10, input$italian_category)
  })
  
}
