// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {AccessControlDefaultAdminRules} from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

/// @notice A configurable capped token for an independently operated EVM network.
contract OwnCoin is ERC20, ERC20Burnable, ERC20Capped, ERC20Pausable, AccessControlDefaultAdminRules {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    error ZeroAddress();
    error InvalidSupply();

    constructor(
        string memory name_,
        string memory symbol_,
        address admin,
        address treasury,
        uint256 initialSupply,
        uint256 maxSupply
    )
        ERC20(name_, symbol_)
        ERC20Capped(maxSupply)
        AccessControlDefaultAdminRules(2 days, admin)
    {
        if (admin == address(0) || treasury == address(0)) revert ZeroAddress();
        if (maxSupply == 0 || initialSupply > maxSupply) revert InvalidSupply();
        _grantRole(MINTER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _mint(treasury, initialSupply);
    }

    function mint(address recipient, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(recipient, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Capped, ERC20Pausable) {
        super._update(from, to, value);
    }
}
