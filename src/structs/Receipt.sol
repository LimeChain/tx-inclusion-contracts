// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Log.sol";

struct Receipt {
    bool status;
    uint256 cumulativeGasUsed;
    bytes bitvector;
    Log[] logs;
}
