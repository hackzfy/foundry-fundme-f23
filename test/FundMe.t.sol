// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimusUSD() public view {
        assertEq(fundMe.minimumUSD(), 1e17);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.owner(), address(this));
    }
}
