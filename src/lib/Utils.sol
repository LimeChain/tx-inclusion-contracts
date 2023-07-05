// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Utils {
    function bytesToBytes32(bytes memory b, uint256 offset) internal pure returns (bytes32) {
        bytes32 out;

        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }
}
