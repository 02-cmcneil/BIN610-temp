# Re-executes any time analysis$ready, input$num_genes_t3, or df$de_df changes.
output$top_genes_gt <- gt::render_gt({
  req(analysis$ready) # halt until CSVs are loaded
  
  # Build and return the formatted gt table, using the numeric input to control how many rows to show
  make_gt_table(
    de_df = df$de_df,
    num_genes = input$num_genes_t3
  )
})