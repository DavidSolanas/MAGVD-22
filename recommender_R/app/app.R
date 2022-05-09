library(shinyWidgets)
library(DT)
library(tidyverse)
library(dplyr)
library(reshape2)
library(recommenderlab)

rm(list = ls())
gc()

source("load_data.R", local = TRUE)$value

ui <- fluidPage(
  sidebarPanel(
    h2("Select and rate 10 movies from 0 to 5"),
    pickerInput(inputId = "movie_selection",
                label = "",
                choices = movie_names,
                options = pickerOptions(
                  actionsBox = FALSE,
                  maxOptions = 10 # maximum of options
                ), 
                multiple = TRUE),
    h4(" "),
    uiOutput("movie_rating01"),
    uiOutput("movie_rating02"),
    uiOutput("movie_rating03"),
    uiOutput("movie_rating04"),
    uiOutput("movie_rating05"),
    uiOutput("movie_rating06"),
    uiOutput("movie_rating07"),
    uiOutput("movie_rating08"),
    uiOutput("movie_rating09"),
    uiOutput("movie_rating10"),
    actionButton("run", "Run")
  ),
  mainPanel(
    tableOutput("recomm")
  )
)


server <- function(input, output, session) {
  source("ui_server.R", local = TRUE)$value
  source("data_server.R", local = TRUE)$value
}

shinyApp(ui = ui, server = server)