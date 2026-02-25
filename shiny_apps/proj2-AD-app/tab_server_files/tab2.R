# Re-executes any time analysis$ready, input$num_genes_t2, input$conditions_t2, or the underlying df$de_df / df$expr_df change.
output$heatmap <- renderPlot({
  req(analysis$ready) # halt until CSVs are loaded
  req(length(input$conditions_t2) > 0) # halt if the user has unchecked all conditions
  
  # Build the z-score normalized long dataframe for plotting, using the numeric input for gene count and the checkbox values for conditions
  heatmap_df <- make_heatmap_df(
    de_df = df$de_df,
    expr_df = df$expr_df,
    num_genes = input$num_genes_t2,
    conditions = input$conditions_t2
  )
  
  # Pass the prepared dataframe to the heatmap plot function
  make_heatmap(heatmap_df)
})