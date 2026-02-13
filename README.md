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
For all demos, navigate into the main project directory.
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
The output is a .xlsx sheet containing relevent information for each LarC UniProt accession whose surrounding genes include larB and larE but exclude larA.

### Supplementary Code 2 (`pfam_occurrence.R`)
_R script for profiling Pfam occurrences_

This script processes a genome neighborhood diagram (.sqlite file) generated with larC as the anchor gene where larBE but not larA are present among the surrounding genes. It generates a table of Pfam occurrences for all neighboring genes of the larC anchor.

Run the following:
```
Rscript scripts/pfam_occurrence.R data/LarC_SSN_larBCEnoA.sqlite demo2_output.xlsx
```
alternatively, use
```
chmod +x scripts/pfam_occurrence.R
./scripts/pfam_occurrence.R data/LarC_SSN_larBCEnoA.sqlite output2.xlsx
```
The output is a .xlsx workbook with two tabs, one has the counts of all pfam occurrences from the .sqlite input file, and the the other tab is the same but excludes occurrences of larBCE.

### Supplementary Code 3 (`filter_HK_motif.R`)
_R script for annotation of AKRs containing the histidine/lysine motif_

This file takes in an alignment (FASTA FORMAT). By providing the known character positions of NphT H144 and K200 in the alignment, it extracts the UniProt accession numbers of additional sequences containing the histidine/lysine motif.

Run the following:
```
Rscript scripts/filter_HK_motif.R data/AKR_Fig6_MSA.fasta a0a917nhy8 144 200 output3.fasta output3_accessions.txt
```
alternatively, use
```
chmod +x scripts/filter_HK_motif.R
./scripts/filter_HK_motif.R data/AKR_Fig6_MSA.fasta a0a917nhy8 144 200 demo3_output.fasta demo3_output.txt
```
The output contains two files. One is a refined MSA in .fasta format containing enzymes with the HK motif, and the other is a basic list of protein names (in this case, UniProt accession numbers) of enzymes with the HK motif.

### Supplementary Code 4 (`refine_metal_pdb.R`)
_R script for counting iron and nickel enzymes_

This file takes the spreadsheet of PDB entries containing iron or nickel (.xlsx format) and refines it to retain entries whose corresponding UniProt entry includes the keyword “nickel” or “iron” in the ligand section, also removing duplicate EC numbers to ensure functionally distinct enzymes are counted only once

**NOTE: this script takes 15-20 minutes to run on a MacBook pro with 48 GB of RAM. The bottleneck here is UniProt API requests.**

Run the following:
```
Rscript scripts/refine_metal_pdb.R data/Fe_Ni_Enzyme_Master_List.xlsx demo4_output.xlsx
```
alternatively, use
```
chmod +x scripts/refine_metal_pdb.R
./scripts/efine_metal_pdb.R data/Fe_Ni_Enzyme_Master_List.xlsx demo4_output.xlsx
```
The output is a .xlsx workbook with two tabs, one for Ni enzymes and one for Fe enzymes.

## Instructions for use on your own data
The general format of each script is listed below. Executable format can also be used (see demos). Input files much match the expected format of the demo files.
Required columns for input.xlsx for `refine_metal_pdb.R`:
- Metal
- Uniprot
- EC_numbers
For `filter_HK_motif.R`:
- Input must be in FASTA format
- All sequences must be aligned

### Supplementary Code 1 (`filter_larC_SSN.R`)
A .sqlite file generated from EFI-GND is required for input.
```
Rscript scripts/pfam_occurrence.R <input.sqlite> <output.xlsx>
```
### Supplementary Code 2 (`pfam_occurrence.R`)
A .sqlite file generated from EFI-GND is required for input.
```
Rscript scripts/pfam_occurrence.R <input.sqlite> <output.xlsx>
```
### Supplementary Code 3 (`filter_HK_motif.R`)
A multiple sequence alignment in .fasta format is required for input.
```
Rscript scripts/filter_HK_motif.R <inputMSA.fasta> <reference_protein_name> <H_position> <K_position> <output.fasta> <output.txt>
```
- `reference_protein_name` is the name of your desired protein to reference all other sequences to. It is not case sensitive and allows your input to be just part of the name after > in the fasta header.
- `H_position` is the amino acid number corresponding to the histidine in the HK motif. (i.e. in NphT, it is 144)
- `K_position` is the amino acid number corresponding to the lysine in the HK motif. (i.e. in NphT, it is 200)

### Supplementary Code 4 (`refine_metal_pdb.R`)
```
Rscript scripts/refine_metal_pdb.R <input.xlsx> <output.xlsx>
```
