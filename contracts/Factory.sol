// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IFactory} from "./Interfaces/IFactory.sol";

contract Factory is IFactory {
    address public owner;
    address public pool;
    uint256 public tokenId;
    mapping(address => address) tokenToPool;
    mapping(address => address) poolToToken;
    mapping(uint256 => address) idToToken;
    mapping(address => bool) public whitelist;

    string invalidAddress = "Factory: Invalid Address";

    constructor() {
        tokenId = 0;
        owner = msg.sender;
    }

    function setPool(address _pool) external onlyOwner returns (bool) {
        require(_pool != address(0), invalidAddress);
        require(_pool != pool, invalidAddress);
        emit PoolSet(pool, _pool);
        pool = _pool;

        return true;
    }

    function whitelistToken(address _token) external onlyOwner returns (bool) {
        require(_token != address(0) && !whitelist[_token], invalidAddress);
        whitelist[_token] = true;
        emit Whitelist(_token);

        return true;
    }

    function createPool(address _token)
        external
        poolSet
        returns (address)
    {}

    // GETTERS
    function getPool(address _token) external view returns (address) {
        return tokenToPool[_token];
    }

    function getToken(address _pool) external view returns (address) {
        return poolToToken[_pool];
    }

    function getTokenWihId(uint256 _id) external view returns (address) {
        return idToToken[_id];
    }

    // MODIFIERS
    modifier poolSet() {
        require(pool != address(0), "Factory: pool template not set");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Factory: Only Owner");
        _;
    }
}
