// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./core/Adminable.sol";
import "./interfaces/IEnvoysKycOracle.sol";

contract EnvoysKycOracle is Adminable, IEnvoysKycOracle {
    mapping(address => bool) public required;
    mapping(address => bool) public verified;
    mapping(address => bool) public controller;
    mapping(address => uint256) public nonce;

    constructor() {
        controller[msg.sender] = true;
    }

    function setController(address usr, bool status) external onlyAdmin {
        controller[usr] = status;
    }

    modifier onlyController {
        require(controller[msg.sender], "EnvoysKycOracle: Not controller");
        _;
    }

    function setRequired(address token, bool status) external onlyController {
        required[token] = status;
        emit KycRequiredChanged(token, status);
    }

    function verify(address usr, bool status) external onlyController {
        _verify(usr, status);
    }

    function allowed(address usr, address token) external view returns (bool) {
        return !required[token] || verified[usr];
    }

    function delegateVerify(address usr, bool status, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 hashedMessage = keccak256(abi.encodePacked(
            usr,
            status,
            nonce[usr]++
        ));

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hashedMessage));
        address signer = ecrecover(prefixedHashMessage, v, r, s);
        
        require(controller[signer], "EnvoysKycOracle: Invalid signature");
        _verify(usr, status);
    }

    function _verify(address usr, bool status) internal {
        verified[usr] = status;
        emit UserKycStatusChanged(usr, status);
    }
}