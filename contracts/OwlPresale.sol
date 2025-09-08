// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract OwlPresale {
    address public owner;
    address public owlToken;
    address public usdtToken;
    
    uint256 public pricePerToken; // Price in wei per OWL token (e.g., 1e18 = 1 ETH per token)
    uint256 public constant CAP = 1_000_000_000 * 1e18; // 1B OWL tokens
    uint256 public totalSold;
    bool public tgeStarted;
    bool public claimEnabled;
    bool public paused;
    
    mapping(address => uint256) public purchased;
    mapping(address => uint256) public claimed;
    
    event TokensPurchased(address indexed buyer, uint256 tokenAmount, uint256 paidAmount, string paymentMethod);
    event TokensClaimed(address indexed buyer, uint256 amount);
    event TGEStarted();
    event ClaimEnabled();
    event PriceUpdated(uint256 newPrice);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }
    
    constructor(
        address _owlToken,
        address _usdtToken,
        uint256 _pricePerToken
    ) {
        require(_owlToken != address(0) && _usdtToken != address(0), "Invalid addresses");
        require(_pricePerToken > 0, "Invalid price");
        
        owner = msg.sender;
        owlToken = _owlToken;
        usdtToken = _usdtToken;
        pricePerToken = _pricePerToken;
    }
    
    // Buy tokens by specifying the amount of tokens you want
    function buyTokens(uint256 tokenAmount) external payable whenNotPaused {
        require(!tgeStarted, "TGE started");
        require(tokenAmount > 0, "Invalid amount");
        require(totalSold + tokenAmount <= CAP, "Cap exceeded");
        
        uint256 ethRequired = (tokenAmount * pricePerToken) / 1e18;
        require(msg.value >= ethRequired, "Insufficient ETH");
        
        // Update state
        purchased[msg.sender] += tokenAmount;
        totalSold += tokenAmount;
        
        // Transfer ETH to owner
        payable(owner).transfer(ethRequired);
        
        // Refund excess ETH
        if (msg.value > ethRequired) {
            payable(msg.sender).transfer(msg.value - ethRequired);
        }
        
        // Auto-claim if enabled
        if (tgeStarted && claimEnabled) {
            (bool tokenSuccess, bytes memory tokenData) = owlToken.call(
                abi.encodeWithSignature("transfer(address,uint256)", msg.sender, tokenAmount)
            );
            require(tokenSuccess && (tokenData.length == 0 || abi.decode(tokenData, (bool))), "Transfer failed");
            claimed[msg.sender] += tokenAmount;
            emit TokensClaimed(msg.sender, tokenAmount);
        }
        
        emit TokensPurchased(msg.sender, tokenAmount, ethRequired, "ETH");
    }
    
    // Buy with USDT by specifying token amount
    function buyTokensWithUSDT(uint256 tokenAmount) external whenNotPaused {
        require(!tgeStarted, "TGE started");
        require(tokenAmount > 0, "Invalid amount");
        require(totalSold + tokenAmount <= CAP, "Cap exceeded");
        
        uint256 usdtRequired = (tokenAmount * pricePerToken) / 1e18;
        
        // Transfer USDT from buyer to owner
        (bool usdtSuccess, bytes memory usdtData) = usdtToken.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, owner, usdtRequired)
        );
        require(usdtSuccess && (usdtData.length == 0 || abi.decode(usdtData, (bool))), "USDT transfer failed");
        
        // Update state
        purchased[msg.sender] += tokenAmount;
        totalSold += tokenAmount;
        
        // Auto-claim if enabled
        if (tgeStarted && claimEnabled) {
            (bool owlSuccess, bytes memory owlData) = owlToken.call(
                abi.encodeWithSignature("transfer(address,uint256)", msg.sender, tokenAmount)
            );
            require(owlSuccess && (owlData.length == 0 || abi.decode(owlData, (bool))), "Transfer failed");
            claimed[msg.sender] += tokenAmount;
            emit TokensClaimed(msg.sender, tokenAmount);
        }
        
        emit TokensPurchased(msg.sender, tokenAmount, usdtRequired, "USDT");
    }
    
    // Claim purchased tokens after TGE
    function claimTokens() external {
        require(tgeStarted && claimEnabled, "Claiming not available");
        
        uint256 claimable = purchased[msg.sender] - claimed[msg.sender];
        require(claimable > 0, "Nothing to claim");
        
        claimed[msg.sender] += claimable;
        (bool claimSuccess, bytes memory claimData) = owlToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", msg.sender, claimable)
        );
        require(claimSuccess && (claimData.length == 0 || abi.decode(claimData, (bool))), "Transfer failed");
        
        emit TokensClaimed(msg.sender, claimable);
    }
    
    // Owner functions
    function setPrice(uint256 _pricePerToken) external onlyOwner {
        require(_pricePerToken > 0, "Invalid price");
        pricePerToken = _pricePerToken;
        emit PriceUpdated(_pricePerToken);
    }
    
    function startTGE() external onlyOwner {
        require(!tgeStarted, "Already started");
        tgeStarted = true;
        emit TGEStarted();
    }
    
    function enableClaim() external onlyOwner {
        require(tgeStarted, "TGE not started");
        claimEnabled = true;
        emit ClaimEnabled();
    }
    
    function togglePause() external onlyOwner {
        paused = !paused;
    }
    
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    function withdrawToken(address token) external onlyOwner {
        (bool balanceSuccess, bytes memory balanceData) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        require(balanceSuccess, "Balance check failed");
        uint256 balance = abi.decode(balanceData, (uint256));
        
        if (balance > 0) {
            (bool withdrawSuccess, bytes memory withdrawData) = token.call(
                abi.encodeWithSignature("transfer(address,uint256)", owner, balance)
            );
            require(withdrawSuccess && (withdrawData.length == 0 || abi.decode(withdrawData, (bool))), "Transfer failed");
        }
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
    
    // View functions
    function getETHCost(uint256 tokenAmount) external view returns (uint256) {
        return (tokenAmount * pricePerToken) / 1e18;
    }
    
    function getUSDTCost(uint256 tokenAmount) external view returns (uint256) {
        return (tokenAmount * pricePerToken) / 1e18;
    }
    
    function getClaimableTokens(address user) external view returns (uint256) {
        return purchased[user] - claimed[user];
    }
    
    function getRemainingTokens() external view returns (uint256) {
        return CAP - totalSold;
    }
}