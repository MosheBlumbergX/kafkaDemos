#!/bin/bash

echo "🚀 Starting Kafka CSV Connector Demo..."

# Start services
echo "1. Starting Docker containers..."
docker-compose up -d

echo "2. Waiting for Kafka Connect to be ready..."
for i in {1..30}; do
  if curl -s http://localhost:8083/ > /dev/null 2>&1; then
    echo "✅ Kafka Connect is ready!"
    break
  fi
  echo "   Waiting... ($i/30)"
  sleep 2
done

# Create connector
echo "3. Creating CSV Spooldir Connector..."
sleep 5
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connector-config.json

echo ""
echo "4. Copying sample CSV to input directory..."
cp sample_data.csv data/input/sample_data_$(date +%s).csv

echo ""
echo "✅ Demo setup complete!"
echo ""
echo "📊 View messages at: http://localhost:8080"
echo "   Navigate to: Topics → employee-data"
echo ""
echo "🔍 Or use console consumer:"
echo "   docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic employee-data --from-beginning"
echo ""
