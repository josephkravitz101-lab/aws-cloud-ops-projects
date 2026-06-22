#!/bin/bash
# serve.sh - Simple & Reliable Bash HTTP Server for Docker Demo
# This is perfect for your Terraform + Docker portfolio project

# ================================================
# Configuration
# ================================================

# Set the port the server will listen on.
# You can override it when running: PORT=9000 ./serve.sh
PORT="${PORT:-8080}"

# Print startup message (visible in terminal and docker logs)
echo "🚀 Starting Bash web server on port $PORT..."


# ================================================
# Main Server Loop
# ================================================

# Infinite loop - keeps the server running forever
while true; do
    {
        # === Send HTTP Response Headers ===
        # These are required for the browser/curl to understand the response
        echo -e "HTTP/1.1 200 OK\r"           # Status: Success
        echo -e "Content-Type: text/html\r"    # Tell client this is HTML content
        echo -e "\r"                           # Blank line required (headers end here)

        # === Serve Content ===
        # If index.html exists in the same folder, serve it
        if [[ -f index.html ]]; then
            cat index.html
        else
            # Fallback message if index.html is missing
            echo "<h1>Hello from Bash Web Server</h1>"
            echo "<p>This is a simple Bash + Docker demo running on Terraform ASG.</p>"
        fi

    # Pipe the entire response to netcat, which listens for incoming connections
    } | nc -l -p "$PORT" -q 1 -w 2
done