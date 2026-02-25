library(quarto)

# Get list of all RNAseq CSV files in the data folder
data_files <- list.files("data", pattern = "RNAseq.*\\.csv", full.names = TRUE)

# Create reports folder if it doesn't exist
if (!dir.exists("reports")) {
  dir.create("reports")
}

# Loop through each data file
for (i in 1:length(data_files)) {
  # Get the current data file path
  current_file <- data_files[i]
  
  # Extract filename for creating output name
  filename <- basename(current_file)
  # Create output filename (replace .csv with .html)
  output_name <- sub("\\.csv$", ".html", filename)
  
  # Render the report with the data_path parameter
  quarto_render(
    "report.qmd",
    execute_params = list(data_path = current_file),
    output_file = output_name
  )
  
  # Move output file to reports folder
  file.rename(from = output_name,
              to = paste0("./reports/", output_name))
}
