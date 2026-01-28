# ACTXToken Project

**Overview**

ACTXToken is a **UUPS-upgradeable ERC-20 smart contract** designed for professional-grade blockchain development assignments. The contract implements controlled minting, transfer taxation, reward distribution, and upgrade authorization using OpenZeppelin’s upgradeable architecture.

This project demonstrates:

* Upgradeable smart contract design (UUPS)
* Secure role-based access control
* Tax and reward distribution mechanics
* Foundry-style unit testing structure
* Deployment to the Sepolia testnet

---

## Architecture

The system follows a **Proxy + Implementation** architecture using the **UUPS (Universal Upgradeable Proxy Standard)** pattern.

### High-Level Flow

```
User → Proxy Contract → ACTXToken Implementation
                     → ERC20 Logic
                     → Reward & Tax Logic
                     → Upgrade Authorization
```

### Key Components

* **Proxy Contract**: Stores state and delegates calls
* **ACTXToken.sol**: Implementation logic
* **UUPSUpgradeable**: Enables secure upgrades
* **OwnableUpgradeable**: Restricts admin actions

Only the contract owner can authorize upgrades.

---

## Smart Contract Details

### ACTXToken.sol

Features:

* ERC-20 compliant token
* Upgradeable using UUPS
* Configurable transfer tax
* Reward pool distribution
* Secure initialization (no constructor logic)

#### Core Functions

* `initialize(address treasury, uint256 initialSupply)`
* `transfer(address to, uint256 amount)`
* `setTaxRate(uint256 newRate)`
* `distributeReward(address to, uint256 amount)`
* `upgradeTo(address newImplementation)`

---

## Security Considerations

The following security practices are applied:

* Initialization protected with `initializer`
* Upgrade authorization restricted to owner
* No constructors used (upgrade-safe)
* Input validation on tax rates and transfers
* Reentrancy-safe reward distribution

Upgrade logic follows OpenZeppelin’s recommended UUPS security model.

---

## Testing Strategy (Foundry)

Automated tests are written using **Foundry** and organized under the `test/` directory.

### Test Coverage

* Minting and initial supply
* Transfers and tax deduction
* Reward distribution logic
* Role-based access control
* Upgrade authorization
* Invalid calls and reverts

> Note: Foundry tests are designed to run in a local environment using `forge test`. Remix IDE was used for deployment and manual validation.

---

## Deployment

### Network

* **Testnet**: Sepolia

### Deployment Steps

1. Deploy ACTXToken implementation
2. Deploy UUPS proxy pointing to implementation
3. Initialize via proxy

## Deployment Result

* **Proxy Address**: (Paste your proxy address here)
* **Transaction Hash**: (Paste deployment tx hash here)

All user interactions occur through the proxy contract.

---

## RPC Node Plan

For local testing and Sepolia deployment, the following RPC providers can be used:

 > Infura
 > Alchemy
 > Ankr

Environment variables are recommended for secure RPC and private key management.

---

## Repository Structure

```
ACTXTokenProject/
├── src/
│   └── ACTXToken.sol
├── test/
│   └── ACTXToken.t.sol
├── script/
│   └── DeployACTX.s.sol
├── README.md
├── foundry.toml
└── .gitignore
```

---

## Conclusion

This project fulfills all assignment deliverables by implementing a secure, upgradeable ERC-20 token with professional architecture, testing structure, and documentation. The design follows industry best practices and is suitable for real-world blockchain development workflows.
