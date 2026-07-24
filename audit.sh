#!/bin/bash
# Apollo Validator — Automated Audit Script
# Collects real infrastructure data and pushes to GitHub
# Run via cron: 0 */6 * * * /path/to/audit.sh

set -euo pipefail

# === CONFIG ===
VALIDATOR_ADDR="celestiavaloper1mcjmn4s8ee5ce0wsuat98kqxggfrhk04te0d38"
CELESTIA_RPC="http://localhost:36657"
CELESTIA_BIN="/root/go/bin/celestia-appd"
CELESTIA_HOME="/root/.celestia-app"
AUDIT_DIR="$HOME/apollo-validator-infra"
AUDIT_FILE="$AUDIT_DIR/VALIDATOR-AUDIT.md"
LOG_FILE="/var/log/validator-audit.log"

# === FUNCTIONS ===

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_block_height() {
    curl -s --max-time 5 $CELESTIA_RPC/status 2>/dev/null | jq -r '.result.sync_info.latest_block_height' 2>/dev/null || echo "N/A"
}

get_sync_status() {
    local catching_up
    catching_up=$(curl -s --max-time 5 $CELESTIA_RPC/status 2>/dev/null | jq -r '.result.sync_info.catching_up' 2>/dev/null || echo "unknown")
    if [ "$catching_up" = "false" ]; then echo "Synced"
    elif [ "$catching_up" = "true" ]; then echo "Catching up"
    else echo "Unknown"
    fi
}

get_peer_count() {
    curl -s --max-time 5 $CELESTIA_RPC/net_info 2>/dev/null | jq -r '.result.n_peers' 2>/dev/null || echo "N/A"
}

get_validator_info() {
    sudo $CELESTIA_BIN query staking validator "$VALIDATOR_ADDR" --home "$CELESTIA_HOME" --node "tcp://127.0.0.1:36657" --output json 2>/dev/null || echo "{}"
}

get_jail_status() {
    local info
    info=$(sudo $CELESTIA_BIN query slashing signing-info "$VALIDATOR_ADDR" --home "$CELESTIA_HOME" --node "tcp://127.0.0.1:36657" --output json 2>/dev/null || echo "{}")
    local missed
    missed=$(echo "$info" | jq -r '.missed_blocks_counter // "0"' 2>/dev/null || echo "0")
    local jailed_until
    jailed_until=$(echo "$info" | jq -r '.jailed_until // "none"' 2>/dev/null || echo "none")
    echo "$missed|$jailed_until"
}

get_cpu_info() {
    local model cores
    model=$(lscpu 2>/dev/null | sed -n 's/^Model name: *//p' | head -1 || echo "N/A")
    cores=$(nproc 2>/dev/null || echo "N/A")
    echo "$model|$cores"
}

get_system_resources() {
    local cpu ram ram_total disk disk_total
    cpu=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1 || echo "N/A")
    ram=$(free -m 2>/dev/null | awk '/Mem:/ {print $3}' || echo "N/A")
    ram_total=$(free -m 2>/dev/null | awk '/Mem:/ {print $2}' || echo "N/A")
    disk=$(df -m / 2>/dev/null | awk 'NR==2 {print $3}' || echo "N/A")
    disk_total=$(df -m / 2>/dev/null | awk 'NR==2 {print $2}' || echo "N/A")
    echo "$cpu|$ram|$ram_total|$disk|$disk_total"
}

get_uptime() {
    uptime -p 2>/dev/null || uptime | sed 's/.*up/up/' | sed 's/,.*//'
}

get_celestia_uptime() {
    sudo systemctl show celestia-appd --property=ActiveEnterTimestamp 2>/dev/null | cut -d'=' -f2 || echo "N/A"
}

get_os_info() {
    lsb_release -ds 2>/dev/null || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "N/A"
}

get_network_info() {
    ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1 || echo "N/A"
}

get_hosting_info() {
    curl -s --max-time 3 https://ipinfo.io/json 2>/dev/null | jq -r '"\(.city), \(.region), \(.country)"' 2>/dev/null || echo "N/A"
}

# === MAIN ===

log "Starting audit..."

mkdir -p "$AUDIT_DIR"

