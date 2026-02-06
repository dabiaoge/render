#!/usr/bin/awk -f
# Text Render by awk
# Version 1.0
# Author : dabioage
#Usage:  awk -F, -f render.awk template.txt var_list.csv

BEGIN { 
}
# -----------------------------------------------------------------------------
# Step 1: Read the template file (template.txt)
# NR == FNR indicates that the first file is being read.
# -----------------------------------------------------------------------------
NR == FNR {
    template = template $0 "\n"
    next
}

# -----------------------------------------------------------------------------
# Step 2: Process CSV file header (first line of var_list.csv)
# FNR == 1 indicates the first line of the current file.
# -----------------------------------------------------------------------------
FNR == 1 {
    # Record total column count for subsequent validation
    expected_cols = NF

    # Store headers in array 'h' for dynamic variable mapping
    for (i = 1; i <= NF; i++) {
        # Remove potential Windows carriage return characters
        gsub(/\r/, "", $i)
        h[i] = $i
    }
    next
}

# -----------------------------------------------------------------------------
# Step 3: Process CSV data lines
# -----------------------------------------------------------------------------
{
    # 1. Ignore empty lines
    if ($0 ~ /^[[:space:]]*$/) next

    # 2. Ignore lines with insufficient columns
    if (NF < expected_cols) next

    # Copy the template to prepare for substitution
    current_out = template

    # --- Process $0 (entire line content) ---
    val0 = $0
    # Escape '&' in content to prevent awk gsub misinterpretation
    gsub(/&/, "\\\\&", val0)
    gsub(/\$0/, val0, current_out)

    # --- Loop through every column ---
    for (i = 1; i <= NF; i++) {
        val = $i
        gsub(/\r/, "", val)     # Remove Windows carriage return
        gsub(/&/, "\\\\&", val) # Escape '&' symbol

        # 1. Replace column name variables (e.g., $product)
        # Use \> to match word boundaries, preventing $id from matching $idx
        pattern_name = "\\$" h[i] "\\>"
        gsub(pattern_name, val, current_out)

        # 2. Replace numeric index variables (e.g., $1, $2)
        pattern_index = "\\$" i "\\>"
        gsub(pattern_index, val, current_out)
    }

    # Output the processed text
    printf "%s", current_out
}
