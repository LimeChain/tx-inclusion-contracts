// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrustedOracle {
    function getBlockHash(uint256 blockNumber) external view returns (bytes32);
}
