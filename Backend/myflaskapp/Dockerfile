# Use an official Ubuntu base image
FROM ubuntu:latest

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package repository and install necessary packages
RUN apt-get update && apt-get upgrade -y

# Install Python3, pip, and other necessary dependencies
RUN apt-get install -y python3 python3-pip gcc python3-dev python3-venv nginx

# Clean the cache
RUN apt-get clean

# Set the working directory to /app
WORKDIR /app

# Copy the application code to the working directory
COPY . /app

# Copy SSL certificates to the working directory
COPY ssl/origin.pem /app/origin.pem
COPY ssl/origin.key /app/origin.key

# Create a virtual environment
RUN python3 -m venv .virtual-env

# Activate the virtual environment and install Python dependencies
RUN . .virtual-env/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

# Expose the port that the Flask app will run on
EXPOSE 5000

# Copy Nginx configuration file
COPY nginx-flask.conf /etc/nginx/nginx.conf

# Expose ports for HTTP and HTTPS traffic
EXPOSE 7080 7443

# Run the runProdServer.sh script and start Nginx
CMD ["/bin/bash", "-c", "/app/run_server.sh & nginx -g 'daemon off;'"]