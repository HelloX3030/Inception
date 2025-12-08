# Build a minimal Nginx image
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy static website files
COPY html/ .

# Expose port 80
EXPOSE 80

# Run Nginx in foreground (PID 1)
CMD ["nginx", "-g", "daemon off;"]
