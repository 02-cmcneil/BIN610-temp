# Re-executes any time analysis$ready, input$logfc_thresh, input$pval_thresh, or input$brain_region via df$de_df change.
output$volcano_plot <- renderPlot({
  req(analysis$ready) # halt rendering until both CSVs are loaded
  
  # Build the annotated dataframe with the significance column, passing the current slider values as thresholds
  volcano_df <- make_volcano_df(
    de_df = df$de_df,
    logfc_thresh = input$logfc_thresh,
    pval_thresh = input$pval_thresh
  )
  
  # Pass the annotated dataframe to the plot function
  make_volcano_plot(volcano_df)
})