# Apollo Validator — Security Practices

> Last audited: 2026-07-24

## SSH Hardening

| Setting | Value |
|---|---|
| PermitRootLogin | no |
| PasswordAuthentication | no |
| PubkeyAuthentication | yes |
| MaxAuthTries | 3 |
| ClientAliveInterval | 300s |
| ClientAliveCountMax | 2 |

- Key-only authentication (ed25519)
- Root login disabled
- Backup config: /etc/ssh/sshd_config.bak

## Firewall (UFW)

Default: deny incoming, allow outgoing

Allowed ports:
- 22/tcp — SSH
- 80/tcp — HTTP
- 443/tcp — HTTPS
- 36656/tcp — Celestia P2P
- 26656/tcp — AtomOne P2P
- 42656/tcp — Axone P2P
- 43656/tcp — Cardchain P2P
- 47656/tcp — Gnoland P2P
- 13756/tcp — Canine P2P
- 38656/tcp — Arkeo P2P
- 27656/tcp — Quicksilver P2P
- 28656/tcp — Bitway P2P
- 29656/tcp — Terp P2P
- 35660/tcp — Realio P2P
- 46656/tcp — Tendermint P2P
- 31244:31248/tcp — Massa P2P
- 33035:33037/tcp — Massa API

## Brute Force Protection (Fail2Ban)

- Active and enabled on boot
- SSH jail: 5 retries, 10 minute ban

## Automatic Updates

- unattended-upgrades: active
- Security patches: automatic
- Reboot schedule: as needed

## User Accounts

- oot — SSH login disabled
- celestia — operational user with sudo (NOPASSWD)
- No other interactive users

## Validator Key Management

- Keys stored in /root/.celestia-app/
- Access via celestia user + sudo
- Regular backups: [to be documented]

## Monitoring

- Custom Telegram bot with real-time alerts
- Checks: jail, offline, missed blocks, disk, peers
- Cron audit: every 6 hours → GitHub

## Incident Response

- Critical alerts: Telegram
- Response time: <5 minutes
- Escalation: manual review

## Upgrade Policy

- Pre-upgrade: backup keys + config
- Upgrade window: within 24 hours
- Post-upgrade: verify signing, monitor 30 min
