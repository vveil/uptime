#!/bin/bash

# Configuration from environment variables
WEBSITE="${WEBSITE}"
BOT_TOKEN="${BOT_TOKEN}"
CHAT_ID="${CHAT_ID}"
INTERVAL="${INTERVAL}"

# Function to send Telegram message
send_telegram_message() {
    local message="⚠️ Website $WEBSITE is DOWN at $(date '+%Y-%m-%d %H:%M:%S')"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" \
        -d parse_mode="HTML"
}

# Main monitoring loop
while true; do
    if ! ping -c 1 ${WEBSITE} &>/dev/null; then
        send_telegram_message
    fi
    sleep ${INTERVAL}
done