# Collect data
BLOCK_HEIGHT=$(get_block_height)
SYNC_STATUS=$(get_sync_status)
PEER_COUNT=$(get_peer_count)
JAIL_INFO=$(get_jail_status)
MISSED_BLOCKS=$(echo "$JAIL_INFO" | cut -d'|' -f1)
JAILED_UNTIL=$(echo "$JAIL_INFO" | cut -d'|' -f2)

CPU_INFO=$(get_cpu_info)
CPU_MODEL=$(echo "$CPU_INFO" | cut -d'|' -f1)
CPU_CORES=$(echo "$CPU_INFO" | cut -d'|' -f2)

SYS_RESOURCES=$(get_system_resources)
SYS_CPU=$(echo "$SYS_RESOURCES" | cut -d'|' -f1)
RAM_USED=$(echo "$SYS_RESOURCES" | cut -d'|' -f2)
RAM_TOTAL=$(echo "$SYS_RESOURCES" | cut -d'|' -f3)
DISK_USED=$(echo "$SYS_RESOURCES" | cut -d'|' -f4)
DISK_TOTAL=$(echo "$SYS_RESOURCES" | cut -d'|' -f5)

SERVER_UPTIME=$(get_uptime)
CELESTIA_START=$(get_celestia_uptime)
OS_INFO=$(get_os_info)
SERVER_IP=$(get_network_info)
HOSTING_LOCATION=$(get_hosting_info)
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

# Validator info
VALIDATOR_JSON=$(get_validator_info)
TOKENS=$(echo "$VALIDATOR_JSON" | jq -r '.validator.tokens // "N/A"' 2>/dev/null || echo "N/A")
COMMISSION_RAW=$(echo "$VALIDATOR_JSON" | jq -r '.validator.commission.commission_rates.rate // "N/A"' 2>/dev/null || echo "N/A")
STATUS_RAW=$(echo "$VALIDATOR_JSON" | jq -r '.validator.status // "N/A"' 2>/dev/null || echo "N/A")

# Format values
if [ "$STATUS_RAW" = "BOND_STATUS_BONDED" ]; then
    STATUS="Active (Bonded)"
else
    STATUS="$STATUS_RAW"
fi

if [ "$TOKENS" != "N/A" ]; then
    TOKENS_TIA=$(echo "$TOKENS" | awk '{printf "%.2f", $1/1000000}')
    TOKENS="${TOKENS_TIA} TIA"
fi

if [ "$COMMISSION_RAW" != "N/A" ]; then
    COMMISSION=$(echo "$COMMISSION_RAW" | awk '{printf "%.0f", $1*100}')
    COMMISSION="${COMMISSION}%"
fi

# Generate markdown
cat > "$AUDIT_FILE" << EOF
# Apollo Validator — Infrastructure Audit

> Last updated: $TIMESTAMP
> Auto-generated by audit.sh

---

## Validator

| Metric | Value |
|---|---|
| Address | $VALIDATOR_ADDR |
| Status | $STATUS |
| Tokens | $TOKENS |
| Commission | $COMMISSION |
| Block Height | $BLOCK_HEIGHT |
| Sync | $SYNC_STATUS |
| Peers | $PEER_COUNT |
| Missed Blocks | $MISSED_BLOCKS |
| Jailed Until | $JAILED_UNTIL |

## Server

| Metric | Value |
|---|---|
| IP | $SERVER_IP |
| Location | $HOSTING_LOCATION |
| OS | $OS_INFO |
| CPU | $CPU_MODEL |
| CPU Cores | $CPU_CORES |
| RAM | ${RAM_USED} MB / ${RAM_TOTAL} MB |
| Storage | ${DISK_USED} MB / ${DISK_TOTAL} MB |
| CPU Usage | ${SYS_CPU}% |
| Server Uptime | $SERVER_UPTIME |
| Celestia Running Since | $CELESTIA_START |

---

*Generated by audit.sh — $(date '+%Y-%m-%d %H:%M:%S')*
EOF

log "Audit file generated: $AUDIT_FILE"

# Push to GitHub
if [ -d "$AUDIT_DIR/.git" ]; then
    cd "$AUDIT_DIR"
    git add VALIDATOR-AUDIT.md
    git diff --cached --quiet || {
        git commit -m "Auto-audit: $(date '+%Y-%m-%d %H:%M')"
        git push origin main
        log "Pushed to GitHub"
    }
else
    log "WARNING: $AUDIT_DIR is not a git repo. Skipping push."
fi

log "Audit complete."
