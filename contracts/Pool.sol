//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IPool} from "./Interfaces/IPool.sol";
import {IFactory} from "./Interfaces/IFactory.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Pool is IPool, ERC20 {
    address private factoryAddress;
    IERC20 token;
    IFactory factory;

    string invalidInput = "Pool: INVALID_VALUE";

    constructor(address _tokenAddress)
        ERC20("Liquidity Provider Token", "LPT")
    {
        token = IERC20(_tokenAddress);
    }

    function getInputPrice(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public view returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, invalidInput);
        uint256 numerator = inputAmount * outputReserve;
        uint256 denominator = inputReserve + inputAmount;
        return numerator / denominator;
    }

    function getOutputPrice(
        uint256 output_amount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public view returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, invalidInput);
        uint256 numerator = inputReserve * output_amount;
        uint256 denominator = outputReserve - output_amount;
        return (numerator / denominator) + 1;
    }

    function ethToTokenSwapInput(uint256 minTokens, uint256 deadline)
        external
        payable
        returns (uint256)
    {
        require(
            msg.value > 0 && minTokens > 0 && deadline > block.timestamp,
            invalidInput
        );
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokensBought = getInputPrice(
            msg.value,
            ethReserve,
            tokenReserve
        );
        require(tokensBought >= minTokens, "Pool: Token yield too low");
        token.transfer(msg.sender, tokensBought);
        emit TokenPurchase(msg.sender, msg.value, tokensBought);
        return tokensBought;
    }

    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline)
        external
        payable
        returns (uint256)
    {
        require(
            tokensBought > 0 && msg.value > 0 && deadline > block.timestamp,
            invalidInput
        );
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 ethRequired = getOutputPrice(
            tokensBought,
            ethReserve,
            tokenReserve
        );
        require(ethRequired <= msg.value, "Pool: Token yeild too low");

        if (msg.value - ethRequired > 0)
            payable(msg.sender).transfer(msg.value - ethRequired);

        token.transfer(msg.sender, tokensBought);
        emit TokenPurchase(msg.sender, ethRequired, tokensBought);
        return ethRequired;
    }

    function tokenToEthSwapInput(
        uint256 tokensSold,
        uint256 minEth,
        uint256 deadline
    ) external returns (uint256) {
        require(
            deadline > block.timestamp && tokensSold > 0 && minEth > 0,
            invalidInput
        );
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        uint256 ethBought = getInputPrice(tokensSold, tokenReserve, ethReserve);
        require(ethBought >= minEth, "Pool: Eth yield too low");

        payable(msg.sender).transfer(ethBought);
        token.transferFrom(msg.sender, address(this), tokensSold);
        emit EthPurchase(msg.sender, tokensSold, ethBought);

        return ethBought;
    }

    function tokenToEthSwapOutput(
        uint256 ethBought,
        uint256 maxTokens,
        uint256 deadline
    ) external returns (uint256) {
        require(
            deadline > block.timestamp && maxTokens > 0 && ethBought > 0,
            invalidInput
        );
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        uint256 tokenRequired = getOutputPrice(
            ethBought,
            tokenReserve,
            ethReserve
        );

        require(tokenRequired <= maxTokens, "Pool: Eth yield too low");
        payable(msg.sender).transfer(ethBought);
        token.transferFrom(msg.sender, address(this), tokenRequired);

        emit EthPurchase(msg.sender, tokenRequired, ethBought);
        return tokenRequired;
    }
}
