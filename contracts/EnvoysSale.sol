// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IEnvoysFactory.sol";
import "./interfaces/IEnvoysSaleFactory.sol";
import "./core/TokenInput.sol";
import "./core/SaleInfo.sol";
import "./core/SafeMath.sol";
import "./core/Lockable.sol";
import "./core/EnvoysDebtERC20.sol";
import "hardhat/console.sol";


contract EnvoysSale is TokenInput, Lockable, EnvoysDebtERC20 {
    event Claimed(uint256 tokens, uint256 receiveBuyTokens);
    using SafeMath for uint256;

    SaleInfo public saleInfo;
    IEnvoysSaleFactory public factory;

    uint8 constant public PHASE_SALE = 0;
    uint8 constant public PHASE_SALE_END = 1;
    uint8 constant public PHASE_CLOSED = 2;
    uint8 public phase = 0;
    uint256 public available = 0;

    bool public activated = false;

    mapping(address => uint256) public receives;
    uint256 public totalReceived;
    address public owner;

    constructor(
        SaleInfo memory _saleInfo,
        address _owner
    ) {
        string memory n = IERC20(_saleInfo.token).name();
        string memory s = IERC20(_saleInfo.token).symbol();
        uint8 d = IERC20(_saleInfo.token).decimals();
        string memory name = string(abi.encodePacked("Envoys Debt ", n));
        string memory symbol = string(abi.encodePacked("ed", s));
        _installToken(name, symbol);
        _setDecimals(d);

        saleInfo = _saleInfo;
        factory = IEnvoysSaleFactory(msg.sender);
        owner = _owner;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal virtual override {
        revert("EnvoysSale: Transfer not allowed");
    }

    function buy(uint256 amount) external input(saleInfo.buyToken) lock {
        require(activated, "EnvoysSale: Sale not activated");
        require(amount >= 1e8, "EnvoysSale: Minimum purchase 1e8");
        require(amount <= available, "EnvoysSale: Max purchase limit overflowed");
        SaleInfo memory info = saleInfo;
        require(
            isStarted() && 
            !isFinished(), 
            "EnvoysSale: Sale not started or finished"
        );


        IERC20(info.buyToken).transferFrom(msg.sender, address(this), amount);
        uint256 received = getInput(info.buyToken);
        require(received > 1e8, "EnvoysSale: Minimum received 1e8");

        uint256 fee = factory.fee();
        address feeTo = factory.feeTo();
        if(fee > 0 && feeTo != address(0)) {
            uint256 feeAmount = received.mul(fee).div(10000);
            received = received.sub(feeAmount);
            IERC20(info.buyToken).transfer(feeTo, feeAmount);
        }

        uint256 decimals = IERC20(info.token).decimals();
        uint256 tokens = received.mul(10 ** decimals).div(info.price);

        _mint(msg.sender, tokens);
        receives[msg.sender] = received;
        totalReceived += received;
    }

    function deposit(uint256 amount) external lock {
        require(!activated, "EnvoysSale: Already activated");
        if(amount > 0) {
            IERC20(saleInfo.token).transferFrom(msg.sender, address(this), amount);
        }
        uint256 balance = IERC20(saleInfo.token).balanceOf(address(this));
        require(balance >= saleInfo.hard, "EnvoysSale: Not enough tokens");

        available += balance;
        activated = true;
    }

    function claim() external lock {
        require(isFinished(), "EnvoysSale: Sale not finished");

        if(!isSuccess()) {
            IERC20(saleInfo.buyToken).transfer(msg.sender, receives[msg.sender]);
            emit Claimed(0, receives[msg.sender]);
        } else {
            IERC20(saleInfo.token).transfer(msg.sender, balanceOf(msg.sender));
            emit Claimed(balanceOf(msg.sender), 0);
        }
        
        receives[msg.sender] = 0;
        _burn(msg.sender, balanceOf(msg.sender));
    }

    function isFinished() internal view returns (bool) {
        return saleInfo.end < block.timestamp;
    }

    function isStarted() internal view returns (bool) {
        return saleInfo.start < block.timestamp;
    }

    function isSuccess() internal view returns (bool) {
        return totalReceived >= saleInfo.soft;
    }

    function withdraw() external lock {
        require(msg.sender == owner, "EnvoysSale: Only owner");
        require(isFinished(), "EnvoysSale: Sale not finished");

        if(!isSuccess()) {
            IERC20(saleInfo.token).transfer(msg.sender, IERC20(saleInfo.token).balanceOf(address(this)));
        } else {
            IERC20(saleInfo.buyToken).transfer(msg.sender, IERC20(saleInfo.buyToken).balanceOf(address(this)));
        }
    }

}
