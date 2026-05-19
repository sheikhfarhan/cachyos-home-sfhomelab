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
echo "[1/7] Re-creating CrowdSec (Security Brain)..."
cd "$OPS/crowdsec" && docker compose up -d --force-recreate
echo "⏳ Sleeping 10s to allow CrowdSec LAPI to boot..."
sleep 10

# --- Step 2: Caddy & Maxmind  ---
echo "[2/7] Re-creating Caddy (Reverse Proxy)..."
cd "$GATEWAY/cachyos-caddy" && docker compose up -d --force-recreate

echo "[3/7] Re-creating Maxmind (IP Geolocation)..."
cd "$GATEWAY/cachyos-maxmind" && docker compose up -d --force-recreate
echo "⏳ Sleeping 5s..."
sleep 5

# --- Step 3: Monitoring & Management ---
echo "[4/7] Re-creating Monitoring Stack (Homepage, Socket Proxy, Beszel)..."
cd "$MON" && docker compose up -d --force-recreate
echo "⏳ Sleeping 5s..."
sleep 10

# --- Step 4: Media Core ---
echo "[5/7] Re-creating Jellyfin Stack (Media & Requests)..."
cd "$MEDIA/jellyfin" && docker compose up -d --force-recreate
echo "⏳ Sleeping 10s..."
sleep 10

# --- Step 5: Automation Engine (The Micro-Stacks) ---
echo "[6/7] Initiating Multi-Stage VPN & ARR Deployment..."

echo "  -> [Tier 1] Re-creating VPN & Torrent Base (Gluetun/Qbit/Trans)..."
cd "$MEDIA/vpn-arr-stack/gluetun" && docker compose up -d --force-recreate
echo "  ⏳ Sleeping 15s for VPN tunnel and network bridge to stabilize..."
sleep 10

echo "  -> [Tier 1] Re-creating Indexer Foundations (Flaresolverr)..."
cd "$MEDIA/vpn-arr-stack/flaresolverr" && docker compose up -d --force-recreate
echo "  ⏳ Sleeping 10s..."
sleep 5

echo "  -> [Tier 2] Re-creating Indexers (Prowlarr, Jackett)..."
cd "$MEDIA/vpn-arr-stack/prowlarr" && docker compose up -d --force-recreate
cd "$MEDIA/vpn-arr-stack/jackett" && docker compose up -d --force-recreate
echo "  ⏳ Sleeping 5s..."
sleep 5

echo "  -> [Tier 3] Re-creating Core ARRs (Radarr, Sonarr)..."
cd "$MEDIA/vpn-arr-stack/radarr" && docker compose up -d --force-recreate
cd "$MEDIA/vpn-arr-stack/sonarr" && docker compose up -d --force-recreate
echo "  ⏳ Sleeping 10s to allow databases to initialize..."
sleep 5

echo "  -> [Tier 4] Re-creating Metadata ARRs (Bazarr, Profilarr)..."
cd "$MEDIA/vpn-arr-stack/bazarr" && docker compose up -d --force-recreate
cd "$MEDIA/vpn-arr-stack/profilarr" && docker compose up -d --force-recreate
echo "  ⏳ Sleeping 5s..."
sleep 5

# --- Step 6: Analytics & Backups ---
echo "[7/7] Re-creating Kopia (Backups)..."
cd "$OPS/kopia" && docker compose up -d --force-recreate

# --- Step 7: Housekeeping ---
echo ""
echo "🧹 Cleaning up old image layers..."
docker image prune -f

echo ""
echo "🎉 All stacks re-created successfully! System is fresh and fully armored."