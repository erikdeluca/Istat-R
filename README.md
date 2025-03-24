# Stranieri in Italia

Welcome to the **Stranieri in Italia** Shiny Application, designed to
visualize and analyze ISTAT data on residents in Italy, categorized by
citizenship and area of residence.

## Access the Application Online

You can access the application online through this link: [Stranieri in Italia - Shiny App](https://erikdeluca.shinyapps.io/Stranieri-in-Italia/)

## Overview

This application provides interactive insights into the distribution and
demographics of foreign residents in Italy. The app is structured into
three main sections:

1.  **Statistics by Italian Location**:
    - View the most populated cities, regions, and municipalities by
      foreign residents.
    - Understand the demographics of these areas and from which
      countries these residents originate.
2.  **Statistics by Citizenship**:
    - Analyze data for specific cities or regions and discover the
      countries of origin of their residents.
    - Gain insights into the foreign demographics of selected Italian
      locations.
3.  **Reverse Lookup by Country**:
    - Given a country, identify where its citizens reside in Italy.
    - View this information in terms of absolute numbers and proportions
      relative to the local population.

## Key Features

- **Interactive Visualizations**: Utilize plots and maps to explore and
  understand data.
- **Dynamic Input Options**: Select regions, municipalities, or
  countries of interest using interactive widgets.
- **Proportional Analysis**: Toggle between absolute numbers and
  population proportions to gain different perspectives.

## Installation and Usage

To run this application locally, ensure you have R and the necessary
libraries installed. Follow these steps:

1.  Clone the repository:

``` bash
git clone https://github.com/erikdeluca/ISTAT-R.git
cd ISTAT-R
```

2.  Install the required R packages:

``` r
install.packages(c("shiny", "shinydashboard", "shinycssloaders", "shinyWidgets", "tidyverse", "bsicons", "sass", "leaflet", "sf", "maps", "plotly", "countrycode", "eurostat", "janitor"))
```

3.  Run the Shiny app:

<!-- -->

    shiny::runApp()

## Contributing

Contributions are welcome! Feel free to open issues or submit pull
requests for improvements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for
details.

## Acknowledgements

This app utilizes the ISTAT data on residents in Italy and various R
packages for data manipulation and visualization.
