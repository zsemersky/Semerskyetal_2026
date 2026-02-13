#!/usr/bin/env Rscript

#install_packages.R

# This script installs all required R packages for Semersky et al. 2026.
# Run from bash using:
# Rscript scripts/install_packages.R
# or
# chmod +x scripts/install_packages.R
# ./scripts/install_packages.R

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

installed <- rownames(installed.packages())

# Install CRAN packages
for (pkg in cran_packages) {
  if (!pkg %in% installed) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# Install BiocManager if needed
if (!"BiocManager" %in% installed) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

# Install Bioconductor packages
for (pkg in bioc_packages) {
  if (!pkg %in% installed) {
    BiocManager::install(pkg, ask = FALSE, update = FALSE)
  }
}

cat("All required packages are installed.")