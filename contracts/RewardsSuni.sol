pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Victor Fage <victorfage@gmail.com>
 */
contract RewardsSuni is Ownable {
    using SafeERC20 for IERC20;

    // Events

    event SetReward(
        address sender,
        uint256 amount
    );

    event EmergencyWithdraw(
        address sender,
        IERC20 token,
        uint256 amount
    );

    event ClaimAirdrop(
        address indexed sender
    );

    // Storage

    /// @dev Store the users who already claim your rewards
    mapping(address => bool) private claimedAddress;

    /// @notice The reward ERC20 token
    IERC20 public immutable rewardToken;

    /// @notice The amount of the ERC20 token reward, can be set by setReward funcion, only the contract owner can set this
    uint256 public rewardAmount;

    /**
     * @param _rewardToken The reward ERC20 token
     * @param _rewardAmount The amount of the ERC20 token reward
     */
    constructor(IERC20 _rewardToken, uint256 _rewardAmount) {
        rewardToken = _rewardToken;
        _setReward(_rewardAmount);
    }

    /**
     * @dev Returns if the claimer was claimed the reward
     *
     * @param _claimer The claimant to consult
     */
    function canClaim(address _claimer) public view returns (bool) {
        return !claimedAddress[_claimer];
    }

    /**
     * @dev Use to claim the airdrop
     *
     * Requirements:
     *
     * - The caller must dont have claimed before(claimedAddress must be false)
     * - The contract must have balance of reward ERC20 token
     */
    function claimAirdrop() external {
        address sender = msg.sender;

        require(!claimedAddress[sender], "Airdrop::claimAirdrop: The sender has already claimed the tokens");
        claimedAddress[sender] = true;

        rewardToken.safeTransfer(sender, rewardAmount);

        emit ClaimAirdrop(sender);
    }

    // OnlyOwner functions

    /**
     * @dev Use set the amount of the airdrop reward
     *
     * @param _rewardAmount The amount of reward ERC20 token
     *
     * Requirements:
     *
     * - Only the owner can send this function
     */
    function setReward(uint256 _rewardAmount) external onlyOwner {
        
        _setReward(_rewardAmount);
    }

    /**
     * @dev Set the amount of the airdrop reward
     *
     * @param _rewardAmount The amount of reward ERC20 token
     *
     * Requirements:
     *
     * - Only the owner can send this function
     */
    function _setReward(uint256 _rewardAmount) internal {
        rewardAmount = _rewardAmount;

        emit SetReward(msg.sender, _rewardAmount);
    }

    /**
     * @dev Use to withdraw ERC20 tokens or ETH in emergency cases
     *
     * @param _token The ERC20 token, if is address 0, ETH currency
     * @param _amount The amount of ERC20 token or ETH
     *
     * Requirements:
     *
     * - Only the owner can send this function
     */
    function emergencyWithdraw(IERC20 _token, uint256 _amount) external onlyOwner {
        address sender = msg.sender;

        if (address(_token) != address(0))
            _token.safeTransfer(sender, _amount);
        else
            payable(sender).transfer(_amount);

        emit EmergencyWithdraw(sender, _token, _amount);
    }

}
