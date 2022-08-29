// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./core/ERC20.sol";
import "./interfaces/IEnvoysKycOracle.sol";

contract EnvoysTokenizedShare is ERC20 {
    IEnvoysKycOracle kycOracle;

    constructor(
        string memory _name, 
        string memory _symbol, 
        uint8 _decimals,
        IEnvoysKycOracle _kycOracle
    ) ERC20(
        _name, 
        _symbol, 
        _decimals
    ) {
        kycOracle = _kycOracle;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(kycOracle.allowed(from, address(this)), "EnvoysTokenizedShare: Sender not verified");
        require(kycOracle.allowed(to, address(this)), "EnvoysTokenizedShare: Receiver not verified");
        super._transfer(from, to, amount);
    }
}
