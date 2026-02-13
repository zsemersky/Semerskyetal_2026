#!/usr/bin/env Rscript

#filter_HK_motif.R

# This file takes in an alignment (FASTA FORMAT). By providing the known
# character positions of NphT H144 and K200 in the alignment, it extracts the 
# UniProt accession numbers of additional sequences containing the 
# histidine/lysine motif.

suppressPackageStartupMessages({
  library(Biostrings)
})

# Parsing command line arguments ####

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 6) {
  stop("Script usage: Rscript filter_HK_motif.R <inputMSA.fasta> 
  <ref_protein_name> <Hpos> <Kpos> <output.fasta> <output.txt>\n
  Example: Rscript filter_HK_motif.R data/AKR_Fig6_MSA.fasta a0a917nhy8 144 200\n
  or\n
  chmod +x scripts/filter_HK_motif.R\n
  ./scripts/filter_HK_motif.R <inputMSA.fasta> <ref_protein_name> <Hpos> 
       <Kpos> <output.fasta> <output.txt>")
}

input_fasta  <- args[1]
ref_name     <- args[2]
Hpos         <- as.integer(args[3])
Kpos         <- as.integer(args[4])
output_fasta <- args[5]
output_txt   <- args[6]

if (!file.exists(input_fasta)) {
  stop("Input file does not exist: ", input_fasta)
}

message("Loading MSA: ", input_fasta)


# Load aligned FASTA ####
fasta <- readAAStringSet(input_fasta)

# Convert to character matrix 
seq_matrix <- as.matrix(fasta)  

# Find reference sequence ####
# Not case-sensitive, allows for partial match
ref_idx <- grep(ref_name, names(fasta), ignore.case = TRUE, fixed = TRUE)

if (length(ref_idx) == 0) {
  stop("Reference protein not found in MSA: ", ref_name)
} else if (length(ref_idx) > 1) {
  warning("Multiple sequences matched the reference name. Using the first match.")
}

ref_seq <- fasta[[ref_idx[1]]]

# Map HK positions relative to reference protein sequence ####

ref_chars <- as.character(ref_seq)
msa_col_H <- which(cumsum(ref_chars != "-") == Hpos) #disregards -
msa_col_K <- which(cumsum(ref_chars != "-") == Kpos) #disregards -

# Verify residues in reference sequence
if (ref_chars[msa_col_H] != "H") stop("Reference residue at H position is not H")
if (ref_chars[msa_col_K] != "K") stop("Reference residue at K position is not K")

message("Mapped H position to MSA column: ", msa_col_H)
message("Mapped K position to MSA column: ", msa_col_K)


# Filter sequences by HK motif ####
# these are the locations of H and K of histidine/lysine motif in the MSA,
# but can alter numeric positions based on custom MSA input and reference protein
matching_seqs <- fasta[which(seq_matrix[, msa_col_H] == "H" & seq_matrix[, msa_col_K] == "K")]

# Save output ####
# Save output list of Uniprot accessions with histidine/lysine motif
# note: this list can be used as a selection input in Cytoscape
writeXStringSet(matching_seqs, filepath = output_fasta)
accessions <- sub("^[^|]*\\|[^|]*\\|([^_]*)_.*", "\\1", names(matching_seqs)) 

# Save output ####
writeLines(accessions, output_txt) # used to isolate accession number

message("Filtered sequences with HK motif saved to: ", output_fasta)
message("List of proteins with HK motif saved to: ", output_txt)