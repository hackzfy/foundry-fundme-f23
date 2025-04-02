// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (int256) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface(
            0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
        );
        (, int256 price, , , ) = dataFeed.latestRoundData();
        return price;
    }

    function getConversionRate(int256 amount) internal view returns (int256) {
        int256 price = getPrice();
        int256 ethAmountInUSD = price * amount;
        return ethAmountInUSD;
    }
}
