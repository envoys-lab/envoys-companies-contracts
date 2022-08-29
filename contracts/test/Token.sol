// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../core/ERC20.sol";

contract Token is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol, 18) {}

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}