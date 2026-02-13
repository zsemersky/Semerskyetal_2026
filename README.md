# Semerskyetal_2026
Supplementary Code as indicated in the Semersky et al. 2026 manuscript. 

## System requirements
#### Operating system
Tested on:
- MacOS Tahoe 26.2

#### Software Requirements
- R (tested with version 4.5.2)
- R packages in scripts/`install_packages.R`
- Internet connection required for `refine_metal_pdb.R`(UniProt API queries)

## Installation guide
Download this repository as a zip file. On Mac, open 

Run all commands through Terminal (Mac/Linux) or Command Prompt (Windows). 
1. Navigate to your desired file destination

Example (Mac/Linux):
```
cd ~/Downloads
```
Example (Windows):
```
cd Downloads
```
2. With Git installed, clone this repository in your desired file location and navigate into the project directory
```
git clone https://github.com/zsemersky/Semerskyetal_2026.git
cd Semerskyetal_2026
```
3. Verify R installation, and download if not installed
```
R --version
```
4. Install required packages while within project directory
```
Rscript scripts/install_packages.R
```
Typical installation time is no more than a few minutes.

## Demos
There are 4 separate scripts. Each demo uses manuscript data for reproducibility.
For all demos, navigate into the main project directory
```
cd Semerskyetal_2026
```
### Supplementary Code 1 (`filter_larC_SSN.R`)
_R script for the bioinformatic identification of nickel pincer enzymes
to keep LarC accessions containing LarB and LarE and removing genomes containing LarA_

This script processes a genome neighborhood diagram (.sqlite file) with larC as the anchor gene, isolating larC accessions whose neighboring genes include larB and larE but exclude larA.

Run the following:
```
Rscript scripts/filter_larC_SSN.R data/LarC_SSN.sqlite demo1_output.xlsx
```
alternatively, use
```
chmod +x scripts/filter_larC_SSN.R
./scripts/filter_larC_SSN.R data/LarC_SSN.sqlite demo1_output.xlsx
```
### Supplementary Code 2 (`pfam_occurrence.R`)
_R script for profiling Pfam occurrences_

This script processes a genome neighborhood diagram (.sqlite file) generated with larC as the anchor gene where larBE but not larA are present among the surrounding genes. It generates a table of Pfam occurrences for all neighboring genes of the larC anchor.
