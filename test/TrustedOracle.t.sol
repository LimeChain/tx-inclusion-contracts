// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";
import "../src/TrustedOracle.sol";

contract TrustedOracleTest is BaseTest {
    TrustedOracle public oracle;

    function setUp() public override {
        super.setUp();
        oracle = new TrustedOracle();
    }

    function testOwner() public {
        assertEq(oracle.owner(), address(this));
    }

    function testSetBlockHash() public {
        oracle.setBlockHash(1, "0x1234");
        assertEq(oracle.getBlockHash(1), "0x1234");
    }

    function testSetBlockHashByNotOwner() public {
        vm.startPrank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        oracle.setBlockHash(1, "0x1234");
        vm.stopPrank();
    }
}
