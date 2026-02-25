library(tidyverse)
library(gt)

# Each function is called from the tab server files

# make_volcano_df()
# Takes the DE results dataframe and the two threshold values from the sliders, and adds a 'significance' column that categorizes each gene as Up, Down, or NS (not significant). This column is what controls the color of each point in the volcano plot.
make_volcano_df <- function(de_df, logfc_thresh, pval_thresh) {
  de_df %>%
    mutate(
      significance = case_when(
        # Upregulated: significant p-value AND fold change above positive threshold
        adj_p_value < pval_thresh & log2_fold_change >  logfc_thresh ~ "Up",
        # Downregulated: significant p-value AND fold change below negative threshold
        adj_p_value < pval_thresh & log2_fold_change < -logfc_thresh ~ "Down",
        # Everything else is not significant
        TRUE                                                          ~ "NS"
      )
    )
}

# make_volcano_plot()
# Builds the ggplot2 volcano plot from the annotated dataframe returned by make_volcano_df(). Uses coord_cartesian() to clip the x-axis to the 1st-99th percentile of fold change values, which prevents a small number of extreme outlier probes from stretching the axis and compressing the plot. coord_cartesian() clips the view without removing any data, so significance coloring is unaffected.

make_volcano_plot <- function(volcano_df) {
  # Compute x-axis limits from the data itself so they stay appropriate regardless of which brain region is selected
  x_limits <- quantile(volcano_df$log2_fold_change, probs = c(0.01, 0.99), na.rm = TRUE)
  
  ggplot(
    data = volcano_df,
    aes(x = log2_fold_change, y = -log10(adj_p_value), color = significance)
  ) +
    geom_point(alpha = 0.5, size = 1.2) +
    # Manually assign colors to each significance category
    scale_color_manual(
      values = c("Up" = "firebrick", "Down" = "steelblue", "NS" = "grey60")
    ) +
    # Clip the x-axis window without dropping any points from the data
    coord_cartesian(xlim = x_limits) +
    labs(
      x = "log2 Fold Change",
      y = "-log10(Adjusted P-Value)",
      color = "Significance"
    ) +
    theme_bw() +
    theme(
      legend.position = "top",
      legend.title = element_text(face = "bold")
    )
}


# make_heatmap_df()
# Prepares the plotting dataframe for the heatmap. Steps:
# 1. Pull the top N most significant genes from the DE data
# 2. Filter the expression matrix to only those genes and the sample columns matching the selected conditions
# 3. Z-score normalize each gene's expression across samples using the same pivot_longer/pivot_wider/scale approach from the heatmap example
# 4. Re-attach adj_p_value so genes can be ordered by it

make_heatmap_df <- function(de_df, expr_df, num_genes, conditions) {
  
  # Step 1: Get the top N gene symbols ranked by adjusted p-value
  top_genes <- de_df %>%
    filter(adj_p_value < 0.05) %>% # keep only significant genes
    arrange(adj_p_value) %>% # sort most significant first
    slice(1:num_genes) %>% # take the top N rows
    pull(gene_symbol) # extract just the gene name vector
  
  # Step 2: Identify sample columns that match the selected conditions.
  # Column names in the expression file are prefixed "AD_" or "Control_", so we use str_detect() to keep only the ones the user selected.
  all_sample_cols <- names(expr_df %>% select(-gene_symbol))
  keep_cols <- all_sample_cols[
    str_detect(all_sample_cols, paste0("^(", paste(conditions, collapse = "|"), ")_"))
  ]
  
  # Step 3 & 4: Z-score normalize and reshape for ggplot.
  # The pivot strategy mirrors the course heatmap example:
  # - pivot_longer: collapse sample columns into rows
  # - pivot_wider:  make genes into columns (one per gene)
  # - scale():      z-score normalize each gene column
  # - pivot_longer: return to long format for ggplot
  expr_df %>%
    filter(gene_symbol %in% top_genes) %>% # keep only top genes
    select(gene_symbol, all_of(keep_cols)) %>% # keep only selected samples
    pivot_longer(cols = -gene_symbol,
                 names_to = "sample",
                 values_to = "counts") %>% # long: one row per gene-sample pair
    pivot_wider(names_from = gene_symbol,
                values_from = counts) %>% # wide: one column per gene
    mutate(across(-sample, scale)) %>% # z-score each gene column
    as.data.frame() %>%
    pivot_longer(cols = -sample,
                 names_to = "gene_symbol",
                 values_to = "z_score") %>% # back to long for ggplot
    mutate(condition = str_extract(sample, "^[^_]+")) %>% # extract "AD" or "Control" from sample name
    inner_join(de_df %>% select(gene_symbol, adj_p_value),
               by = "gene_symbol") %>% # re-attach p-value for ordering
    mutate(gene_symbol = fct_reorder(gene_symbol, -adj_p_value)) # order genes by significance
}

