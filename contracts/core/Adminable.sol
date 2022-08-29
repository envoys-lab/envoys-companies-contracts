// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Adminable {
    event AdminChanged(address oldAdmin, address newAdmin);
    address public admin = msg.sender;

    modifier onlyAdmin {
        require(admin == msg.sender, "Adminable: Only admin");
        _;
    }

    function _setAdmin(address newAdmin) internal {
        require(newAdmin != address(0), "Adminable: New address is zero");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        _setAdmin(newAdmin);
    }
}
