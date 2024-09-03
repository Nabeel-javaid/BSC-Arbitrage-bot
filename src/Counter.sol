// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

contract Arbitrage {
    address public owner;
    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Router02 public anotherRouter;

    constructor(address _uniswapRouter, address _anotherRouter) {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        anotherRouter = IUniswapV2Router02(_anotherRouter);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function executeArbitrage(
        address tokenA,
        address tokenB,
        uint amountIn,
        uint minProfit
    ) external onlyOwner {
        uint amountOutUniswap = getAmountOut(uniswapRouter, tokenA, tokenB, amountIn);
        uint amountOutAnother = getAmountOut(anotherRouter, tokenA, tokenB, amountIn);

        uint maxAmountOut = amountOutUniswap > amountOutAnother ? amountOutUniswap : amountOutAnother;
        uint minAmountOut = amountOutUniswap > amountOutAnother ? amountOutAnother : amountOutUniswap;

        require(maxAmountOut > minAmountOut + minProfit, "No profitable arbitrage opportunity");

        // Perform arbitrage: Buy low on one exchange and sell high on the other
        if (amountOutUniswap > amountOutAnother) {
            // Buy on Another Router, sell on Uniswap
            swap(anotherRouter, tokenA, tokenB, amountIn);
            swap(uniswapRouter, tokenB, tokenA, amountIn);
        } else {
            // Buy on Uniswap, sell on Another Router
            swap(uniswapRouter, tokenA, tokenB, amountIn);
            swap(anotherRouter, tokenB, tokenA, amountIn);
        }
    }

    function getAmountOut(
        IUniswapV2Router02 router,
        address tokenA,
        address tokenB,
        uint amountIn
    ) internal view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        uint[] memory amounts = router.getAmountsOut(amountIn, path);
        return amounts[1];
    }

    function swap(
        IUniswapV2Router02 router,
        address tokenA,
        address tokenB,
        uint amountIn
    ) internal {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        IERC20(tokenA).approve(address(router), amountIn);
        router.swapExactTokensForTokens(
            amountIn,
            0,  // Accept any amountOut
            path,
            address(this),
            block.timestamp
        );
    }

    // Function to withdraw tokens from the contract
    function withdrawToken(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    // Function to withdraw ETH from the contract
    function withdrawETH(uint amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}
