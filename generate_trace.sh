#!/bin/sh

# Script to build and run WiredTiger Docker container with log collection
# This script creates a Docker container from the Dockerfile and collects logs via mount

set -e

# Configuration
IMAGE_NAME="wiredtiger-trace"
CONTAINER_NAME="wiredtiger-trace-runner"
HOST_LOG_DIR="${1:-$(pwd)/logs}"
LOG_FILE="${2:-data_log.txt}"
CONTAINER_LOG_DIR="/logs"
OUTPUT="${3:-spc_fmt.log}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

create_log_directory() {
    print_status "Creating logs directory at ${HOST_LOG_DIR}"
    mkdir -p "${HOST_LOG_DIR}"
}

build_image() {
    print_status "Building Docker image: ${IMAGE_NAME}"
    echo docker build -t "${IMAGE_NAME}" .
    if docker build -t "${IMAGE_NAME}" .; then
        print_status "Docker image built successfully"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

cleanup_existing_container() {
    if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_warning "Container ${CONTAINER_NAME} already exists. Stopping and removing it..."
        docker stop "${CONTAINER_NAME}" 2>/dev/null || true
        docker rm "${CONTAINER_NAME}" 2>/dev/null || true
    fi
}

run_container() {
    print_status "Starting Docker container: ${CONTAINER_NAME}"
    print_status "Logs will be mounted to: ${HOST_LOG_DIR}"

    # Run the container with the following options:
    # -d: detached mode (runs in background)
    # --name: assign a name to the container
    # --mount: mount the logs directory

    if docker run -d \
        --name "${CONTAINER_NAME}" \
        --mount type=bind,source="${HOST_LOG_DIR}",target="${CONTAINER_LOG_DIR}" \
        "${IMAGE_NAME}" "${LOG_FILE}"; then

        print_status "Container started successfully"
        print_status "Container ID: $(docker ps -q --filter name=${CONTAINER_NAME})"
    else
        print_error "Failed to start container"
        exit 1
    fi
}

show_status() {
    print_status "Container status:"
    docker ps --filter name="${CONTAINER_NAME}"

    print_status "Following container logs (press Ctrl+C to stop following):"
    print_warning "Note: The actual benchmark results will be saved to ${HOST_LOG_DIR}/${LOG_FILE}"
    docker logs -f "${CONTAINER_NAME}"
}

cleanup() {
    if [[ $1 -ne 0 ]]; then
        print_error "Script interrupted or failed"
    fi

    print_status "To stop the container manually, run: docker stop ${CONTAINER_NAME}"
    print_status "To remove the container manually, run: docker rm ${CONTAINER_NAME}"
    print_status "To view collected logs, check: ${HOST_LOG_DIR}/"
}

trap 'cleanup $?' EXIT INT TERM

main() {
    print_status "Starting WiredTiger Docker container with log collection"

    print_error "${HOST_LOG_DIR}/${LOG_FILE}"
    create_log_directory
    build_image
    cleanup_existing_container
    run_container
    show_status

    ./filter.sh "${HOST_LOG_DIR}/${LOG_FILE}" > "${OUTPUT}"
}

main "$@"
