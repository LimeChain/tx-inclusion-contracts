// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TxReceipt.sol";
import "./BlockData.sol";

struct ProverDto {
    BlockData blockData;
    TxReceipt txReceipt;
    uint256 blockNumber;
    bytes[] receiptProofBranch;
}
