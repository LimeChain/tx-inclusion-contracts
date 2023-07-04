// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../structs/ProverDto.sol";

/// @title Interface for the ReceiptInclusionProver contract
/// @author Limechain team
interface IReceiptInclusionProver {
    function proveReceiptInclusion(ProverDto calldata dto) external view returns (bool);
}
