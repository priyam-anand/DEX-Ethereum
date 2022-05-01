// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IFactory} from "./Interfaces/IFactory.sol";

contract Factory is IFactory {

    event ExchangeSet(address indexed from, address indexed to);
    event Whitelist(address indexed token);
    event NewExchange(address indexed token, address indexed exchange);

    address public owner;
    address public exchange;
    uint256 public tokenId;
    mapping(address => address) tokenToExchange;
    mapping(address => address) exchangeToToken;
    mapping(uint256 => address) idToToken;
    mapping(address => bool) public whitelist;

    string invalidAddress = "Factory: Invalid Address";

    constructor() {
        tokenId = 0;
        owner = msg.sender;
    }

    function setExchange(address _exchange) external onlyOwner returns (bool) {
        require(_exchange != address(0), invalidAddress);
        require(_exchange != exchange, invalidAddress);
        emit ExchangeSet(exchange, _exchange);
        exchange = _exchange;

        return true;
    }

    function whitelistToken(address _token) external onlyOwner returns (bool) {
        require(_token != address(0) && !whitelist[_token], invalidAddress);
        whitelist[_token] = true;
        emit Whitelist(_token);

        return true;
    }

    function createExchange(address _token)
        external
        exchangeSet
        returns (address)
    {}

    // GETTERS
    function getExchange(address _token) external view returns (address) {
        return tokenToExchange[_token];
    }

    function getToken(address _exchange) external view returns (address) {
        return exchangeToToken[_exchange];
    }

    function getTokenWihId(uint256 _id) external view returns (address) {
        return idToToken[_id];
    }

    // MODIFIERS
    modifier exchangeSet() {
        require(exchange != address(0), "Factory: Exchange template not set");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Factory: Only Owner");
        _;
    }
}
