//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


/**
 * @title ERC900 Simple Staking Interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md
 */
abstract contract Staking {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    struct Stake {
        uint256 amount;
        uint256 stakedOn;
        uint256 stakedYears;
        uint256 noPenaltyAfter;
        uint256 rewarded;
    }

    struct Reward {
        uint256 amount;
        uint256 rewardedOn; 
    }

    struct Token {
        address tokenAddress;
        string symbol;
        uint8 precision;
    }

    struct Unstake {
        uint256 amount;
        uint256 canWithdrawAt;
    }

    mapping(address => mapping(address => Counters.Counter)) public stakeCounters;
    mapping(address => mapping(address => mapping(uint256 => Stake))) public stakes;
    mapping(address => Token) public tokens;
    mapping(address => mapping(address => mapping(uint256 => Reward))) public rewards;
    mapping(address => mapping(address => Counters.Counter)) public unstakeCounters;
    mapping(address => mapping(address => mapping(uint256 => Unstake))) public wallet;

    event Staked(address indexed user, uint256 amount, uint256 stakedOn);
    event Unstaked(address indexed user, uint256 amount, uint256 unstakedOn);
    event Withdraw(address indexed user, uint256 amount, uint256 withdrawOn);
    event WithdrawRewards( address indexed user, uint256 amount, uint256 withdrawOn);
    event StakeRewards(address indexed user, uint256 amount, uint256 total, uint256 stakedOn);
    event WithdrawReserve(address indexed user, uint256 amount, uint256 newBalance);
    event BurnedToken(address indexed user, uint256 amount);

    /*
    * @notice returns a list of the stakes for the given accouunt
    * @dev use this to iterate the stakes
    * @param _tokenAddress ERC20 token address
    * @param _user user wallet address
    */
    function stakesFor(address _tokenAddress, address _user)
    external view returns (Stake[] memory) {
        uint256 index = stakeCounters[_tokenAddress][_user].current();
        Stake[] memory entries = new Stake[](index);
        for(uint256 i = 0; i < index; i++) {
            entries[i] = stakes[_tokenAddress][_user][i+1];
        }
        return entries;
    }

    /*
    * @notice returns a list of the unstakes for the given accouunt
    * @dev use this to iterate the unstakes
    * @param _tokenAddress ERC20 token address
    * @param _user user wallet address
    */
    function unstakesFor(address _tokenAddress, address _user)
    external view returns (Unstake[] memory) {
        uint256 index = unstakeCounters[_tokenAddress][_user].current();
        Unstake[] memory entries = new Unstake[](index);
        for(uint256 i = 0; i < index; i++) {
            entries[i] = wallet[_tokenAddress][_user][i+1];
        }
        return entries;
    }

    /*
    * @notice returns the current amount of stakes available for the account
    * @dev use this to iterate the stakes mapping
    * @param _tokenAddress ERC20 token address
    */
    function countStakes(address _tokenAddress) external view returns (uint256) {
        return stakeCounters[_tokenAddress][msg.sender].current();
    }

    /*
    * @notice returns how many times the account has unstaked
    * @dev use this to iterate the wallet mapping
    * @param _tokenAddress ERC20 token address
    */
    function countUnstakes(address _tokenAddress) external view returns (uint256) {
        return unstakeCounters[_tokenAddress][msg.sender].current();
    }

    /*
     * @notice checks if address have the required tokens
     * @param _tokenAddress ERC20 token address
     * @param _sender user wallet address
     * @param _deligate recipient wallet
     * @param _amount amout of token being transferred
     */
    function isAllowed(address _tokenAddress, address _sender, address _deligate, uint256 _amount) internal view returns (bool) {
        return  IERC20(_tokenAddress).allowance(_sender, _deligate) >= _amount;
    }
}