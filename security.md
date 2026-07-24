# Apollo Validator — Security Practices

## Key Management
- Validator private keys stored in encrypted keyring
- No remote access to validator keys
- Backup keys stored in encrypted offline storage
- Key rotation procedure: [to be documented]

## Server Security
- SSH key-only authentication (PasswordAuthentication no)
- Firewall enabled (ufw)
- Allowed ports: 26656/TCP (P2P), 22/TCP (SSH, restricted)
- Separate user for validator operations (not root)
- Regular OS security updates (unattended-upgrades)
- Fail2ban enabled

## Network Security
- Validator node: no public RPC exposure
- Bridge node: separate server or isolated process
- Monitoring: separate user/process

## Backup Strategy
- Validator key backup: [frequency]
- Config backup: [method]
- Encryption: [method]
- Offline storage: [description]

## Incident Response
- Alerting: Telegram bot, real-time
- Response time: <5 minutes for critical alerts
- Escalation: [procedure]

## Upgrade Policy
- Pre-upgrade: backup keys + config
- Upgrade window: within 24 hours of announcement
- Post-upgrade: verify signing, check logs, monitor 30 min
