layout_sidebar(
  sidebar = sidebar(
    width = 260,
    # sliderInput() for the log2 fold change threshold. Moving this slider changes which genes are colored Up or Down by updating input$logfc_thresh in the server.
    sliderInput(
      inputId = "logfc_thresh",
      label = "log2 Fold Change Threshold",
      min = 0,
      max = 3,
      value = 0.58, # 0.58 ≈ 1.5x fold change, a common default threshold
      step = 0.01
    ),
    # sliderInput() for the adjusted p-value threshold. Genes below this threshold (and above the FC threshold) are colored.
    sliderInput(
      inputId = "pval_thresh",
      label = "Adjusted P-Value Threshold",
      min = 0.001,
      max = 0.1,
      value = 0.05, # standard significance cutoff
      step = 0.001
    )
  ),
  # card() wraps the plot output in a styled panel. full_screen = TRUE adds an expand button to the card.
  card(
    card_header("Volcano Plot"),
    card_body(plotOutput("volcano_plot", height = "500px")),
    full_screen = TRUE
  )
)