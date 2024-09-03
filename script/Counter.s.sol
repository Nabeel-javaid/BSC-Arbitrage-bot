// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/Counter.sol";

contract DeployArbitrage {
    function run() external {
        address uniswapRouter = "0x10ED43C718714eb63d5aA57B78B54704E256024E";
        address anotherRouter = "0xC0788A3aD43d79aa53B09c2EaCc313A787d1d607";

        Arbitrage arbitrage = new Arbitrage(uniswapRouter, anotherRouter);
        console.log("Arbitrage contract deployed to:", address(arbitrage));
    }
}
