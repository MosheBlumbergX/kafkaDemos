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

## Requirements

- Docker
- Docker Compose

## Contributing

Feel free to add more Kafka demos and examples to this repository.
