// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Lockable {
    uint8 private _locked;
    modifier lock {
        require(_locked == 0, "Lockable: Permission denied");
        _locked = 1;
        _;
        _locked = 0;
    }
}
