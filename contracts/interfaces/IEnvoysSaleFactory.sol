// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IEnvoysSaleFactory {
    function feeTo() external view returns (address);
    function fee() external view returns (uint256);
}
