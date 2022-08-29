// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IEnvoysKycOracle {
    function required(address) external view returns (bool);
    function verified(address) external view returns (bool);
    function allowed(address, address) external view returns (bool);
    function controller(address) external view returns (bool);
    function nonce(address) external view returns (uint256);

    event KycRequiredChanged(address token, bool status);
    event UserKycStatusChanged(address usr, bool status);
}