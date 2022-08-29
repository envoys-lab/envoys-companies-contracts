// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./core/AirdropInfo.sol";
import "./core/EnvoysDebtERC20.sol";
import "./core/SafeMath.sol";
import "./core/EOACallable.sol";
import "./core/Lockable.sol";
import "./EnvoysAirdropFactory.sol";

contract EnvoysAirdrop is EOACallable, Lockable, EnvoysDebtERC20 {
    using SafeMath for uint256;
    address public owner;
    AirdropInfo public airdropInfo;
    uint256 public haravestedAmount = 0;
    address[] private _allocation;

    constructor(
        AirdropInfo memory _airdropInfo,
        address _owner
    ) {
        owner = _owner;
        airdropInfo = _airdropInfo;

        IERC20 t = IERC20(_airdropInfo.token);
        string memory n = t.name();
        string memory s = t.symbol();
        uint8 d = t.decimals();
        string memory name = string(abi.encodePacked("Envoys Airdrop ", n));
        string memory symbol = string(abi.encodePacked("ea", s));
        _installToken(name, symbol);
        _setDecimals(d);
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal virtual override {
        revert("EnvoysAirdrop: Transfer not allowed");
    }

    function airdrop() notContract lock external {
        require(_isStarted(), "EnvoysAirdrop: Airdrop not started");
        require(!_isFinished(), "EnvoysAirdrop: Airdrop finished");
        require(!_isReceived(msg.sender), "EnvoysAirdrop: Already received");
        require(
            _allocation.length.add(1).mul(airdropInfo.amount) <= _totalBalance(), 
            "EnvoysAirdrop: Not enough collateral"
        );

        _allocation.push(msg.sender);
        _mint(msg.sender, airdropInfo.amount);
    }

    function harvest() notContract lock external {
        require(_isFinished(), "EnvoysAirdrop: Airdrop not finished");

        uint256 toHarvest = balanceOf(msg.sender);
        require(toHarvest > 0, "EnvoysAirdrop: Nothing to harvest");
        haravestedAmount = haravestedAmount.add(toHarvest);
        _burn(msg.sender, toHarvest);
        IERC20(airdropInfo.token).transfer(msg.sender, toHarvest);
    }

    function refund() external lock {
        require(msg.sender == owner, "EnvoysAirdrop: Only owner");
        require(_isFinished(), "EnvoysAirdrop: Not finished");

        uint256 balance = _totalBalance();
        uint256 toHarvest = totalSupply();
        uint256 toRefund = balance.sub(toHarvest);
        require(toRefund > 0, "EnvoyAirdrop: Nothing to return");
        IERC20(airdropInfo.token).transfer(owner, toRefund);
    }

    function allocation(uint256 index) external view returns (address) {
        return _allocation[index];
    }

    function allocationLen() external view returns (uint256) {
        return _allocation.length;
    }

    function _isReceived(address account) internal view returns (bool) {
        return balanceOf(account) > 0;
    }

    function _totalBalance() internal view returns (uint256) {
        return (IERC20(airdropInfo.token).balanceOf(address(this))).add(haravestedAmount);
    } 

    function _isFinished() internal view returns (bool) {
        return airdropInfo.end < block.timestamp;
    }

    function _isStarted() internal view returns (bool) {
        return airdropInfo.start < block.timestamp;
    }
}
