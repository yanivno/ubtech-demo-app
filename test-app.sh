#!/bin/bash

# Default values
DEFAULT_IP="20.91.161.16"
DEFAULT_PORT="80"
DEFAULT_REQUESTS=20
DEFAULT_DELAY=0.5

# Usage function
usage() {
    echo "Usage: $0 [-i IP_ADDRESS] [-p PORT] [-n NUM_REQUESTS] [-d DELAY]"
    echo ""
    echo "Options:"
    echo "  -i    Load balancer IP address (default: $DEFAULT_IP)"
    echo "  -p    Port number (default: $DEFAULT_PORT)"
    echo "  -n    Number of requests to send (default: $DEFAULT_REQUESTS)"
    echo "  -d    Delay between requests in seconds (default: $DEFAULT_DELAY)"
    echo "  -h    Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -i 10.0.0.100 -p 80 -n 20 -d 0.5"
    exit 1
}

# Parse command line arguments
IP_ADDRESS=$DEFAULT_IP
PORT=$DEFAULT_PORT
NUM_REQUESTS=$DEFAULT_REQUESTS
DELAY=$DEFAULT_DELAY

while getopts "i:p:n:d:h" opt; do
    case $opt in
        i) IP_ADDRESS="$OPTARG" ;;
        p) PORT="$OPTARG" ;;
        n) NUM_REQUESTS="$OPTARG" ;;
        d) DELAY="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Counters
success_count=0
error_count=0
timeout_count=0

echo "============================================"
echo "Flask Crash App Test Script"
echo "============================================"
echo "Target: http://${IP_ADDRESS}:${PORT}/test"
echo "Requests: ${NUM_REQUESTS}"
echo "Delay: ${DELAY}s"
echo "============================================"
echo ""

# Send requests
for i in $(seq 1 $NUM_REQUESTS); do
    echo -n "Request $i/$NUM_REQUESTS: "
    
    # Make the request with timeout
    response=$(curl -s -w "\n%{http_code}" --connect-timeout 5 --max-time 10 "http://${IP_ADDRESS}:${PORT}/test" 2>/dev/null)
    exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo "TIMEOUT/CONNECTION ERROR (exit code: $exit_code)"
        ((timeout_count++))
    else
        # Extract HTTP status code (last line) and body
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" == "200" ]; then
            echo "SUCCESS (HTTP $http_code) - $body"
            ((success_count++))
        else
            echo "ERROR (HTTP $http_code) - $body"
            ((error_count++))
        fi
    fi
    
    # Delay between requests (except after last one)
    if [ $i -lt $NUM_REQUESTS ]; then
        sleep $DELAY
    fi
done

# Summary
echo ""
echo "============================================"
echo "Summary"
echo "============================================"
echo "Total Requests: $NUM_REQUESTS"
echo "Successful:     $success_count"
echo "Errors:         $error_count"
echo "Timeouts:       $timeout_count"
echo "Success Rate:   $(echo "scale=1; $success_count * 100 / $NUM_REQUESTS" | bc)%"
echo "============================================"
