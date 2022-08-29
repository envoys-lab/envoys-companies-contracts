// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EOACallable {

    modifier notContract {
        uint32 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }
        require (size == 0, "EOACallable: Call from contract");
        require(msg.sender == tx.origin, "EOACallable: Mismatch between msg and tx sender");
        _;
    }
}