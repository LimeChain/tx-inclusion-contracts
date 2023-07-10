// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct TxLog {
    address addr;
    bytes[] topics;
    bytes data;
}
