# load necessary packages
# and source your functions.R file

library(shiny)
library(tidyverse)

source('functions.R')

# this function defines your server logic
server <- function(input, output, session){
  
  # reactiveValues() creates a shared data container that any part of the server can read from. When the values inside change, any output that depends on them will automatically re-render.
  df <- reactiveValues(
    de_df = NULL, # will hold the differential expression results CSV
    expr_df = NULL # will hold the normalized expression matrix CSV
  )
  
  # A separate reactive flag that tabs use via req() to make sure data is loaded before attempting to render any plots or tables
  analysis <- reactiveValues(ready = FALSE)
  
  # observeEvent() watches input$brain_region and fires whenever the user selects a different region from the sidebar dropdown. Both CSV files are reloaded together, and analysis$ready is set to TRUE, which unlocks all three tabs simultaneously.
  observeEvent(input$brain_region, {
    region_tag <- input$brain_region # e.g. "hippocampus"
    df$de_df <- read.csv(paste0("data/AD_", region_tag, "_de.csv")) # DE results
    df$expr_df <- read.csv(paste0("data/AD_", region_tag, "_expr.csv")) # expression matrix
    analysis$ready <- TRUE
  })
  
  # Each tab's server logic lives in its own file for organization. local = TRUE keeps each file's code scoped inside this server function, so they can access df, analysis, and input directly.
  
  # Tab 1 - Volcano Plot
  source("tab_server_files/tab1.R", local = TRUE)$value
  
  # Tab 2 - Heatmap
  source("tab_server_files/tab2.R", local = TRUE)$value
  
  # Tab 3 - Top Genes Table
  source("tab_server_files/tab3.R", local = TRUE)$value

}
