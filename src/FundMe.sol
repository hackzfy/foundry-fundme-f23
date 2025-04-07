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
    address payable private immutable i_owner;

    address[] private s_funders;
    mapping(address => uint) private s_funderToAmount;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = payable(msg.sender);
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

    function withdrawCheap() public onlyOwner {
        uint fundersLength = s_funders.length;
        for (uint i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_funderToAmount[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        if (!success) {
            revert withdrawFailed();
        }
    }

    function withdraw() public onlyOwner {
        for (uint i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_funderToAmount[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
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

    function getOwner() public view returns (address) {
        return i_owner;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }
}
