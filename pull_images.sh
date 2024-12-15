#!/bin/bash

# Function to print progress
print_progress() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Pull Docker images
print_progress "Pulling defect-tracker-backend image..."
docker pull dipayanray/defect-tracker-backend:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to pull defect-tracker-backend image"
    exit 1
fi

print_progress "Pulling defect-tracker-frontend image..."
docker pull dipayanray/defect-tracker-frontend:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to pull defect-tracker-frontend image"
    exit 1
fi

print_progress "Pulling defect-tracker-reverse-proxy image..."
docker pull dipayanray/defect-tracker-reverse-proxy:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to pull defect-tracker-reverse-proxy image"
    exit 1
fi

print_progress "All images have been successfully pulled."
