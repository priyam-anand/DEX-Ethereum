// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IFactory} from "./Interfaces/IFactory.sol";
import {Pool} from "./Pool.sol";

contract Factory is IFactory {
    address public owner;
    uint256 public poolId;
    mapping(address => address) tokenToPool;
    mapping(address => address) poolToToken;
    mapping(uint256 => address) idToToken;
    mapping(address => bool) public whitelist;

    string invalidAddress = "Factory: Invalid Address";

    constructor() {
        poolId = 0;
        owner = msg.sender;
    }

    function whitelistToken(address _token) external onlyOwner returns (bool) {
        require(_token != address(0) && !whitelist[_token], invalidAddress);
        whitelist[_token] = true;
        emit Whitelist(_token);

        return true;
    }

    function createPool(address _token) external returns (address) {
        require(whitelist[_token], "Factory: Not whitelisted");
        require(_token != address(0), invalidAddress);
        require(
            tokenToPool[_token] == address(0),
            "Factory: Pool with same token exist"
        );
        Pool _pool = new Pool(_token, address(this));
        tokenToPool[_token] = address(_pool);
        poolToToken[address(_pool)] = _token;
        poolId++;
        idToToken[poolId] = _token;
        emit Newpool(_token, address(_pool));
        return address(_pool);
    }

    // GETTERS
    function getPool(address _token) external view returns (address) {
        return tokenToPool[_token];
    }

    function getToken(address _pool) external view returns (address) {
        return poolToToken[_pool];
    }

    function getTokenWithId(uint256 _id) external view returns (address) {
        return idToToken[_id];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Factory: Only Owner");
        _;
    }
}
