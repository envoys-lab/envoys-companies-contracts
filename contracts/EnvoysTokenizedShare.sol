// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./core/ERC20.sol";
import "./core/Access.sol";
import "./core/Adminable.sol";
import "./interfaces/IEnvoysKycOracle.sol";

contract EnvoysTokenizedShare is ERC20, Adminable, Access {
    IEnvoysKycOracle kycOracle;

    uint256 constant public MINTER_ROLE = 0x1;
    uint256 constant public BURNER_ROLE = 0x2;

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

        _setRole(msg.sender, MINTER_ROLE, true);
        _setRole(msg.sender, BURNER_ROLE, true);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(kycOracle.allowed(from, address(this)), "EnvoysTokenizedShare: Sender not verified");
        require(kycOracle.allowed(to, address(this)), "EnvoysTokenizedShare: Receiver not verified");
        super._transfer(from, to, amount);
    }

    function mint(address account, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(account, amount);
    }

    function setRole(address account, uint256 role, bool status) external onlyAdmin {
        _setRole(account, role, status);
    }
}
