# Use a lightweight base image
FROM alpine:latest

# Install bash and netcat
RUN apk add --no-cache bash netcat-openbsd

# Set working directory
WORKDIR /app

# Copy the application files
COPY serve.sh index.html ./

# Make the script executable
RUN chmod +x serve.sh

# Expose the port the app runs on
EXPOSE 8080

# Start the web server
CMD ["./serve.sh"]