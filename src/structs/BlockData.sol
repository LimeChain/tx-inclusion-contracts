// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct BlockData {
    bytes32 parentHash;
    bytes32 sha3Uncles;
    bytes miner;
    bytes32 stateRoot;
    bytes32 transactionsRoot;
    bytes32 receiptsRoot;
    bytes logsBloom;
    uint256 difficulty;
    uint256 number;
    uint256 gasLimit;
    uint256 gasUsed;
    uint256 timestamp;
    bytes extraData;
    bytes32 mixHash;
    bytes nonce;
    uint256 baseFeePerGas;
    bytes32 withdrawalsRoot;
}
