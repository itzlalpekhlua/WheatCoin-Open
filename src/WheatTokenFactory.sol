// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Fixed-supply community token created through the official factory.
contract WheatCommunityToken is ERC20, ERC20Burnable {
    address public immutable creator;

    constructor(string memory name_, string memory symbol_, uint256 supply_, address creator_) ERC20(name_, symbol_) {
        creator = creator_;
        _mint(creator_, supply_ * 1 ether);
    }
}

/// @notice Permissionless registry and deployer for WheatCoin Mainnet community tokens.
contract WheatTokenFactory is Ownable {
    struct TokenRecord {
        address token;
        address creator;
        string name;
        string symbol;
        uint256 supply;
        uint256 blockNumber;
    }

    uint256 public constant MAX_SUPPLY = 1_000_000_000_000;
    uint256 public creationFee;
    address payable public feeRecipient;
    TokenRecord[] private _tokens;
    mapping(address => bool) public isFactoryToken;

    error InvalidName();
    error InvalidSymbol();
    error InvalidSupply();
    error IncorrectFee();
    error FeeTransferFailed();
    error ZeroAddress();

    event TokenCreated(address indexed token, address indexed creator, string name, string symbol, uint256 supply);
    event CreationFeeUpdated(uint256 oldFee, uint256 newFee);
    event FeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);

    constructor(address owner_, address payable feeRecipient_, uint256 creationFee_) Ownable(owner_) {
        if (feeRecipient_ == address(0)) revert ZeroAddress();
        feeRecipient = feeRecipient_;
        creationFee = creationFee_;
    }

    function createToken(string calldata name_, string calldata symbol_, uint256 supply_)
        external
        payable
        returns (address token)
    {
        uint256 nameLength = bytes(name_).length;
        uint256 symbolLength = bytes(symbol_).length;
        if (nameLength < 2 || nameLength > 40) revert InvalidName();
        if (symbolLength < 2 || symbolLength > 10) revert InvalidSymbol();
        if (supply_ == 0 || supply_ > MAX_SUPPLY) revert InvalidSupply();
        if (msg.value != creationFee) revert IncorrectFee();

        token = address(new WheatCommunityToken(name_, symbol_, supply_, msg.sender));
        isFactoryToken[token] = true;
        _tokens.push(TokenRecord(token, msg.sender, name_, symbol_, supply_, block.number));

        (bool sent,) = feeRecipient.call{value: msg.value}("");
        if (!sent) revert FeeTransferFailed();
        emit TokenCreated(token, msg.sender, name_, symbol_, supply_);
    }

    function tokenCount() external view returns (uint256) {
        return _tokens.length;
    }

    function tokenAt(uint256 index) external view returns (TokenRecord memory) {
        return _tokens[index];
    }

    function tokens(uint256 offset, uint256 limit) external view returns (TokenRecord[] memory page) {
        uint256 count = _tokens.length;
        if (offset >= count || limit == 0) return new TokenRecord[](0);
        uint256 end = offset + limit;
        if (end > count) end = count;
        page = new TokenRecord[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            page[i - offset] = _tokens[i];
        }
    }

    function setCreationFee(uint256 newFee) external onlyOwner {
        emit CreationFeeUpdated(creationFee, newFee);
        creationFee = newFee;
    }

    function setFeeRecipient(address payable newRecipient) external onlyOwner {
        if (newRecipient == address(0)) revert ZeroAddress();
        emit FeeRecipientUpdated(feeRecipient, newRecipient);
        feeRecipient = newRecipient;
    }
}
