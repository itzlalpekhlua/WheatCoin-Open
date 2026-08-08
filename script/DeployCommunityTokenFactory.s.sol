// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {WheatTokenFactory} from "../src/WheatTokenFactory.sol";

/// @notice Deploy a fixed-supply ERC-20 factory on any EVM-compatible network.
/// @dev Keep the private key in Foundry's encrypted keystore; do not place it in .env.
contract DeployCommunityTokenFactory is Script {
    function run() external returns (WheatTokenFactory factory) {
        address owner = vm.envAddress("FACTORY_OWNER_ADDRESS");
        address payable feeRecipient = payable(vm.envAddress("FACTORY_FEE_RECIPIENT"));
        uint256 creationFee = vm.envOr("FACTORY_CREATION_FEE_WEI", uint256(0));

        vm.startBroadcast();
        factory = new WheatTokenFactory(owner, feeRecipient, creationFee);
        vm.stopBroadcast();

        console2.log("Factory deployed:", address(factory));
        console2.log("Owner:", owner);
        console2.log("Fee recipient:", feeRecipient);
        console2.log("Creation fee (wei):", creationFee);
    }
}
