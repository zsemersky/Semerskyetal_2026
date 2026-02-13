#!/usr/bin/env Rscript

#refine_metal_pdb.R

# This file takes the spreadsheet of PDB entries containing iron or nickel 
# (.xlsx format) and refines it to retain entries whose corresponding UniProt 
# entry includes the keyword “nickel” or “iron” in the ligand section, also 
# removing duplicate EC numbers to ensure functionally distinct enzymes are 
# counted only once.

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(httr)
  library(jsonlite)
  library(openxlsx)
})

# Parse command line arguments ####
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop(
    "Usage: Rscript scripts/refine_metal_pdb.R <input.xlsx> <output.xlsx>\n",
    "Example: Rscript scripts/refine_metal_pdb.R data/Fe_Ni_Enzyme_Master_List.xlsx Fe_Ni_Enzyme_refined_output.xlsx\n",
    "or\n",
    "chmod +x scripts/filter_HK_motif.R\n",
    "./scripts/refine_metal_pdb.R <input.xlsx> <output.xlsx>"
  )
}

input_file  <- args[1]
output_file <- args[2]

# Open excel file ####
MegaPDBmetals <- read_excel(input_file)

# First pass metal count ####
ni_entries <- MegaPDBmetals %>% filter(Metal == "NI")
fe_entries <- MegaPDBmetals %>% filter(Metal == "FE")

# Extract Uniprot entries with nickel or iron keyword ####

# Function: check if UniProt entry has the keyword "Nickel" in ligand section
has_nickel_keyword <- function(uniprot_id) {
  url <- paste0("https://rest.uniprot.org/uniprotkb/", uniprot_id, ".json")
  res <- GET(url)
  if (status_code(res) != 200) return(FALSE)
  
  data <- fromJSON(content(res, as = "text", encoding = "UTF-8"))
  
  if (!"keywords" %in% names(data)) return(FALSE)
  
  any(grepl("nickel", data$keywords$name, ignore.case = TRUE))
}

# Function: check if UniProt entry has the keyword "Iron" in ligand section
has_iron_keyword <- function(uniprot_id) {
  url <- paste0("https://rest.uniprot.org/uniprotkb/", uniprot_id, ".json")
  res <- GET(url)
  if (status_code(res) != 200) return(FALSE)
  
  data <- fromJSON(content(res, as = "text", encoding = "UTF-8"))
  
  if (!"keywords" %in% names(data)) return(FALSE)
  
  any(grepl("iron", data$keywords$name, ignore.case = TRUE))
}

# NICKEL: run has_nickel_keyword function and remove rows that have no EC number and duplicate ECs
ni_refined <- ni_entries %>%
  filter(sapply(Uniprot, has_nickel_keyword)) %>% 
  filter(!is.na(EC_numbers) & EC_numbers != "") %>%   # remove blank ECs
  separate_rows(EC_numbers, sep = ",\\s*") %>%        # split on comma
  filter(grepl("^\\d+\\.\\d+\\.\\d+\\.(\\d+|-)$", EC_numbers)) %>%  # keep x.x.x.x or x.x.x.- EC numbers
  distinct(EC_numbers, .keep_all = TRUE)              # remove duplicate ECs

# IRON: run has_iron_keyword function and remove rows that have no EC number and duplicate ECs
fe_refined <- fe_entries %>%
  filter(sapply(Uniprot, has_iron_keyword)) %>% 
  filter(!is.na(EC_numbers) & EC_numbers != "") %>%   # remove blank ECs
  separate_rows(EC_numbers, sep = ",\\s*") %>%        # split on comma
  filter(grepl("^\\d+\\.\\d+\\.\\d+\\.(\\d+|-)$", EC_numbers)) %>%  # keep x.x.x.x or x.x.x.- EC numbers
  distinct(EC_numbers, .keep_all = TRUE)              # remove duplicate ECs

# Save results as single workbook with multiple tabs ####
wb <- createWorkbook()

addWorksheet(wb, "Ni refined")
writeData(wb, "Ni refined", ni_refined)

addWorksheet(wb, "Fe refined")
writeData(wb, "Fe refined", fe_refined)

saveWorkbook(wb, output_file, overwrite = TRUE)

cat("Refined workbook saved to:", output_file, "\n")
