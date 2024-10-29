#!/bin/bash

# Configuration from environment variables
WEBSITE="${WEBSITE}"
BOT_TOKEN="${BOT_TOKEN}"
CHAT_ID="${CHAT_ID}"
INTERVAL="${INTERVAL}"

# Function to send Telegram message
send_telegram_message() {
    local status_code=$1
    local message="⚠️ Website $WEBSITE returned error $status_code at $(date '+%Y-%m-%d %H:%M:%S')"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" \
        -d parse_mode="HTML"
}

# Main monitoring loop
while true; do
    # Get HTTP status code with curl
    # -s: silent mode
    # -o /dev/null: discard response body
    # -w "%{http_code}": only output the status code
    # -I: send HEAD request instead of GET
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -I "https://${WEBSITE}")
    
    # Check if status code starts with 5
    if [[ $status_code =~ ^5[0-9][0-9]$ ]]; then
        send_telegram_message "$status_code"
    fi
    
    sleep ${INTERVAL}
done
