//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IPool} from "./Interfaces/IPool.sol";
import {IFactory} from "./Interfaces/IFactory.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Pool is IPool, ERC20 {
    IERC20 token;
    IFactory factory;

    string invalidInput = "Pool: INVALID ARGUMENTS";

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
        require(
            inputReserve > 0 &&
                outputReserve > 0 &&
                outputReserve > output_amount,
            invalidInput
        );
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
        uint256 ethBought = getInputPrice(
            tokensSold, 
            tokenReserve, 
            ethReserve
        );
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

    function tokenToTokenSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 deadline,
        address tokenAddr
    ) external returns (uint256) {
        require(
            deadline > block.timestamp && minTokensBought > 0 && tokensSold > 0,
            invalidInput
        );
        address poolAddress = factory.getPool(tokenAddr);
        require(
            poolAddress != address(this) && poolAddress != address(0),
            "Pool: Invalid token address"
        );
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        uint256 ethBought = getInputPrice(
            tokensSold, 
            tokenReserve, 
            ethReserve
        );
        token.transferFrom(msg.sender, address(this), tokensSold);
        uint256 tokensBought = IPool(poolAddress).ethToTokenSwapInput{
            value: ethBought
        }(minTokensBought, deadline);
        ERC20(tokenAddr).transfer(msg.sender, tokensBought);
        emit EthPurchase(msg.sender, tokensSold, ethBought);

        return tokensBought;
    }

    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 deadline,
        address tokenAddr
    ) external returns (uint256) {
        require(
            deadline > block.timestamp && maxTokensSold > 0 && tokensBought > 0,
            invalidInput
        );
        address poolAddress = factory.getPool(tokenAddr);
        require(
            poolAddress != address(this) && poolAddress != address(0),
            "Pool: Invalid token address"
        );

        uint256 ethBought = IPool(poolAddress).getEthToTokenOutputPrice(
            tokensBought
        );
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        uint256 tokensSold = getOutputPrice(
            ethBought,
            tokenReserve,
            ethReserve
        );
        require(maxTokensSold >= tokensSold, "Pool: Yield too low");
        token.transferFrom(msg.sender, address(this), tokensSold);
        IPool(poolAddress).ethToTokenSwapOutput{value: ethBought}(
            tokensBought,
            deadline
        );
        ERC20(tokenAddr).transfer(msg.sender, tokensBought);
        emit EthPurchase(msg.sender, tokensSold, ethBought);
        return tokensSold;
    }

    function addLiquidity(
        uint256 minLiquidity,
        uint256 maxTokens,
        uint256 deadline
    ) external payable returns (uint256) {
        require(
            deadline > block.timestamp && maxTokens > 0 && msg.value > 0,
            invalidInput
        );
        uint256 totalLiquidity = totalSupply();

        if (totalLiquidity > 0) {
            require(minLiquidity > 0, "Pool: Minimum liquidity required too low");
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = token.balanceOf(address(this));
            uint256 tokensRequired = msg.value *
                (tokenReserve / ethReserve) +
                1;
            uint256 liquidityMinted = msg.value * (totalLiquidity / ethReserve);

            require(
                maxTokens >= tokensRequired && liquidityMinted >= minLiquidity,
                "Pool: Liquidty minted too low"
            );

            _mint(msg.sender, liquidityMinted);
            token.transferFrom(msg.sender, address(this), tokensRequired);

            emit AddLiquidity(msg.sender, msg.value, tokensRequired);
            emit Transfer(address(0), msg.sender, liquidityMinted);
            return liquidityMinted;
        } else {
            require(
                address(factory) != address(0) &&
                    address(token) != address(0) &&
                    msg.value >= 1000000000,
                invalidInput
            );
            require(
                factory.getPool(address(token)) == address(this),
                "Pool: Incorrect Pool-Token pair"
            );
            uint256 tokensRequired = maxTokens;
            uint256 initialLiquidity = address(this).balance;
            _mint(msg.sender, initialLiquidity);

            token.transferFrom(msg.sender, address(this), tokensRequired);

            emit AddLiquidity(msg.sender, msg.value, tokensRequired);
            emit Transfer(address(0), msg.sender, initialLiquidity);
            return initialLiquidity;
        }
    }

    function removeLiquidity(
        uint256 amount,
        uint256 minEth,
        uint256 minTokens,
        uint256 deadline
    ) external returns (uint256, uint256) {
        require(
            amount > 0 &&
                deadline > block.timestamp &&
                minEth > 0 &&
                minTokens > 0
        );
        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "Pool: Liquidity too low");
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance;
        uint256 ethAmount = amount * (ethReserve / totalLiquidity);
        uint256 tokenAmount = amount * (tokenReserve / totalLiquidity);
        require(ethAmount >= minEth && tokenAmount >= minTokens);

        _burn(msg.sender, amount);

        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender, tokenAmount);
        emit RemoveLiquidity(msg.sender, ethAmount, tokenAmount);
        emit Transfer(msg.sender, address(0), amount);
        return (ethAmount, tokenAmount);
    }

    function getEthToTokenInputPrice(uint256 ethSold)
        external
        view
        returns (uint256)
    {
        require(ethSold > 0);
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokensBought = getInputPrice(
            ethSold,
            address(this).balance,
            tokenReserve
        );
        return tokensBought;
    }

    function getEthToTokenOutputPrice(uint256 tokensBought)
        external
        view
        returns (uint256)
    {
        require(tokensBought > 0);
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethSold = getOutputPrice(
            tokensBought,
            address(this).balance,
            tokenReserve
        );
        return ethSold;
    }

    function getTokenToEthInputPrice(uint256 tokensSold)
        external
        view
        returns (uint256)
    {
        require(tokensSold > 0);
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethBought = getInputPrice(
            tokensSold,
            tokenReserve,
            address(this).balance
        );
        return ethBought;
    }

    function getTokenToEthOutputPrice(uint256 ethBought)
        external
        view
        returns (uint256)
    {
        uint256 tokenReserve = token.balanceOf(address(this));
        return getOutputPrice(ethBought, tokenReserve, address(this).balance);
    }

    function tokenAddress() external view returns (address) {
        return address(token);
    }

    function factoryAddress() external view returns (address) {
        return address(factory);
    }
}
