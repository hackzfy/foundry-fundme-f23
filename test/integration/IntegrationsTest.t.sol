// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/FundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    uint constant VALUE_SENT = 0.1 ether;
    uint constant STARTING_USER_BALANCE = 10 ether;
    address bob = makeAddr("bob");
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(bob, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerCanWithdraw() public {
        uint preBobBalance = bob.balance;
        uint preOwnerBalance = address(fundMe.getOwner()).balance;
        uint preFundMeBalance = address(fundMe).balance;
        vm.prank(bob);
        fundMe.fund{value: VALUE_SENT}();

        assertEq(bob.balance, preBobBalance - VALUE_SENT);
        assertEq(address(fundMe).balance, preFundMeBalance + VALUE_SENT);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint afterOwnerBalance = address(fundMe.getOwner()).balance;
        assertEq(afterOwnerBalance, preOwnerBalance + VALUE_SENT);
    }
}
