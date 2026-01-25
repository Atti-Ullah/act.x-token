# ACT.XToken — UUPS-Upgradeable ERC-20 Token

Project Overview
ACT.XToken is a UUPS-upgradeable ERC-20 token designed with:

- Transfer tax (basis points, configurable)  
- Reward pool logic funded by tax on transactions  
- Role-based reward distribution via `REWARD_MANAGER_ROLE`  
- Upgradeable implementation using UUPS proxy pattern  
- Secure ownership & access control for administrative functions  

This project demonstrates best practices for upgradeable smart contracts, tokenomics, and professional blockchain development.

---

Architecture

```text
    ┌───────────────────────────────┐
    │         Proxy Contract         │  ← Users interact here
    │      (ERC1967Proxy, UUPS)     │
    └─────────────┬─────────────────┘
                  │
                  ▼
    ┌───────────────────────────────┐
    │   ACTXToken Implementation    │
    │ - ERC20Upgradeable            │
    │ - OwnableUpgradeable          │
    │ - AccessControlUpgradeable    │
    │ - UUPSUpgradeable             │
    │ - Reward Pool & Tax Logic     │
    └───────────────────────────────┘
