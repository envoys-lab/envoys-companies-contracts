// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./core/AirdropInfo.sol";
import "./core/Adminable.sol";
import "./core/Lockable.sol";
import "./interfaces/IERC20.sol";
import "./EnvoysAirdrop.sol";

contract EnvoysAirdropFactory is Adminable, Lockable {
    mapping(address => address) public airdrops;
    uint8 public difficulty = 5;

    function delegateCreate(
        AirdropInfo memory airdropInfo, 
        uint256 amount,
        address owner, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (address) {
        bytes32 hashedMessage = keccak256(abi.encodePacked(
            airdropInfo.token,
            airdropInfo.amount,
            airdropInfo.start,
            airdropInfo.end,
            owner
        ));

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hashedMessage));
        address signer = ecrecover(prefixedHashMessage, v, r, s);
        
        require(signer == admin, "EnvoysSaleFactory: Invalid signature");
        
        return _create(airdropInfo, amount, owner);
    }

    function create(
        AirdropInfo memory airdropInfo,
        uint256 amount,
        address owner
    ) external lock onlyAdmin returns (address) {
        return _create(airdropInfo, amount, owner);
    }

    function _create(
        AirdropInfo memory airdropInfo,
        uint256 amount,
        address owner
    ) internal returns (address) {
        address _token = airdropInfo.token;
        EnvoysAirdrop _airdrop = new EnvoysAirdrop(airdropInfo, owner);
        airdrops[_token] = address(_airdrop);
        IERC20 token = IERC20(airdropInfo.token);

        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "EnvoysSaleFactory: Insufficient allowance to transfer tokens");
        token.transferFrom(msg.sender, address(_airdrop), amount);

        return airdrops[_token];
    }

    function setDifficulty(uint8 newDifficulty) external {
        difficulty = newDifficulty;
    }

    function getDifficulty() external view returns (uint8) {
        return difficulty;
    }
}
