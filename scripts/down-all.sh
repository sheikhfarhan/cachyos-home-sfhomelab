#!/bin/bash
set -e # Exit immediately if any command fails

echo "--- 🛑 Gracefully Stopping All Docker Stacks ---"
echo "This will take a moment as all containers are spun down..."
echo ""

# Define the absolute path to our stacks
BASE_DIR="/home/sfarhan/homelab/services"

# Define Sub-Stack Paths for cleaner code
OPS="$BASE_DIR/ops-stack"
MEDIA="$BASE_DIR/media-stack"
MON="$BASE_DIR/mon-stack"

# --- Step 1: Analytics & Backups ---
echo "[1/5] Stopping Kopia (Backups)..."
cd "$OPS/kopia" && docker compose down

# --- Step 2: Automation Engine ---
echo "[2/5] Stopping VPN-ARR-Stack (Downloads & Managers)..."
cd "$MEDIA/vpn-arr-stack" && docker compose down

# --- Step 3: Media Core ---
echo "[3/5] Stopping Jellyfin Stack (Media)..."
cd "$MEDIA/jellyfin" && docker compose down

# --- Step 4: Monitoring & Management ---
echo "[4/5] Stopping Monitoring Stack (Homepage, Socket Proxy, Beszel)..."
cd "$MON" && docker compose down

# --- Step 5: Core & Security Infrastructure ---
echo "[5/5] Stopping CrowdSec (Security Brain)..."
cd "$OPS/crowdsec" && docker compose down

echo ""
echo "🛑 All stacks have been successfully shut down! Safe to perform maintenance."