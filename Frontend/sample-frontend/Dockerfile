# Use an official Node.js runtime as a parent image
FROM node:18 AS build

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Build the Angular application for development
# RUN npm run build:dev

# Build the Angular application for production
RUN npm run build -- --configuration production

# Run the post-build script to inject the API_URL into index.html
# RUN node /app/post-build.js

# Use an official Nginx runtime as a parent image
FROM nginx:alpine

# Copy the built Angular app from the previous stage to the Nginx html directory
COPY --from=build /app/dist/sample-frontend/browser /usr/share/nginx/html

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration file to the Nginx configuration directory
COPY nginx-angular.conf /etc/nginx/conf.d

# Copy the SSL certificate and key to the container
COPY ssl/origin.pem /etc/nginx/ssl/origin.pem
COPY ssl/origin.key /etc/nginx/ssl/origin.key

# Expose ports for HTTP and HTTPS traffic
EXPOSE 6080 6443

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
