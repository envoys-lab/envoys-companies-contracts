// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IERC20.sol";

struct SaleInfo {
    address token;
    uint256 soft;
    uint256 hard;
    address buyToken;
    uint256 price;
    
    uint256 start;
    uint256 end;
}
