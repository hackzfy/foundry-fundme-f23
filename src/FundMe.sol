// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {PriceConverter} from "./PriceConverter.sol";
using PriceConverter for uint;

error NotOwner();
error InsufficientFunds();
error withdrawFailed();
error moreFundsRequired();

contract FundMe {
    uint public constant minimumUSD = 1e17; // 0.1 eth
    address payable public immutable owner;
    uint total;
    address[] people;
    mapping(address => uint) personToAmount;

    constructor() {
        owner = payable(msg.sender);
    }

    function fund() public payable {
        if (msg.value.getConversionRate() < minimumUSD) {
            revert moreFundsRequired();
        }
        total += msg.value;
        if (personToAmount[msg.sender] == 0) {
            personToAmount[msg.sender] = msg.value;
            people.push(msg.sender);
        } else {
            personToAmount[msg.sender] += msg.value;
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
