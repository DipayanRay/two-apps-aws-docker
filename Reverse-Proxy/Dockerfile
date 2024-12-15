# Use the official Nginx image from the Docker Hub
FROM nginx:latest

# Copy the Nginx configuration file to the container
COPY nginx-reverse-proxy.conf /etc/nginx/nginx.conf

# Copy SSL certificates to the container (if you have them)
# Make sure to place your SSL certificates in the same directory as this Dockerfile
# or adjust the path accordingly
COPY ssl /etc/nginx/ssl

# Expose ports 80 and 443
EXPOSE 80
EXPOSE 443