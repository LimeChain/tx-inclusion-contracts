// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TxLog.sol";

struct TxReceipt {
    uint256 receiptType;
    uint256 postStateOrStatus;
    uint256 cumulativeGasUsed;
    bytes keyIndex;
    bytes bloom;
    TxLog[] logs;
}
