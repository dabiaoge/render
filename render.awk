#!/usr/bin/awk -f
# Text Render by awk
# Version 1.5
# Author : dabioage
# Usage:  awk -F, -f render.awk template.txt var_list.csv

BEGIN {
    if (ARGC < 2) {
        print "Error: Insufficient arguments." > "/dev/stderr"
        exit 1
    }
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
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
        headers[i] = $i
    }
    next
}

# -----------------------------------------------------------------------------
# Step 3: Process CSV data lines
# -----------------------------------------------------------------------------
{
    if ($0 ~ /^[[:space:]]*$/) next
    if (NF < expected_cols) next

    # Load data into a map for quick lookup
    delete vars
    for (i = 1; i <= NF; i++) {
        val = $i
        gsub(/\r/, "", val)
        vars[headers[i]] = val  # Store by name: vars["product"]
        vars[i] = val           # Store by index: vars["2"]
    }
    vars["0"] = $0

    line = template
    result = ""

    # -------------------------------------------------------------------------
    # The "Magic" Logic: 
    # Instead of gsub, we scan the string from left to right.
    # We look for the NEXT occurrence of a $ sign.
    # -------------------------------------------------------------------------
    while (match(line, /\$(\{[a-zA-Z0-9_]+\}|[0-9]+|[a-zA-Z0-9_]+)/)) {
        # 1. Append everything BEFORE the match to the result
        result = result substr(line, 1, RSTART - 1)
        
        # 2. Extract the full tag (e.g., "${expiration}" or "$2" or "$no")
        full_tag = substr(line, RSTART, RLENGTH)
        
        # 3. Determine the key inside the tag
        key = full_tag
        sub(/^\$/, "", key)      # Remove leading $
        sub(/^\{/, "", key)      # Remove leading { if exists
        sub(/\}$/, "", key)      # Remove trailing } if exists

        # 4. Replace if key exists in our vars map, otherwise keep original tag
        if (key in vars) {
            replacement = vars[key]
            # Escape ampersand for the final output safety if needed, 
            # but since we aren't using gsub here, literal is fine.
            result = result replacement
        } else {
            result = result full_tag
        }

        # 5. Move the pointer forward
        line = substr(line, RSTART + RLENGTH)
    }
    
    # Append the remaining part of the line
    result = result line
    printf "%s", result
}
