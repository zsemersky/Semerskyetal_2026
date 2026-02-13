#!/usr/bin/env Rscript

# filter_larC_SSN.R
# This script processes a genome neighborhood diagram (.sqlite file)
# with larC as the anchor gene, isolating larC accessions whose neighboring 
# genes include larB and larE but exclude larA.

suppressPackageStartupMessages({
  library(RSQLite)
  library(DBI)
  library(dplyr)
  library(stringr)
  library(openxlsx)
})

# ----------------------------
# Argument parsing
# ----------------------------

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Usage: Rscript filter_larC_neighborhood.R <input.sqlite> <output.xlsx>")
}

input_sqlite <- args[1]
output_file  <- args[2]

if (!file.exists(input_sqlite)) {
  stop("Input file does not exist: ", input_sqlite)
}

message("Opening database: ", input_sqlite)


# Extract data from .sqlite file ####

# Open .sqlite file from a given genome neighborhood diagram
con <- dbConnect(SQLite(), input_sqlite)

# List tables in the database
tables <- dbListTables(con)

# Extract tables from .sqlite
# neighbors and attributes are our primary ones of interest
required_tables <- c("neighbors", "attributes")

missing_tables <- setdiff(required_tables, tables)

if (length(missing_tables) > 0) {
  stop("Missing required tables: ", paste(missing_tables, collapse = ", "))
}

# Retrieve table data as tibbles
neighbors_tibble  <- dbGetQuery(con, "SELECT * FROM neighbors") %>% as_tibble()
attributes_tibble <- dbGetQuery(con, "SELECT * FROM attributes") %>% as_tibble()

dbDisconnect(con)

# Create larBCE no larA UniProt accession list by filtering ####
# this is for larC as anchor

# Filter 'neighbors_tibble' to include anything with larB, larE, larA 
filtered_neighbors <- neighbors_tibble %>%
  filter(
    str_detect(family_desc, regex("larB|larE|larA", ignore_case = TRUE)) |
      str_detect(ipro_family_desc, regex("larB|larE|larA", ignore_case = TRUE))
  )

# Create new tibble to remove 'gene_key' entries in filtered_neighbors where larA is found
filtered_out_larA <- neighbors_tibble %>%
  filter(
    str_detect(family_desc, regex("larA", ignore_case = TRUE)) |
      str_detect(ipro_family_desc, regex("larA", ignore_case = TRUE))
  )

# Remove rows in filtered_neighbors that have 'gene_key' values present in filtered_out_larA
filtered_neighbors_noA <- filtered_neighbors %>%
  anti_join(filtered_out_larA, by = "gene_key")

# Count the occurrences of each 'gene_key' in filtered_neighbors_noA
# and filter to only include counts greater than or equal to 2
# b/c we want both larB and larE to be present
filtered_neighbors_noA_counts <- filtered_neighbors_noA %>%
  count(gene_key) %>%
  filter(n >= 2)

# Filter 'filtered_attributes' based on 'sort_key' presence and occurrence count
# This will contain final list of LarC accessions to put into EFI-EST
filtered_attributes <- attributes_tibble %>%
  semi_join(filtered_neighbors_noA_counts,
            by = c("sort_key" = "gene_key"))

# Save output ####

message("Writing output to: ", output_file)
write.xlsx(filtered_attributes, file = output_file)

message("Done.")
