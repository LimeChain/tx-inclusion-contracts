// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../structs/ProverDto.sol";

/// @title Interface for the TransactionInclusionProver contract
/// @author Limechain team
interface ITransactionInclusionProver {
    function proveTransactionInclusion(ProverDto calldata dto) external view returns (bool);
}
