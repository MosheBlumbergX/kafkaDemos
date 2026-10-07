#!/bin/bash

echo "🚀 Starting Kafka Azure Blob CSV Connector Demo..."

# The storage account name and key / SAS token are read from the environment (or a
# git-ignored .env file) so they never end up in connector-config.json or in git.
if [ -f .env ]; then
  set -a; source .env; set +a
fi
if [ -z "$AZURE_STORAGE_ACCOUNT" ] || { [ -z "$AZURE_STORAGE_KEY" ] && [ -z "$AZURE_STORAGE_SAS_TOKEN" ]; }; then
  echo "❌ Set AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_KEY or AZURE_STORAGE_SAS_TOKEN (in your shell or in .env) before running this script."
  echo "   export AZURE_STORAGE_ACCOUNT=<storage account name>"
  echo "   export AZURE_STORAGE_KEY=<storage account key>"
  echo "   # or: export AZURE_STORAGE_SAS_TOKEN='<SAS token with Read + List on csv-data>'"
  exit 1
fi

# Start services
echo "1. Starting Docker containers..."
docker compose up -d

echo "2. Waiting for Kafka Connect to be ready..."
for i in {1..60}; do
  if curl -s http://localhost:8083/connector-plugins | grep -q AzureBlobStorageSourceConnector; then
    echo "✅ Kafka Connect is ready!"
    break
  fi
  echo "   Waiting... ($i/60)"
  sleep 3
done

# Create connector, injecting the Azure credentials from the environment
echo "3. Creating Azure Blob Storage Source Connector..."
CONFIG=$(jq \
  --arg account "$AZURE_STORAGE_ACCOUNT" \
  --arg key "${AZURE_STORAGE_KEY:-}" \
  --arg sas "${AZURE_STORAGE_SAS_TOKEN:-}" '
  .config["azblob.account.name"] = $account
  | if $key != "" then .config["azblob.account.key"] = $key
    else .config["azblob.sas.token"] = $sas end
  | .config' connector-config.json)
# PUT creates the connector, or updates it in place if it already exists
curl -s -X PUT http://localhost:8083/connectors/azure-blob-csv-connector/config \
  -H "Content-Type: application/json" \
  -d "$CONFIG" > /dev/null

sleep 5
curl -s http://localhost:8083/connectors/azure-blob-csv-connector/status | jq -c '{connector: .connector.state, tasks: [.tasks[].state]}'

echo ""
echo "✅ Demo setup complete!"
echo ""
echo "The connector routes CSV blobs by folder:"
echo "   csv-data/input/employees/*.csv -> employee-data"
echo "   csv-data/input/new_hires/*.csv -> new-hires"
echo ""
echo "📊 View messages at: http://localhost:8080"
echo "   Navigate to: Topics → employee-data"
echo ""
echo "🔍 Or use console consumer:"
echo "   docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic employee-data --from-beginning"
echo ""
echo "📤 Upload more files with: ./upload-csv.sh <file.csv>"
echo ""
