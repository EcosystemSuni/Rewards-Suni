pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Victor Fage <victorfage@gmail.com>
 */
contract RewardsSuni is Ownable {
    using SafeERC20 for IERC20;

    mapping(address => bool) private claimedAddress;

    IERC20 public rewardToken;

    uint256 public rewardAmount;

    constructor(IERC20 _rewardToken, uint256 _rewardAmount) {
        rewardToken = _rewardToken;
        rewardAmount = _rewardAmount;
    }

    function claimAirdrop() external {
        address sender = msg.sender;

        require(!claimedAddress[sender], "Airdrop::claimAirdrop: The sender has already claimed the tokens");
        claimedAddress[sender] = true;

        rewardToken.safeTransfer(sender, rewardAmount);
    }
}
