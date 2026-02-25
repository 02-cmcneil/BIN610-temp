# Quick Reference

This Shiny app allows the user to explore differential gene expression results from Alzheimer's disease vs. control postmortem brain tissue (GSE48350) across four brain regions. Using a persistent sidebar, the user selects a brain region to load; all three tabs update accordingly. The tabs provide a volcano plot, a z-score heatmap, and a formatted summary table of top differentially expressed genes.

[Shiny Gallery for Quick Reference](https://shiny.posit.co/r/gallery/)

### Layout description
This app uses `bslib` for layout. A global sidebar (always visible) holds the brain region selector. The main area contains three tabs built with `navset_tab`, each with its own secondary sidebar for tab-specific controls:

* **Tab 1 (Volcano Plot):** User adjusts logFC and adjusted p-value thresholds via sliders; the volcano plot updates to color-code significant genes accordingly.
* **Tab 2 (Heatmap):** User selects the number of top genes and which conditions (AD, Control, or both) to display; the heatmap updates to show z-score normalized expression.
* **Tab 3 (Top Genes Table):** User selects the number of top genes (by adjusted p-value) to display in a formatted `gt` table.

### Inputs
The bullets below take the general form:

> shiny Component  |  **variable_name** | optional: args

* APP | selectInput | **brain_region** | choices: hippocampus, entorhinal_cortex, postcentral_gyrus, superior_frontal_gyrus
* TAB1 | sliderInput | **logfc_thresh** | min = 0, max = 3, value = 0.58, step = 0.01
* TAB1 | sliderInput | **pval_thresh** | min = 0.001, max = 0.1, value = 0.05, step = 0.001
* TAB2 | numericInput | **num_genes_t2** | value = 20, min = 2, max = 50
* TAB2 | checkboxGroupInput | **conditions_t2** | choices: AD, Control; selected: both
* TAB3 | numericInput | **num_genes_t3** | value = 10, min = 1, max = 50

### Outputs
The bullets below take the general form:

> Shiny Component  |  **variable_name**  | (inputs required)  | optional: function used

* TAB1 | plotOutput | **volcano_plot** | make_volcano_plot()
* TAB2 | plotOutput | **heatmap** | make_heatmap()
* TAB3 | gt::gt_output | **top_genes_gt** | make_gt_table()

### Reactive components and Server

> component type | **variable_name(s)** | Events that trigger 

* APP | reactiveValues() | **df$de_df** | input$brain_region | dataframe
* APP | reactiveValues() | **df$expr_df** | input$brain_region | dataframe
* APP | reactiveValues() | **analysis$ready** | input$brain_region | logical


### Functions and Set up

> **function_name**  |  (inputs)  | purpose

* **make_volcano_df** | (de_df, logfc_thresh, pval_thresh) | adds a significance category column (Up / Down / NS) for plot coloring
* **make_volcano_plot** | (volcano_df) | builds the ggplot2 volcano plot
* **make_heatmap_df** | (de_df, expr_df, num_genes, conditions) | filters to top genes, selects condition columns, z-score normalizes per gene using the same pivot approach as the heatmap example
* **make_heatmap** | (heatmap_df) | builds the ggplot2 tile heatmap with condition facets
* **make_gt_table** | (de_df, num_genes) | returns a formatted gt table of the top n significant genes