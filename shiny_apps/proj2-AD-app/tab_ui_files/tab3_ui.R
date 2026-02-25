layout_sidebar(
  sidebar = sidebar(
    width = 260,
    # numericInput() controls how many rows appear in the gt table. Passed to make_gt_table() as num_genes.
    numericInput(
      inputId = "num_genes_t3",
      label   = "Number of top genes to display:",
      value   = 10,
      min     = 1,
      max     = 50
    )
  ),
  card(
    card_header("Top Differentially Expressed Genes"),
    # gt_output() is the gt package's equivalent of plotOutput — it creates a placeholder that render_gt() fills in the server.
    card_body(gt::gt_output("top_genes_gt")),
    full_screen = TRUE
  )
)