#!/bin/bash
# Upload a CSV file to the Azure Blob container the connector is watching.
# Usage: ./upload-csv.sh [file.csv] [folder]
#   file.csv  defaults to sample_data.csv
#   folder    sub-folder under input/ that decides the topic (see topic.regex.list):
#             employees -> employee-data (default), new_hires -> new-hires
# Uses AZURE_STORAGE_ACCOUNT plus AZURE_STORAGE_KEY or AZURE_STORAGE_SAS_TOKEN
# (the SAS token needs Write permission for uploads).

FILE=${1:-sample_data.csv}
FOLDER=${2:-employees}
CONTAINER=csv-data
BLOB_NAME="input/$FOLDER/$(basename "${FILE%.csv}")_$(date +%s).csv"

if [ -f .env ]; then
  set -a; source .env; set +a
fi
if [ -z "$AZURE_STORAGE_ACCOUNT" ]; then
  echo "❌ Set AZURE_STORAGE_ACCOUNT (in your shell or in .env) before running this script."
  exit 1
fi

docker compose run --rm -T azure-cli az storage blob upload \
  --only-show-errors \
  --container-name "$CONTAINER" \
  --file "$FILE" \
  --name "$BLOB_NAME" > /dev/null && echo "📤 Uploaded $FILE to $CONTAINER/$BLOB_NAME"
