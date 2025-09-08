🦉 OwnCoin – The Native Token of OwlVest
📌 Overview

OwnCoin (OWN) is the native ERC-20 utility token for the OwlVest startup ecosystem. It powers fundraising, staking, rewards, and governance across the platform. Designed with security, scalability, and flexibility in mind, OwnCoin is the foundation of OwlVest’s decentralized finance (DeFi) ecosystem.

🚀 Key Features

ERC-20 Standard Compliance – Fully compatible with Ethereum wallets, DEXs, and dApps.

Utility Token – Supports transactions, payments, and services within the OwlVest ecosystem.

Presale & Vesting Support – Built-in logic for presale phases and team/early investor vesting schedules.

Staking & Rewards – Token holders can stake OwnCoin and earn rewards for securing the ecosystem.

Governance – Enables community-driven decision-making for OwlVest’s growth and roadmap.

Security First – Designed with gas efficiency and safe math practices to ensure robust security.

🛠 Tech Stack

Blockchain: Ethereum

Smart Contracts: Solidity (Hardhat for development & testing)

Token Standard: ERC-20

Deployment Tools: Hardhat + Ethers.js

Wallet Integration: MetaMask

📂 Project Structure
├── contracts/            # Solidity contracts
│   └── OwnCoin.sol       # Main ERC-20 token contract
├── scripts/              # Deployment and interaction scripts
├── test/                 # Hardhat test cases
├── hardhat.config.js     # Hardhat configuration file
└── README.md             # Documentation

🔑 Smart Contract Functionalities

transfer() – Standard ERC-20 token transfer.

approve() / transferFrom() – Allowance & delegated transfers.

mint() – Token minting (restricted to contract owner).

burn() – Token burning to reduce total supply.

Extensions for OwlVest: Presale distribution, vesting schedules, and staking logic.
