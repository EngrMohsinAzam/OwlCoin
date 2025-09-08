// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * ----------------------------------------------------------------
 * Contract: OwlCoin Token (ERC20 with cap, burn, minting enabled)
 * ----------------------------------------------------------------
 */
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwlCoin is ERC20Capped, ERC20Burnable, Ownable {
    /// @notice Minting switch — enabled by default for the owner
    bool public mintingEnabled = true;
    
    /// @notice Initial supply to mint to deployer (1B out of 10B cap)
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 1e18; // 1B tokens
    
    /**
     * @notice Constructor - deploys with initial supply to deployer
     */
    constructor()
        ERC20("OwlCoin", "OWL")
        ERC20Capped(10_000_000_000 * 1e18) // 10B token cap
        Ownable(msg.sender) // Deployer becomes the initial owner
    {
        // Mint initial supply to the contract deployer
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /** -----------------------------------------------------------
     *  Admin Controls (onlyOwner)
     * ------------------------------------------------------------*/

    /// @notice Owner can enable or disable future minting
    function toggleMinting(bool _state) external onlyOwner {
        mintingEnabled = _state;
        emit MintingToggled(_state);
    }

    /**
     * @notice Mint new tokens to any address
     * @dev Respects the hard cap (10B OWL). Requires minting to be enabled.
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint (in wei, 18 decimals)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(mintingEnabled, "Minting is disabled");
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than 0");
        
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @notice Batch mint tokens to multiple addresses
     * @param recipients Array of addresses to mint to
     * @param amounts Array of amounts to mint (must match recipients length)
     */
    function batchMint(address[] calldata recipients, uint256[] calldata amounts) 
        external 
        onlyOwner 
    {
        require(mintingEnabled, "Minting is disabled");
        require(recipients.length == amounts.length, "Arrays length mismatch");
        require(recipients.length > 0, "Empty arrays");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Cannot mint to zero address");
            require(amounts[i] > 0, "Amount must be greater than 0");
            _mint(recipients[i], amounts[i]);
        }
        
        emit BatchMintCompleted(recipients.length);
    }

    /**
     * @notice Emergency function to disable minting permanently
     * @dev Once called, minting cannot be re-enabled
     */
    function disableMintingPermanently() external onlyOwner {
        mintingEnabled = false;
        emit MintingDisabledPermanently();
    }

    /**
     * @notice Transfer ownership of the contract
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        super.transferOwnership(newOwner);
    }

    /**
     * @notice Renounce ownership - makes the contract ownerless
     * @dev Use with caution! This will disable all onlyOwner functions permanently
     */
    function renounceOwnership() public override onlyOwner {
        super.renounceOwnership();
    }

    /**
     * @dev Override required to resolve multiple inheritance diamond problem
     */
    function _update(address from, address to, uint256 value)
        internal
        virtual
        override(ERC20, ERC20Capped)
    {
        super._update(from, to, value);
    }

    /** -----------------------------------------------------------
     *  View Functions
     * ------------------------------------------------------------*/

    /// @notice Get remaining tokens that can be minted
    function remainingMintableSupply() external view returns (uint256) {
        return cap() - totalSupply();
    }

    /// @notice Check if minting is currently allowed
    function canMint() external view returns (bool) {
        return mintingEnabled && totalSupply() < cap();
    }

    /// @notice Get token information
    function getTokenInfo() external view returns (
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 tokenTotalSupply,
        uint256 tokenCap,
        uint256 remainingSupply,
        bool isMintingEnabled
    ) {
        return (
            name(),
            symbol(),
            decimals(),
            totalSupply(),
            cap(),
            cap() - totalSupply(),
            mintingEnabled
        );
    }

    /** -----------------------------------------------------------
     *  Events
     * ------------------------------------------------------------*/

    event MintingToggled(bool enabled);
    event TokensMinted(address indexed to, uint256 amount);
    event BatchMintCompleted(uint256 recipientCount);
    event MintingDisabledPermanently();
}