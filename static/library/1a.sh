#!/bin/bash

# URL for Google Sheets download as XLSX
URL="https://docs.google.com/spreadsheets/d/13U87Sm6e6Fh1SWipl_y_Hi6r2zxfYLyTwjMMZoLjMl4/export?format=xlsx"

# Temporary and log files
TIMESTAMP=$(date +%s)
TEMP_XLSX="temp_$TIMESTAMP.xlsx"
DOWNLOAD_LOG="download_$TIMESTAMP.log"
TARGET_DIR="/var/www/html/current/static/library"  # Adjust the target directory if necessary

rm -r *.xlsx
# Download the XLSX file
echo "Attempting to download from $URL"
curl -f --location -v "$URL" -o "$TEMP_XLSX" 2>&1 | tee "$DOWNLOAD_LOG"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download XLSX. Check $DOWNLOAD_LOG for details."
    cat "$DOWNLOAD_LOG"
    exit 1
fi

# Verify the file extension
if [[ "$TEMP_XLSX" != *.xlsx ]]; then
    echo "Downloaded file does not have .xlsx extension. Please check the download URL or the file."
    exit 1
fi

# Ensure the file is readable and the target directory is writable
chmod +r "$TEMP_XLSX"

# Fix the permissions for the target directory (to ensure write access for JSON output)
chmod u+w "$TARGET_DIR"

# Optionally, you can change the ownership of the downloaded XLSX and target directory to your user (if needed):
# sudo chown $(whoami):$(whoami) "$TEMP_XLSX"
# sudo chown -R $(whoami):$(whoami) "$TARGET_DIR"

# Check if the target directory is writable for JSON output
if [ ! -w "$TARGET_DIR" ]; then
    echo "The target directory is not writable: $TARGET_DIR. Exiting."
    exit 1
fi

echo "Download completed: $TEMP_XLSX"

# Input file (passed as an argument to 2.sh)
INPUT_XLSX="$TEMP_XLSX"

# Ensure the input file is provided for processing
if [ -z "$INPUT_XLSX" ]; then
    echo "Usage: ./2.sh <input_xlsx_file>"
    exit 1
fi

# Check if the input file exists before processing
if [ ! -f "$INPUT_XLSX" ]; then
    echo "File $INPUT_XLSX does not exist."
    exit 1
fi

