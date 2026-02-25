# Build your UI page here

library(shiny)
library(bslib)
library(gt)

ui <- page_sidebar(
  title = "Alzheimer's Disease Gene Expression Explorer",
  theme = bs_theme(bootswatch = "flatly"), # apply the Flatly Bootstrap theme
  
  # The global sidebar — always visible regardless of which tab is active. This is where the brain region selector lives, since switching regions should affect all three tabs at once.
  sidebar = sidebar(
    width = 280,
    h5("Dataset"),
    # selectInput() produces a dropdown menu. The named list maps display labels to the file name tags used in server.R.
    selectInput(
      inputId = "brain_region",
      label = "Brain Region:",
      choices = list(
        "Hippocampus" = "hippocampus",
        "Entorhinal Cortex" = "entorhinal_cortex",
        "Postcentral Gyrus" = "postcentral_gyrus",
        "Superior Frontal Gyrus" = "superior_frontal_gyrus"
      ),
      selected = "hippocampus" # default selection on app load
    ),
    hr(), # horizontal rule for visual separation
    p(
      em("Data: GSE48350 — 253 postmortem brain samples (80 AD, 173 controls)."),
      style = "font-size: 0.82em; color: grey;"
    )
  ),
  
  # navset_tab() creates the tabbed main content area. Each nav_panel() is one tab.
  navset_tab(
    nav_panel(
      "Volcano Plot",
      source("tab_ui_files/tab1_ui.R", local = TRUE)$value
    ),
    nav_panel(
      "Heatmap",
      source("tab_ui_files/tab2_ui.R", local = TRUE)$value
    ),
    nav_panel(
      "Top Genes Table",
      source("tab_ui_files/tab3_ui.R", local = TRUE)$value
    )
  )
  )
