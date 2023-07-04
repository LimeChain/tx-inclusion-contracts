// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Receipt.sol";
import "./BlockData.sol";

struct ProverDto {
    BlockData blockData;
    Receipt txReceipt;
    uint256 blockNumber;
    bytes32[] receiptProofBranch;
}
