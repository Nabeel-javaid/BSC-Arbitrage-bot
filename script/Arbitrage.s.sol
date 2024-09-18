// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Arbitrage.sol";

contract DeployArbitrage is Script {
    function run() external {
        // Hardcoded deployer private key
        uint256 deployerPrivateKey = 0x3e7b404799d15eecf526936fad13795127855323412c4c4e1d43a5222de7056a;

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the Arbitrage contract
        address uniswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address anotherRouter = 0xC0788A3aD43d79aa53B09c2EaCc313A787d1d607;
        new Arbitrage(uniswapRouter, anotherRouter);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
