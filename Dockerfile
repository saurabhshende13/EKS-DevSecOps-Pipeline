# Use nginx as the base image
FROM nginx:alpine

# Update package repositories and upgrade libxml2
RUN apk update && apk upgrade libxml2

# Copy the static website files to the nginx html directory
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/

# Create images directory and copy images
COPY images/ /usr/share/nginx/html/images/

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 