#!/bin/bash
# =====================================================
# User Data Bootstrap Script
# Runs automatically when each new EC2 instance launches
# =====================================================

echo "=== Starting EC2 Bootstrap Script ==="

# Update system packages
echo "Updating system packages..."
yum update -y

# Install Docker
echo "Installing Docker..."
yum install -y docker

# Start and enable Docker service
echo "Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Pull your Docker image
echo "Pulling Docker image from Docker Hub..."
docker pull ${dockerhub_username}/bash-web-app:latest

# Run the container
echo "Starting the Bash web application container..."
docker run -d \
  --name bash-web-app \
  --restart unless-stopped \
  -p 80:8080 \
  ${dockerhub_username}/bash-web-app:latest

echo "=== Bootstrap Completed Successfully ==="
echo "Bash web app should now be accessible on port 80"