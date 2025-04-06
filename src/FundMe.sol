// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

using PriceConverter for uint;

error NotOwner();
error InsufficientFunds();
error withdrawFailed();
error moreFundsRequired();

contract FundMe {
    uint public constant MINIMUM_USD = 5;
    address payable public immutable owner;

    address[] private s_funders;
    mapping(address => uint) private s_funderToAmount;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        owner = payable(msg.sender);
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert moreFundsRequired();
        }

        if (s_funderToAmount[msg.sender] == 0) {
            s_funderToAmount[msg.sender] = msg.value;
            s_funders.push(msg.sender);
        } else {
            s_funderToAmount[msg.sender] += msg.value;
        }
    }

    function getVersion() public view returns (uint) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) {
            revert withdrawFailed();
        }
    }

    function getFunder(uint index) public view returns (address) {
        return s_funders[index];
    }

    function getAmountByFunder(address funder) public view returns (uint) {
        return s_funderToAmount[funder];
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
}
