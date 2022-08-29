// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IERC20.sol";

contract TokenInput {
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _unlock;

    modifier input(address token) {
        _unlock[token] = true;
        _balances[token] = IERC20(token).balanceOf(address(this));
        _;
        _balances[token] = 0;
        _unlock[token] = false;
    }

    function getInput(address token) internal view returns (uint256) {
        require(_unlock[token], "TokenInput: Not used modifier input");
        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        uint256 afterCallBalance = _balances[token];
        return currentBalance - afterCallBalance;
    }
}