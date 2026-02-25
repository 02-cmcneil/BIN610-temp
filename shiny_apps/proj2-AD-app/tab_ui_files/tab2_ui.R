layout_sidebar(
  sidebar = sidebar(
    width = 260,
    # numericInput() lets the user type or increment the number of top genes to show in the heatmap. Passed to make_heatmap_df() as num_genes.
    numericInput(
      inputId = "num_genes_t2",
      label = "Number of top genes to display:",
      value = 20,
      min = 2,
      max = 50
    ),
    # checkboxGroupInput() lets the user toggle AD samples, Control samples, or both. The selected values are passed to make_heatmap_df() as the 'conditions' argument, which filters the expression matrix columns.
    checkboxGroupInput(
      inputId = "conditions_t2",
      label = "Conditions to include:",
      choices = c("AD", "Control"),
      selected = c("AD", "Control") # both selected by default
    )
  ),
  card(
    card_header("Heatmap of Top Differentially Expressed Genes"),
    card_body(plotOutput("heatmap", height = "600px")),
    full_screen = TRUE
  )
)