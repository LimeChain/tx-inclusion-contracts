// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./interfaces/ITrustedOracle.sol";

/// @title TrustedOracle contract
/// @author LimeChain team
contract TrustedOracle is ITrustedOracle, Ownable {
    mapping(uint256 blockNumber => bytes32 blockHash) private _blockHashes;

    function setBlockHash(uint256 blockNumber, bytes32 blockHash) public onlyOwner {
        _blockHashes[blockNumber] = blockHash;
    }

    function getBlockHash(uint256 blockNumber) public view returns (bytes32) {
        return _blockHashes[blockNumber];
    }
}
