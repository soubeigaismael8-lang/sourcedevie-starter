// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LifePoints is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
    address public usdcAddress;
    uint256 public constant POINTS_PER_USDC = 100; // 1 USDC = 100 LifePoints
    uint256 public constant TRANSFER_FEE = 1; // 1% transfer fee
    
    mapping(address => uint256) public lastTransferTime;
    mapping(address => bool) public whitelistedAddresses;
    
    event PointsAwarded(address indexed user, uint256 amount);
    event USDCReceived(address indexed user, uint256 usdcAmount, uint256 pointsAwarded);
    event TokensBurned(address indexed user, uint256 amount);
    event AddressWhitelisted(address indexed address_);
    event AddressRemovedFromWhitelist(address indexed address_);
    
    modifier onlyWhitelisted() {
        require(whitelistedAddresses[msg.sender], "LifePoints: Address is not whitelisted");
        _;
    }
    
    modifier transferCooldown() {
        require(block.timestamp >= lastTransferTime[msg.sender].add(1 hours), "LifePoints: Transfer cooldown active");
        _;
        lastTransferTime[msg.sender] = block.timestamp;
    }
    
    constructor(address _usdcAddress) ERC20("LifePoints", "LIFE") Ownable(msg.sender) {
        usdcAddress = _usdcAddress;
        _mint(msg.sender, 1000000 * 10**18); // Initial supply for owner
    }
    
    function awardPoints(address user, uint256 amount) external onlyOwner nonReentrant {
        require(user != address(0), "LifePoints: Cannot award points to zero address");
        require(amount > 0, "LifePoints: Amount must be greater than 0");
        
        _mint(user, amount);
        emit PointsAwarded(user, amount);
    }
    
    function payWithUSDC(address user, uint256 usdcAmount) external nonReentrant {
        require(usdcAmount > 0, "LifePoints: USDC amount must be greater than 0");
        require(user != address(0), "LifePoints: Cannot award points to zero address");
        
        // Calculate points to award (1 USDC = 100 LifePoints)
        uint256 pointsToAward = usdcAmount.mul(POINTS_PER_USDC);
        
        // Transfer USDC from user to this contract
        bool success = IERC20(usdcAddress).transferFrom(user, address(this), usdcAmount);
        require(success, "LifePoints: USDC transfer failed");
        
        // Mint LifePoints to user
        _mint(user, pointsToAward);
        
        emit USDCReceived(user, usdcAmount, pointsToAward);
    }
    
    function burnTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "LifePoints: Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "LifePoints: Insufficient balance");
        
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
    
    function transfer(address to, uint256 amount) public override transferCooldown returns (bool) {
        uint256 fee = amount.mul(TRANSFER_FEE).div(100);
        uint256 amountAfterFee = amount.sub(fee);
        
        _transfer(msg.sender, to, amountAfterFee);
        if (fee > 0) {
            _transfer(msg.sender, owner(), fee);
        }
        
        return true;
    }
    
    function addToWhitelist(address address_) external onlyOwner {
        require(address_ != address(0), "LifePoints: Cannot whitelist zero address");
        require(!whitelistedAddresses[address_], "LifePoints: Address already whitelisted");
        
        whitelistedAddresses[address_] = true;
        emit AddressWhitelisted(address_);
    }
    
    function removeFromWhitelist(address address_) external onlyOwner {
        require(address_ != address(0), "LifePoints: Cannot remove zero address");
        require(whitelistedAddresses[address_], "LifePoints: Address not whitelisted");
        
        whitelistedAddresses[address_] = false;
        emit AddressRemovedFromWhitelist(address_);
    }
    
    function setTransferFee(uint256 newFee) external onlyOwner {
        require(newFee <= 10, "LifePoints: Fee cannot exceed 10%");
        TRANSFER_FEE = newFee;
    }
    
    function withdrawUSDC(uint256 amount) external onlyOwner {
        require(amount > 0, "LifePoints: Amount must be greater than 0");
        require(IERC20(usdcAddress).balanceOf(address(this)) >= amount, "LifePoints: Insufficient USDC balance");
        
        IERC20(usdcAddress).transfer(owner(), amount);
    }
    
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
