#!/bin/bash

# ==========================================
# LOAD SECRETS
# ==========================================
# Source the .env file using its absolute path
source /home/sfarhan/homelab/cachyos-home/scripts/.env

# ==========================================
# CONFIGURATION
# ==========================================
THRESHOLD=90.00

# Variables are now injected securely
GOTIFY_URL="https://gotify.${ROOT_DOMAIN}/message"
GOTIFY_TOKEN="${GOTIFY_CACHYOS_TOKEN}"

# ==========================================
# METRICS GATHERING
# ==========================================
STATS=$(docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}" | sed 's/%//g')

ALERT_TRIGGERED=false
MESSAGE="⚠️ WARNING: High Container CPU Detected on CachyOS!

Offending Containers:
"

# ==========================================
# ALERT LOGIC
# ==========================================
while read -r NAME CPU; do
    IS_HIGH=$(awk -v cpu="$CPU" -v thresh="$THRESHOLD" 'BEGIN {if (cpu >= thresh) print 1; else print 0}')
    
    if [ "$IS_HIGH" -eq 1 ]; then
        ALERT_TRIGGERED=true
        MESSAGE="$MESSAGE- $NAME: ${CPU}%
"
    fi
done <<< "$STATS"

# ==========================================
# DISPATCH
# ==========================================
if [ "$ALERT_TRIGGERED" = true ]; then
    echo "High usage detected. Sending payload to Gotify..."
    
    curl -sS -X POST "$GOTIFY_URL?token=$GOTIFY_TOKEN" \
        -F "title=🐳 CachyOS Docker Alert" \
        -F "message=$MESSAGE" \
        -F "priority=7"
else
    echo "✅ All CachyOS containers are nominal."
fi