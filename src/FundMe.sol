// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {PriceConverter} from "./PriceConverter.sol";
using PriceConverter for int256;

error NotOwner();
error InsufficientFunds();
error withdrawFailed();
error moreFundsRequired();

contract FundMe {
    int256 public constant minimumUSD = 1e17; // 0.1 eth
    address payable public immutable owner;
    int256 total;
    address[] people;
    mapping(address => int256) personToAmount;

    constructor() {
        owner = payable(msg.sender);
    }

    function fund(int256 amount) public payable {
        if (amount.getConversionRate() < minimumUSD) {
            revert moreFundsRequired();
        }
        total += amount;
        if (personToAmount[msg.sender] == 0) {
            personToAmount[msg.sender] = amount;
            people.push(msg.sender);
        } else {
            personToAmount[msg.sender] += amount;
        }
    }

    function withdraw() public onlyOwner {
        if (total <= 0) {
            revert InsufficientFunds();
        }
        total = 0;
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) {
            revert withdrawFailed();
        }
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
}
