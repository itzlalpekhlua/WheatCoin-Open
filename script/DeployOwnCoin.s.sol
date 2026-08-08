// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {OwnCoin} from "../src/OwnCoin.sol";

/// @notice Deploy a custom coin using environment variables only.
contract DeployOwnCoin is Script {
    function run() external returns (OwnCoin coin) {
        string memory name = vm.envString("COIN_NAME");
        string memory symbol = vm.envString("COIN_SYMBOL");
        address admin = vm.envAddress("COIN_ADMIN_ADDRESS");
        address treasury = vm.envAddress("COIN_TREASURY_ADDRESS");
        uint256 initialSupply = vm.envUint("COIN_INITIAL_SUPPLY") * 1 ether;
        uint256 maxSupply = vm.envUint("COIN_MAX_SUPPLY") * 1 ether;

        vm.startBroadcast();
        coin = new OwnCoin(name, symbol, admin, treasury, initialSupply, maxSupply);
        vm.stopBroadcast();

        console2.log("Coin deployed:", address(coin));
        console2.log("Name:", name);
        console2.log("Symbol:", symbol);
        console2.log("Treasury:", treasury);
    }
}
