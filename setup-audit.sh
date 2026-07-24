#!/bin/bash
# Setup script for Apollo Validator Audit
# Run once on the server to install the audit cron job

set -euo pipefail

AUDIT_SCRIPT="$HOME/audit.sh"
AUDIT_DIR="$HOME/apollo-validator-infra"
CRON_SCHEDULE="0 */6 * * *"  # Every 6 hours

echo "=== Apollo Validator Audit Setup ==="

# 1. Clone or create repo
if [ ! -d "$AUDIT_DIR/.git" ]; then
    echo "[1/4] Creating audit repository..."
    mkdir -p "$AUDIT_DIR"
    cd "$AUDIT_DIR"
    git init
    git remote add origin https://github.com/zelivsky/apollo-validator-infra.git 2>/dev/null || true
    
    # Create initial files
    echo "# Apollo Validator Infrastructure" > README.md
    echo "Automated audit and documentation for Apollo Celestia Validator." >> README.md
    
    git add .
    git commit -m "Initial commit"
    
    echo "  → Repository created at $AUDIT_DIR"
    echo "  → IMPORTANT: Push to GitHub first, then re-run this setup"
    echo "  → Or add your GitHub token:"
    echo "     git remote set-url origin https://<TOKEN>@github.com/zelivsky/apollo-validator-infra.git"
else
    echo "[1/4] Repository already exists at $AUDIT_DIR"
fi

# 2. Copy audit script
echo "[2/4] Installing audit script..."
cp "$OLDPWD/audit.sh" "$AUDIT_SCRIPT"
chmod +x "$AUDIT_SCRIPT"
echo "  → Installed at $AUDIT_SCRIPT"

# 3. Create log directory
echo "[3/4] Setting up logging..."
sudo touch /var/log/validator-audit.log
sudo chmod 666 /var/log/validator-audit.log
echo "  → Log file: /var/log/validator-audit.log"

# 4. Install cron job
echo "[4/4] Installing cron job..."
(crontab -l 2>/dev/null | grep -v "audit.sh"; echo "$CRON_SCHEDULE $AUDIT_SCRIPT >> /var/log/validator-audit.log 2>&1") | crontab -
echo "  → Cron schedule: $CRON_SCHEDULE (every 6 hours)"

# 5. Run initial audit
echo ""
echo "=== Running initial audit ==="
bash "$AUDIT_SCRIPT"
echo ""
echo "=== Setup complete ==="
echo ""
echo "Files created:"
echo "  - $AUDIT_DIR/VALIDATOR-AUDIT.md (audit report)"
echo "  - $AUDIT_SCRIPT (audit script)"
echo "  - /var/log/validator-audit.log (log file)"
echo ""
echo "Next steps:"
echo "  1. Push the repo to GitHub: cd $AUDIT_DIR && git push -u origin main"
echo "  2. Verify audit: cat $AUDIT_DIR/VALIDATOR-AUDIT.md"
echo "  3. Check cron: crontab -l"
echo "  4. After push, the audit will auto-update every 6 hours"
