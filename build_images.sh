#!/bin/bash

# Function to print progress
print_progress() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Build Docker images
print_progress "Building flask_app image..."
docker build -t flask_app:latest Backend/myflaskapp
if [ $? -ne 0 ]; then
    print_progress "Failed to build flask_app image"
    exit 1
fi

print_progress "Building angular_app image..."
docker build -t angular_app:latest Frontend/sample-frontend
if [ $? -ne 0 ]; then
    print_progress "Failed to build angular_app image"
    exit 1
fi

print_progress "Building reverse-proxy image..."
docker build -t reverse-proxy:latest Reverse-Proxy
if [ $? -ne 0 ]; then
    print_progress "Failed to build reverse-proxy image"
    exit 1
fi

print_progress "All images have been successfully built."