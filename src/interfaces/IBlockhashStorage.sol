// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IBlockhashStorage interface
/// @notice The interface provides functions which a contract must have in order to store and retrieve block hashes
/// @author LimeChain
interface IBlockhashStorage {
    /// @notice Gets the block hash for a given block number
    /// @param blockNumber The block number for which to get the block hash
    /// @return The block hash for the given block number
    function getBlockHash(uint256 blockNumber) external view returns (bytes32);

    /// @notice Sets the block hash for a given block number
    /// @param blockNumber The block number for which to set the block hash
    /// @param blockHash The block hash to set
    function setBlockHash(uint256 blockNumber, bytes32 blockHash) external;
}
