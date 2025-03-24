# load libraries
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(tidyverse)
library(bsicons)
library(sass)
# library(DT)

conflicted::conflict_prefer("select", winner = "dplyr")
conflicted::conflict_prefer("filter", winner = "dplyr")

# delete ui.html
unlink("Stranieri in Italia/ui.html")

# IMPORT CSS ------------
# load scss file
sass(
  input = sass_file("www/styles.scss"),
  output = "www/sass-styles.css",
  options = sass_options(output_style = "compressed")
)

# IMPORT ENVIROMENT ------------
# for the locale shinyapp
# read_rds("data/residenti_in_italia.rds") -> df
# for the erikdeluca.shinyapp.io
read_rds("data/residenti_in_italia_small.rds") -> df
read_rds("data/mapping_world_locations.rds") -> mapping_world_locations
read_rds("data/mapping_italian_locations.rds") -> mapping_italian_locations
read_rds("data/world_borders.rds") -> world_borders
read_rds("data/italian_borders.rds") -> italian_borders

# IMPORT FUNCTIONS ------------
source("R/plot.R")
source("R/map.R")
source("R/value_box.R")


my_palette <- c("#08090a", "#8e9aaf", "#cbc0d3", "#efd3d7", "#feeafa",  "#dee2ff")
