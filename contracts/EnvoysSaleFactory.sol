// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IEnvoysFactory.sol";
import "./core/Adminable.sol";
import "./EnvoysSale.sol";
import "./core/SaleInfo.sol";
import "./core/Lockable.sol";

contract EnvoysSaleFactory is Adminable, Lockable {
    event FeeSettingsChanged(address currentFeeTo, uint256 currentFee);

    mapping(address => address) public sales;

    address public feeTo;
    uint256 public fee;

    function delegateCreate(
        SaleInfo memory saleInfo, 
        address owner, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external lock returns (address) {
        bytes32 hashedMessage = keccak256(abi.encodePacked(
            saleInfo.token,
            saleInfo.soft,
            saleInfo.hard,
            saleInfo.buyToken,
            saleInfo.price,
            saleInfo.start,
            saleInfo.end,
            owner
        ));

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hashedMessage));
        address signer = ecrecover(prefixedHashMessage, v, r, s);
        
        require(signer == admin, "EnvoysSaleFactory: Invalid signature");
        return _create(saleInfo, owner);
    }

    function create(
        SaleInfo memory saleInfo,
        address owner
    ) external lock onlyAdmin returns (address) {
        return _create(saleInfo, owner);
    }

    function _create(
        SaleInfo memory saleInfo,
        address owner
    ) internal returns (address) {
        address _token = saleInfo.token;
        EnvoysSale _sale = new EnvoysSale(saleInfo, owner);
        sales[_token] = address(_sale);
        IERC20 token = IERC20(saleInfo.token);

        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= saleInfo.hard, "EnvoysSaleFactory: Insufficient allowance to transfer tokens");
        token.transferFrom(msg.sender, address(_sale), saleInfo.hard);
        _sale.deposit(0);

        return sales[_token];
    }

    function _changeFeeSettings(address _newFeeTo, uint256 _newFee) internal {
        feeTo = _newFeeTo;
        fee = _newFee;
        emit FeeSettingsChanged(feeTo, fee);
    }

    function setFeeTo(address _newFeeTo) external onlyAdmin {
        _changeFeeSettings(_newFeeTo, fee);
    }

    function setFee(uint256 _newFee) external onlyAdmin {
        require(_newFee <= 10000, "EnvoysSaleFactory: Max fee 1000");
        _changeFeeSettings(feeTo, _newFee);
    }
}