# make_heatmap()
# Builds the ggplot2 tile heatmap from the normalized dataframe returned by make_heatmap_df(). Genes are on the y-axis, samples on the x-axis, and fill color represents the z-score. facet_grid() splits samples into AD vs Control panels side by side.

make_heatmap <- function(heatmap_df) {
  ggplot(
    data = heatmap_df,
    aes(x = sample, y = gene_symbol, fill = z_score)
  ) +
    geom_tile() +
    # Diverging color scale: blue = low expression, red = high expression
    scale_fill_gradient2(
      low = "steelblue",
      mid = "white",
      high = "firebrick",
      midpoint = 0,
      limits = c(-2.5, 2.5), # fix scale across all regions for consistency
      oob = scales::squish # squish values outside limits rather than showing NA
    ) +
    scale_y_discrete(position = "right") + # gene labels on the right side
    # Split into AD and Control panels; free_x allows each panel its own width
    facet_grid(~ condition, scales = "free_x", space = "free_x") +
    labs(x = "Sample", y = "Gene Symbol", fill = "Z-Score") +
    theme_bw() +
    theme(
      axis.text.x = element_blank(), # hide individual sample names (too many to display)
      axis.ticks.x = element_blank(),
      legend.position = "top",
      legend.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold") # bold the AD / Control facet labels
    )
}

# make_gt_table()
# Builds a formatted gt table of the top N differentially expressed genes, filtered to those that are both statistically significant (adj_p_value < 0.05) and biologically meaningful (|log2FC| > 0.58, i.e. ~1.5x change).

make_gt_table <- function(de_df, num_genes) {
  de_df %>%
    filter(adj_p_value < 0.05, abs(log2_fold_change) > 0.58) %>%  # significant + meaningful FC
    arrange(adj_p_value) %>% # sort most significant first
    slice(1:num_genes) %>% # take top N
    select(gene_symbol, log2_fold_change, avg_expression, t_statistic, adj_p_value) %>%
    gt() %>%
    tab_header(
      title    = "Top Differentially Expressed Genes",
      subtitle = paste("Showing top", num_genes, "genes by adjusted p-value")
    ) %>%
    fmt_scientific(columns = adj_p_value, decimals = 2) %>%  # scientific notation for small p-values
    fmt_number(columns = c(log2_fold_change, avg_expression, t_statistic), decimals = 3) %>%
    # Color the log2FC column on a blue-white-red scale to show direction
    data_color(
      columns = log2_fold_change,
      method  = "numeric",
      palette = c("steelblue", "white", "firebrick")
    ) %>%
    # Rename columns to cleaner display labels
    cols_label(
      gene_symbol = "Gene",
      log2_fold_change = "log2FC",
      avg_expression = "Avg. Expr.",
      t_statistic = "T-Statistic",
      adj_p_value = "Adj. P-Value"
    ) %>%
    tab_options(table.width = pct(100)) # stretch table to full card width
}