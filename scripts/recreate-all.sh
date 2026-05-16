#!/bin/bash
set -e # Exit immediately if any command fails

echo "--- 🐳 Forcibly Re-creating All Docker Stacks ---"
echo "This will take a few minutes as all containers are rebuilt..."
echo ""

# Define the absolute path to our stacks
BASE_DIR="/home/sfarhan/homelab/cachyos-home"

# Define Sub-Stack Paths for cleaner code
GATEWAY="$BASE_DIR/gateway-stack"
OPS="$BASE_DIR/ops-stack"
MEDIA="$BASE_DIR/media-stack"
MON="$BASE_DIR/mon-stack"

# --- Step 1 : CrowdSec First ---

echo "[1/7] Re-creating CrowdSec..."
cd "$OPS/crowdsec" && docker compose up -d --force-recreate

# --- Step 2: Caddy & Maxmind  ---

echo "[2/7] Re-creating Caddy (Reverse Proxy)..."
cd "$GATEWAY/cachyos-caddy" && docker compose up -d --force-recreate

echo "[3/7] Re-creating Maxmind (IP Geolocation)..."
cd "$GATEWAY/cachyos-maxmind" && docker compose up -d --force-recreate

# --- Step 3: Monitoring & Management ---
# We do this early so the Socket Proxy is ready if other apps need it

echo "[4/7] Re-creating Monitoring Stack (Homepage, Socket Proxy, Beszel)..."
cd "$MON" && docker compose up -d --force-recreate

# --- Step 5: Media Core ---

echo "[5/7] Re-creating Jellyfin Stack (Media & Requests)..."
cd "$MEDIA/jellyfin" && docker compose up -d --force-recreate

# --- Step 6: Automation Engine ---

echo "[6/7] Re-creating VPN-ARR-Stack (Downloads & Managers)..."
cd "$MEDIA/vpn-arr-stack" && docker compose up -d --force-recreate

# --- Step 7: Analytics & Backups ---

echo "[7/7] Re-creating Kopia (Backups)..."
cd "$OPS/kopia" && docker compose up -d --force-recreate

# --- Step 8: Housekeeping ---
echo ""
echo "🧹 Cleaning up old image layers..."
docker image prune -f

echo ""
echo "🎉 All stacks re-created successfully! System is fresh."
