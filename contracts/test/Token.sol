// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../core/EnvoysDebtERC20.sol";

contract Token is EnvoysDebtERC20 {
    constructor(string memory name, string memory symbol) {
        _installToken(name, symbol);
        _setDecimals(18);
    }

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}