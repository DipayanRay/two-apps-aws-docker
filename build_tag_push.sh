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

# Tag Docker images
print_progress "Tagging flask_app image..."
docker tag flask_app docker_hub_user_name/flask_app:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to tag flask_app image"
    exit 1
fi

print_progress "Tagging angular_app image..."
docker tag angular_app docker_hub_user_name/angular_app:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to tag angular_app image"
    exit 1
fi

print_progress "Tagging reverse-proxy image..."
docker tag reverse-proxy docker_hub_user_name/reverse-proxy:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to tag reverse-proxy image"
    exit 1
fi

# Push Docker images
print_progress "Pushing flask_app image..."
docker push docker_hub_user_name/flask_app:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to push flask_app image"
    exit 1
fi

print_progress "Pushing angular_app image..."
docker push docker_hub_user_name/angular_app:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to push angular_app image"
    exit 1
fi

print_progress "Pushing reverse-proxy image..."
docker push docker_hub_user_name/reverse-proxy:latest
if [ $? -ne 0 ]; then
    print_progress "Failed to push reverse-proxy image"
    exit 1
fi

print_progress "All images have been successfully built, tagged, and pushed."
