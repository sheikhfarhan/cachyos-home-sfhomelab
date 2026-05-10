#!/bin/bash
BASE_DIR="/home/sfarhan/homelab/cachyos-home"

echo "--- 🔎 Auto-Discovering and Pulling Stacks ---"

# Logic: Look for compose.yml BUT skip (prune) directories named 'data', 'cache', 'logs', 'state', 'media'
find "$BASE_DIR" \
  -type d \( -name "data" -o -name "cache" -o -name "logs" -o -name "state" -o -name "media" -o -name "docker-data" -o -name "certificates" \) -prune \
  -o -name "compose.yml" -print | while read compose_file; do

    dir=$(dirname "$compose_file")
    stack_name=$(basename "$dir")
    
    echo "⬇️  Pulling for: $stack_name ($dir)"
    # We use ( ) to run cd in a subshell so it doesn't affect the main script loop
    (cd "$dir" && docker compose pull)
    
    echo "✅  Done."
    echo "-----------------------------------"
done

echo "🎉 All discovered stacks updated."