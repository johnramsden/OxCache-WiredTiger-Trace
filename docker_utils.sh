#!/bin/bash

# Utility script for managing WiredTiger Docker container

CONTAINER_NAME="wiredtiger-trace-runner"
LOG_DIR="$(pwd)/logs"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

case "$1" in
    "status")
        print_status "Container status:"
        docker ps -a --filter name="${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    "logs")
        print_status "Following container logs (Ctrl+C to stop):"
        docker logs -f "${CONTAINER_NAME}"
        ;;
    "stop")
        print_status "Stopping container..."
        if docker stop "${CONTAINER_NAME}"; then
            print_status "Container stopped"
        else
            print_error "Failed to stop container"
        fi
        ;;
    "remove")
        print_status "Removing container..."
        if docker rm "${CONTAINER_NAME}"; then
            print_status "Container removed"
        else
            print_error "Failed to remove container"
        fi
        ;;
    "results")
        print_status "Benchmark results:"
        if [ -f "${LOG_DIR}/data_log.txt" ]; then
            echo "Results saved in: ${LOG_DIR}/data_log.txt"
            echo "Last 20 lines:"
            tail -20 "${LOG_DIR}/data_log.txt"
        else
            print_warning "No results found in ${LOG_DIR}/data_log.txt"
            echo "Available files in ${LOG_DIR}:"
            ls -la "${LOG_DIR}/" 2>/dev/null || echo "Log directory does not exist"
        fi
        ;;
    "shell")
        print_status "Opening shell in container..."
        docker exec -it "${CONTAINER_NAME}" /bin/bash
        ;;
    *)
        echo "WiredTiger Docker Utilities"
        echo "Usage: $0 {status|logs|stop|remove|results|shell}"
        echo ""
        echo "Commands:"
        echo "  status   - Show container status"
        echo "  logs     - Follow container logs"
        echo "  stop     - Stop the running container"
        echo "  remove   - Remove the container"
        echo "  results  - Show benchmark results"
        echo "  shell    - Open shell in container"
        ;;
esac