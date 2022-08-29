// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Access {
    mapping(address => mapping(uint256 => bool)) private _permission;

    modifier onlyRole(uint256 role) {
        require(_permission[msg.sender][role], "Access: Permission denied");
        _;
    }

    function _setRole(address account, uint256 role, bool status) internal virtual {
        _permission[account][role] = status;
    }

    function permission(address account, uint256 role) external view returns (bool) {
        return _permission[account][role];
    }
}
