// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address immutable bob = makeAddr("bob");
    uint constant INITIAL_BALANCE = 10 ether;
    uint constant VALUE_SENT = 1 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(bob, INITIAL_BALANCE);
    }

    function testMinimusUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundToAmount() public {
        vm.prank(bob);
        fundMe.fund{value: VALUE_SENT}();
        uint amount = fundMe.getAmountByFunder(bob);
        assertEq(amount, VALUE_SENT);
    }

    function testFundUpdatesFunders() public {
        vm.prank(bob);
        fundMe.fund{value: VALUE_SENT}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, bob);
    }

    modifier funded() {
        vm.prank(bob);
        fundMe.fund{value: VALUE_SENT}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        uint startingFundMeBalance = address(fundMe).balance;
        uint startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint endingFundMeBalance = address(fundMe).balance;
        uint endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingFundMeBalance + startingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startIndex = 1;

        for (uint160 index = startIndex; index <= numberOfFunders; index++) {
            hoax(address(index), VALUE_SENT);
            fundMe.fund{value: VALUE_SENT}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
        assertEq(
            numberOfFunders * VALUE_SENT,
            fundMe.getOwner().balance - startingOwnerBalance
        );
    }
}
