# Kafka Demos

A collection of Kafka demonstration projects and examples.

## Demos

### [csv-spooldir-connector](./csv-spooldir-connector/)
A Docker-based demo showing how to use Kafka Connect with the Spooldir connector to automatically read CSV files and publish them as JSON messages to Kafka topics.

**Features:**
- Kafka 7.7.1 (KRaft mode - no Zookeeper)
- Spooldir CSV Source Connector
- Kafka UI for monitoring
- Automatic CSV to JSON transformation

**Quick Start:**
```bash
cd csv-spooldir-connector
./start-demo.sh
```

---

### [azure-blob-csv-connector](./azure-blob-csv-connector/)
The same CSV-to-Kafka flow, but the files are read from Azure Blob Storage instead of a local directory, using Confluent's Azure Blob Storage Source connector. Files are routed to different topics based on their folder in the container.

**Features:**
- Kafka 8.3.2 (KRaft mode - no Zookeeper)
- Kafka Connect on `cp-server-connect` 8.3.2 (needed for the commercial connector's licensing; 30-day trial without a license key)
- Confluent Azure Blob Storage Source Connector (GENERIC mode, CSV format)
- Topic routing by folder: `input/employees/` → `employee-data`, `input/new_hires/` → `new-hires`
- Credentials loaded from a git-ignored `.env` file (`AZURE_STORAGE_ACCOUNT` + `AZURE_STORAGE_KEY` or `AZURE_STORAGE_SAS_TOKEN`)
- `upload-csv.sh` helper to push CSV files to the container
- Kafka UI for monitoring

**Quick Start:**
```bash
cd azure-blob-csv-connector
# create .env with your Azure storage credentials first (see the demo README)
./start-demo.sh
./upload-csv.sh new_hires.csv new_hires
```

---

## Requirements

- Docker
- Docker Compose

## Contributing

Feel free to add more Kafka demos and examples to this repository.
