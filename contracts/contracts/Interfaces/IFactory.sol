// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFactory {
    event PoolSet(address indexed from, address indexed to);
    event Whitelist(address indexed token);
    event Newpool(address indexed token, address indexed pool);

    function setPool(address _pool) external returns (bool);

    function whitelistToken(address _token) external returns (bool);

    function createPool(address _token) external returns (address);

    function getPool(address _token) external view returns (address);

    function getToken(address _pool) external view returns (address);

    function getTokenWihId(uint256 _token_id) external view returns (address);
}
