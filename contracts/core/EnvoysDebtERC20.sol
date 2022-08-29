// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EnvoysDebtERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;

    function _installToken(string memory name_, string memory symbol_) internal {
        _name = name_;
        _symbol = symbol_;
    }

    function _setDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }


    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
    }

    function allowance(address, address) public view virtual returns (uint256) {
        return 0;
    }

    function approve(address, uint256) public virtual returns (bool) {
        revert("EnvoysDebtErc20: approve not allowed");
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        _transfer(from, to, amount);
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal virtual {
        revert("EnvoysDebtErc20: transfer not allowed");
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }
}