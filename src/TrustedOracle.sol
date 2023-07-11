// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./interfaces/IBlockhashStorage.sol";

/**
 * @title TrustedOracle contract
 * @notice The contract provides an example of a trusted oracle used for crosschecking block hashes
 * @dev The conctract is owned by an address that can set block hashes
 * @author LimeChain
 */
contract TrustedOracle is IBlockhashStorage, Ownable {
    mapping(uint256 blockNumber => bytes32 blockHash) private _blockHashes;

    /// @notice Sets the block hash for a given block number
    /// @dev Only the contract owner can call this function
    /// @param blockNumber The block number for which to set the block hash
    /// @param blockHash The block hash to set
    function setBlockHash(uint256 blockNumber, bytes32 blockHash) public onlyOwner {
        _blockHashes[blockNumber] = blockHash;
    }

    /// @notice Gets the block hash for a given block number
    /// @param blockNumber The block number for which to get the block hash
    /// @return The block hash for the given block number
    function getBlockHash(uint256 blockNumber) public view returns (bytes32) {
        return _blockHashes[blockNumber];
    }
}
