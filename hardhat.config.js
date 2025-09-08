require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.28",
  defaultNetwork: "hardhat",
  networks: {
    // BNB Smart Chain Mainnet
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: [process.env.PRIVATE_KEY],
      gas: 8000000,
      gasPrice: 5000000000, // 5 gwei
      timeout: 60000,
    },
    // BNB Smart Chain Testnet
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: [process.env.PRIVATE_KEY],
      gas: 8000000,
      gasPrice: 10000000000, // 10 gwei
      timeout: 60000,
    },
    // Existing configs
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
      gas: 8000000,
      gasPrice: 20000000000,
      timeout: 60000,
    },
    hardhat: {
      chainId: 31337,
      gas: 12000000,
      gasPrice: 8000000000,
    },
  },
  mocha: {
    timeout: 60000
  }
};