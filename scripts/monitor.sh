#!/bin/bash

# Configuration from environment variables
# WEBSITES should be a comma-separated list of domains
WEBSITES=(${WEBSITES//,/ })
BOT_TOKEN="${BOT_TOKEN}"
CHAT_ID="${CHAT_ID}"
INTERVAL="${INTERVAL:-300}"

get_status_description() {
    local code=$1
    case $code in
        400) echo "Bad Request" ;;
        401) echo "Unauthorized" ;;
        402) echo "Payment Required" ;;
        403) echo "Forbidden" ;;
        404) echo "Not Found" ;;
        405) echo "Method Not Allowed" ;;
        406) echo "Not Acceptable" ;;
        407) echo "Proxy Authentication Required" ;;
        408) echo "Request Timeout" ;;
        409) echo "Conflict" ;;
        410) echo "Gone" ;;
        429) echo "Too Many Requests" ;;
        500) echo "Internal Server Error" ;;
        501) echo "Not Implemented" ;;
        502) echo "Bad Gateway" ;;
        503) echo "Service Unavailable" ;;
        504) echo "Gateway Timeout" ;;
        505) echo "HTTP Version Not Supported" ;;
        *) echo "HTTP Error" ;;
    esac
}

send_telegram_message() {
    local website=$1
    local status_code=$2
    local description=$(get_status_description "$status_code")
    local message="⚠️ Website $website returned error $status_code ($description) at $(date '+%Y-%m-%d %H:%M:%S')"
    
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" \
        -d parse_mode="HTML"
}

# Function to check a single website
check_website() {
    local website=$1
    
    # Get HTTP status code with curl
    # -s: silent mode
    # -o /dev/null: discard response body
    # -w "%{http_code}": only output the status code
    # -I: send HEAD request instead of GET
    # --max-time 10: timeout after 10 seconds
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -I --max-time 10 "https://${website}")
    
    # Check if curl failed (no status code returned)
    if [ -z "$status_code" ]; then
        send_telegram_message "$website" "TIMEOUT"
        return
    fi
    
    # Check if status code is 4xx or 5xx (client or server errors)
    if [[ $status_code =~ ^[45][0-9][0-9]$ ]]; then
        send_telegram_message "$website" "$status_code"
    fi
}

# Validate environment variables
if [ -z "$WEBSITES" ]; then
    echo "Error: WEBSITES environment variable is not set"
    echo "Please set it as a comma-separated list of domains"
    echo "Example: export WEBSITES=\"example.com,google.com,github.com\""
    exit 1
fi

if [ -z "$BOT_TOKEN" ]; then
    echo "Error: BOT_TOKEN environment variable is not set"
    exit 1
fi

if [ -z "$CHAT_ID" ]; then
    echo "Error: CHAT_ID environment variable is not set"
    exit 1
fi

echo "Starting monitoring for websites: ${WEBSITES[*]}"
echo "Check interval: ${INTERVAL} seconds"

while true; do
    for website in "${WEBSITES[@]}"; do
        check_website "$website"
        sleep 2
    done
    
    sleep ${INTERVAL}
done
