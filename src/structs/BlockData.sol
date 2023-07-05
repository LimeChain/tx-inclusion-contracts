// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct BlockData {
    bytes parentHash;
    bytes sha3Uncles;
    bytes miner;
    bytes stateRoot;
    bytes transactionsRoot;
    bytes receiptsRoot;
    bytes logsBloom;
    uint256 difficulty;
    uint256 number;
    uint256 gasLimit;
    uint256 gasUsed;
    uint256 timestamp;
    bytes extraData;
    bytes mixHash;
    bytes nonce;
    uint256 baseFeePerGas;
    bytes withdrawalsRoot;
}
