// scripts/deploy/OwlPresale.js
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// Default addresses for BSC Testnet
const DEFAULT_OWL_TOKEN = "0x..."; // Replace with your OwlCoin address
const DEFAULT_USDT_TOKEN = "0x337610d27c682E347C9cD60BD4b3b107C9d34dDd"; // BSC Testnet USDT
const DEFAULT_PRICE = 500000000000000; // 0.0005 BNB per OWL

module.exports = buildModule("OwlPresaleModule", (m) => {
  // Get parameters with defaults
  const owlToken = m.getParameter("owlToken", DEFAULT_OWL_TOKEN);
  const usdtToken = m.getParameter("usdtToken", DEFAULT_USDT_TOKEN);
  const pricePerToken = m.getParameter("price", DEFAULT_PRICE);
  
  // Deploy OwlPresale contract
  const owlPresale = m.contract("OwlPresale", [
    owlToken,
    usdtToken,
    pricePerToken
  ]);
  
  // Optional: Transfer ownership to a multisig
  // m.call(owlPresale, "transferOwnership", ["0xYourMultisigAddress"]);
  
  return { owlPresale };
});