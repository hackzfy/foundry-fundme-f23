// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface(
            0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
        );
        (, int price, , , ) = dataFeed.latestRoundData();
        // is it safe to convert here?
        return uint(price);
    }

    function getConversionRate(uint amount) internal view returns (uint) {
        uint price = getPrice();
        return price * amount;
    }
}
