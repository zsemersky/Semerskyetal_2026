#!/usr/bin/env Rscript

# pfam_occurrence.R

# This script processes a genome neighborhood diagram (.sqlite file) generated
# with larC as the anchor gene where larBE but not larA are present among the 
# surrounding genes. It generates a table of Pfam occurrences for all 
# neighboring genes of the larC anchor.

suppressPackageStartupMessages({
library(RSQLite)
library(DBI)
library(dplyr)
library(tidyr)
library(stringr)
library(openxlsx)
})

# Parsing command line arguments ####

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop("Script usage: pfam_occurrence.R <input.sqlite> <output.xlsx>\n
       or\n
       chmod +x scripts/pfam_occurrence.R\n
       ./scripts/pfam_occurrence.R <input.sqlite> <output.xlsx>")
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
# Create Pfam list ####

# New tibble that splits pfams from neighbors_tibble
all_pfams_bce <- neighbors_tibble %>%
  mutate(
    family = str_split(family, "-"),
    family_desc = str_split(family_desc, ";")
  ) %>%
  unnest(c(family, family_desc))

# Count number of unique families present in all_pfams_bce
unique_pfam_count_bce <- all_pfams_bce %>%
  summarise(unique_pfam_count_bce = n_distinct(family))
print(unique_pfam_count_bce)

# Make tibble with counts of each Pfam with description and sorts in descending order
# AKR superfamily is PF00248
pfam_counts_total_bce <- all_pfams_bce %>%
  count(family) %>%
  arrange(desc(n)) %>%
  left_join(
    all_pfams_bce %>% distinct(family, family_desc),
    by = "family"
  )

# From tibble of counts of each Pfam with description:
# removes LarE (PF02540), LarB (PF00731), LarC (PF01969), and Pfam of "none" and sorts in descending order
pfam_counts_exclude_bce <- pfam_counts_total_bce %>%
  filter(!family %in% c("PF02540", "PF00731", "PF01969", "none")) %>%
  arrange(desc(n))

# Save output ####
wb <- createWorkbook()

# Sheet 1: All PFAM
addWorksheet(wb,"All PFAM")
writeData(wb, sheet = "All PFAM", pfam_counts_total_bce)

# Sheet 2: LarBCE excluded
addWorksheet(wb,"LarBCE excluded")
writeData(wb, sheet = "LarBCE excluded", pfam_counts_exclude_bce)

# Save workbook
saveWorkbook(wb, file = output_file, overwrite = TRUE)
message("Writing output to: ", output_file)
