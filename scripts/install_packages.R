#!/usr/bin/env Rscript

#install_packages.R

# This script installs all required R packages for Semersky et al. 2026.
# Run from bash using:
# Rscript scripts/install_packages.R
# or
# chmod +x scripts/install_packages.R
# ./scripts/install_packages.R

# CRAN and Bioconductor packages ####
cran_packages <- c(
  "RSQLite",
  "DBI",
  "dplyr",
  "tidyr",
  "stringr",
  "openxlsx",
  "tidyverse",
  "readxl",
  "httr",
  "jsonlite"
)

bioc_packages <- c(
  "Biostrings"
)

# ----------------------------
# Installed packages
# ----------------------------
installed <- rownames(installed.packages())

# ----------------------------
# Install CRAN packages if missing
# ----------------------------
for (pkg in cran_packages) {
  if (!pkg %in% installed) {
    message("Installing CRAN package: ", pkg)
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}


# Install BiocManager if missing ####
if (!"BiocManager" %in% installed) {
  message("Installing BiocManager...")
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

# Install Bioconductor packages if missing ####
for (pkg in bioc_packages) {
  if (!pkg %in% installed) {
    message("Installing Bioconductor package: ", pkg)
    BiocManager::install(pkg, ask = FALSE, update = FALSE)
  }
}

# Load all required packages ####
suppressPackageStartupMessages({
  for (pkg in c(cran_packages, bioc_packages)) {
    library(pkg, character.only = TRUE)
  }
})

message("All required packages installed and loaded.")