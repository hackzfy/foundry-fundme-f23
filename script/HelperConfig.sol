// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Script} from "forge-std/Script.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {MockAggregatorV3} from "../test/mock/MockAggregatorV3.sol";

contract HelperConfig is Script {
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 1999e8;

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getSepoliaConfig();
        } else {
            activeConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeConfig.priceFeed != address(0)) {
            return activeConfig;
        }
        vm.startBroadcast();
        MockAggregatorV3 mockPriceFeed = new MockAggregatorV3(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        activeConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return activeConfig;
    }
}
