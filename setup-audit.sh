#!/bin/bash
# Apollo Validator Audit — Setup
# Run once on the server

set -euo pipefail

AUDIT_SCRIPT="$HOME/audit.sh"
AUDIT_DIR="$HOME/apollo-validator-infra"
CRON_SCHEDULE="0 */6 * * *"

echo "=== Apollo Validator Audit Setup ==="

# 1. Clone repo
if [ ! -d "$AUDIT_DIR/.git" ]; then
    echo "[1/3] Cloning repository..."
    git clone https://github.com/Zelivsky/apollo-validator-infra.git "$AUDIT_DIR"
else
    echo "[1/3] Repository already exists"
fi

# 2. Install audit script
echo "[2/3] Installing audit script..."
cp "$AUDIT_DIR/audit.sh" "$AUDIT_SCRIPT"
chmod +x "$AUDIT_SCRIPT"
sudo touch /var/log/validator-audit.log
sudo chmod 666 /var/log/validator-audit.log

# 3. Install cron
echo "[3/3] Installing cron job..."
(crontab -l 2>/dev/null | grep -v "audit.sh"; echo "$CRON_SCHEDULE $AUDIT_SCRIPT >> /var/log/validator-audit.log 2>&1") | crontab -

# Run first audit
echo ""
echo "=== Running first audit ==="
bash "$AUDIT_SCRIPT"

echo ""
echo "=== Done ==="
echo "  Audit runs every 6 hours"
echo "  Log: /var/log/validator-audit.log"
echo "  Output: $AUDIT_DIR/VALIDATOR-AUDIT.md"
echo "  GitHub: https://github.com/Zelivsky/apollo-validator-infra"
