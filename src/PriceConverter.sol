// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint) {
        (, int price, , , ) = priceFeed.latestRoundData();
        // is it safe to convert here?
        return uint(price * 1e10);
    }

    function getConversionRate(
        uint amount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint) {
        uint price = getPrice(priceFeed);
        return (price * amount) / 1e18;
    }
}
