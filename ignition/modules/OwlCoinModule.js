// This setup uses Hardhat Ignition to deploy the OwlCoin token
// Learn more at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("OwlCoinModule", (m) => {
  // Deploy the OwlCoin contract (no constructor parameters needed)
  const owlCoin = m.contract("OwlCoin");
  
  // Optional post-deployment actions
  // m.call(owlCoin, "toggleMinting", [false]); // Disable minting after deploy
  // m.call(owlCoin, "transferOwnership", ["0xNewOwnerAddress"]); // Transfer ownership
  
  return { owlCoin };
});