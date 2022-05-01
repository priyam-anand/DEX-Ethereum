// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFactory {
    event ExchangeSet(address indexed from, address indexed to);
    event Whitelist(address indexed token);
    event NewExchange(address indexed token, address indexed exchange);

    function setExchange(address _exchange) external returns (bool);

    function whitelistToken(address _token) external returns (bool);

    function createExchange(address _token) external returns (address);

    function getExchange(address _token) external view returns (address);

    function getToken(address _exchange) external view returns (address);

    function getTokenWihId(uint256 _token_id) external view returns (address);
}
