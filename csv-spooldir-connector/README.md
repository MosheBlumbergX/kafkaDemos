# Kafka CSV Connector Demo

A local Docker-based demo using Kafka (KRaft mode) with a Spooldir connector to read CSV files and publish messages to Kafka.

## Architecture

- **Kafka 7.7.1** (KRaft mode - no Zookeeper needed)
- **Kafka Connect** with Spooldir CSV Source Connector
- **Kafka UI** for monitoring topics and messages

## Setup

1. **Start the services:**
   ```bash
   docker-compose up -d
   ```

2. **Wait for services to be ready** (about 30-60 seconds):
   ```bash
   docker-compose logs -f kafka-connect
   # Wait until you see "Kafka Connect started"
   ```

3. **Create the connector:**
   ```bash
   curl -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d @connector-config.json
   ```

4. **Copy CSV file to input directory:**
   ```bash
   cp sample_data.csv data/input/
   ```

## Verify Messages

### Option 1: Kafka UI (Recommended)
Open http://localhost:8080 in your browser and navigate to Topics → employee-data

### Option 2: Console Consumer
```bash
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic employee-data \
  --from-beginning
```

## Expected Output

Each CSV row will be converted to JSON:
```json
{
  "ID": 1,
  "Name": "Alice Smith",
  "Department": "Engineering",
  "Salary": 85000
}
```

## Directory Structure

- `data/input/` - Place CSV files here to be processed
- `data/finished/` - Successfully processed files are moved here
- `data/error/` - Files with errors are moved here

## Useful Commands

**Check connector status:**
```bash
curl http://localhost:8083/connectors/csv-spooldir-connector/status | jq
```

**Delete connector:**
```bash
curl -X DELETE http://localhost:8083/connectors/csv-spooldir-connector
```

**Stop all services:**
```bash
docker-compose down
```

**Clean up (remove volumes):**
```bash
docker-compose down -v
```
