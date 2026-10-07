# Kafka Azure Blob CSV Connector Demo

The same idea as the [csv-spooldir-connector](../csv-spooldir-connector/) demo, but the CSV files live in **Azure Blob Storage** instead of on the Kafka Connect worker's disk. Confluent's Azure Blob Storage Source connector reads them and publishes each row to Kafka as JSON.

## Architecture

- **Kafka 8.3.2** (KRaft mode - no Zookeeper needed)
- **Kafka Connect** (`cp-server-connect` 8.3.2) with the [Confluent Azure Blob Storage Source Connector](https://docs.confluent.io/kafka-connectors/azure-blob-storage-source/current/overview.html) in `GENERIC` mode
- **Azure Blob Storage** container `csv-data` in your storage account, files under `input/<folder>/`
- **Kafka UI** for monitoring topics and messages

> The connector is a Confluent commercial connector. Without a `confluent.license` it runs on a 30-day trial.
> It needs the `cp-server-connect` image: the community `cp-kafka-connect` image doesn't provide the licensing classes it depends on.

## Credentials

Put the storage account credentials in a `.env` file next to `docker-compose.yml` (it is git-ignored):

```bash
AZURE_STORAGE_ACCOUNT=<storage account name>
AZURE_STORAGE_KEY=<storage account key>
# or, instead of the key, a SAS token with Read + List on the container:
# AZURE_STORAGE_SAS_TOKEN=<sas token>
```

`start-demo.sh` adds these to the connector config at creation time, so they never go into `connector-config.json`.

## Quick Start

```bash
./start-demo.sh
```

This starts the containers, waits for Kafka Connect, and creates the connector (or updates it if it already exists, so re-running the script applies config changes).

To push files to the container (uses the Azure CLI in a container, needs write access):

```bash
./upload-csv.sh sample_data.csv employees   # -> employee-data
./upload-csv.sh new_hires.csv new_hires     # -> new-hires
```

## Routing Files to Topics

The connector picks the topic from the blob's path using `topic.regex.list`, a comma-separated list of `topic:regex` pairs:

```json
"topic.regex.list": "employee-data:input/employees/.*\\.csv,new-hires:input/new_hires/.*\\.csv"
```

| Blob path | Topic |
|-----------|-------|
| `csv-data/input/employees/*.csv` | `employee-data` |
| `csv-data/input/new_hires/*.csv` | `new-hires` |
| anything else (e.g. `csv-data/input/x.csv`) | ignored |

- The regex is matched against the full path (`input/employees/file.csv`), not just the file name.
- Keep the patterns non-overlapping. Files that match no pattern are skipped.
- To add a topic, add another `topic:regex` pair and re-run `./start-demo.sh`.
- All files are parsed with the same CSV settings. Each file's own header row gives its field names, so files can have different columns.

## Verify Messages

### Option 1: Kafka UI (Recommended)
Open http://localhost:8080 in your browser and navigate to Topics → employee-data or new-hires

### Option 2: Console Consumer
```bash
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic employee-data \
  --from-beginning
# or --topic new-hires
```

## Expected Output

Each CSV row is converted to JSON, using the header row for field names:
```json
{
  "ID": "1",
  "Name": "Alice Smith",
  "Department": "Engineering",
  "Salary": "85000"
}
```

## Differences from the Spooldir Demo

- **Files are remote.** The connector lists and reads blobs over the Azure API; nothing is mounted into the Connect container.
- **No `finished/` or `error/` folders.** Blobs are left where they are. The connector stores how far it has read in the Connect offsets topic (keyed by connector name), so it won't publish a file twice.
- **New files and folders are picked up** on each poll (`azblob.poll.interval.ms`, set to 10s here).
- **Topic per folder** instead of a single topic (see [Routing Files to Topics](#routing-files-to-topics)).
- **Re-reading everything:** deleting and recreating the connector with the same name does *not* reprocess files. Give it a new name, or clear its offsets.
- **Values are strings.** CSV columns come through as strings.

## Useful Commands

**Check connector status:**
```bash
curl http://localhost:8083/connectors/azure-blob-csv-connector/status | jq
```

**Delete connector:**
```bash
curl -X DELETE http://localhost:8083/connectors/azure-blob-csv-connector
```

**Stop all services:**
```bash
./stop-demo.sh
```

**Clean up (remove volumes):**
```bash
docker compose down -v
```
