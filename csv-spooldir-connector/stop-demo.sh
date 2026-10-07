#!/bin/bash

echo "🛑 Stopping Kafka CSV Connector Demo..."

# Stop all services
docker-compose down

echo ""
echo "✅ Demo stopped!"
echo ""
echo "To remove all data volumes as well, run:"
echo "   docker-compose down -v"
echo ""
