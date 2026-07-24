# Apollo Validator — Security Practices

> Last audited: 2026-07-24

## SSH Hardening

- Key-only authentication (ed25519)
- Root login disabled
- Password authentication disabled
- Max auth attempts: 3
- Client alive interval: 300s

## Firewall (UFW)

Default: deny incoming, allow outgoing

Allowed ports:
- 22/tcp — SSH
- 80/tcp — HTTP
- 443/tcp — HTTPS
- 36656/tcp — Celestia P2P

## Brute Force Protection (Fail2Ban)

- Active and enabled on boot
- SSH jail configured

## Automatic Updates

- unattended-upgrades: active
- Security patches: automatic

## Validator Operations

- Dedicated operational user (non-root)
- Separate accounts for different services
- Validator keys stored in encrypted keyring

## Monitoring

- Custom monitoring with real-time Telegram alerts
- Checks: validator status, uptime, missed blocks, system resources
- Automated audit every 6 hours

## Upgrade Policy

- Pre-upgrade: backup keys and configuration
- Upgrade window: within 24 hours of announcement
- Post-upgrade: verify signing, monitor for 30 minutes
