// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {Utilities} from "./utils/Utilities.sol";

contract BaseTest is Test {
    Utilities internal utils;

    address payable internal owner;
    address payable internal user1;
    address payable internal user2;

    uint256 internal ownerPk;
    uint256 internal user1Pk;
    uint256 internal user2Pk;

    function setUp() public virtual {
        utils = new Utilities();
        (address payable[] memory users, uint256[] memory pks) = utils.createUsers(3);

        owner = users[0];
        user1 = users[1];
        user2 = users[2];

        ownerPk = pks[0];
        user1Pk = pks[1];
        user2Pk = pks[2];
    }
}
