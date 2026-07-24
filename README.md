# Apollo Validator Infrastructure

Automated audit and documentation for Apollo Celestia Validator.

## Validator Status

[![Auto Audit](https://img.shields.io/badge/auto--audit-updating-blue)](https://github.com/zelivsky/apollo-validator-infra/blob/main/VALIDATOR-AUDIT.md)

**Latest audit:** See [VALIDATOR-AUDIT.md](VALIDATOR-AUDIT.md)

## What This Repository Contains

| File | Description |
|---|---|
| `VALIDATOR-AUDIT.md` | Auto-generated audit report (updated every 6 hours) |
| `audit.sh` | Audit script that collects and pushes data |
| `setup-audit.sh` | One-time setup script for the server |
| `security.md` | Security practices documentation |
| `VALIDATOR-AUDIT.md` | Live validator stats |

## How It Works

1. `audit.sh` runs every 6 hours via cron
2. It collects: block height, peers, hardware stats, validator status, jail/missed blocks
3. Generates `VALIDATOR-AUDIT.md`
4. Auto-commits and pushes to this repository

## Setup (on server)

```bash
# Clone this repo
git clone https://github.com/zelivsky/apollo-validator-infra.git
cd apollo-validator-infra

# Run setup
chmod +x setup-audit.sh
./setup-audit.sh
```

## Manual Run

```bash
~/audit.sh
cat ~/apollo-validator-infra/VALIDATOR-AUDIT.md
```

## Requirements Gap (as of application)

| Requirement | Current | Target | Status |
|---|---|---|---|
| CPU | AMD Ryzen 5 3600 (6 cores) | 32 cores + GFNI/SHA-NI | 🔴 |
| RAM | 64 GB | 32 GB min | ✅ |
| Storage | 2x500 GB NVMe | 12 TiB NVMe | 🔴 |
| Hosting (mainnet) | Mevspace, Poland | Not Hetzner/OVH/Contabo | ✅ |
| Hosting (testnet) | Contabo | Not Contabo | 🔴 |
| Contributions | None | 3-5 public goods | 🔴 |
| Security docs | None | Public documentation | 🔴 |

## Links

- Validator: [Mintscan](https://www.mintscan.io/celestia/validators/celestiavaloper1mcjmn4s8ee5ce0wsuat98kqxggfrhk04te0d38)
- Website: [apollo-validator.eu](https://apollo-validator.eu)
- GitHub: [zelivsky](https://github.com/zelivsky)
