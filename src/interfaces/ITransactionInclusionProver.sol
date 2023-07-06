// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../structs/ProverDto.sol";

/**
 * @title Interface for TransactionInclusionProver contract
 * @dev An interface for the contract that verifies whether a transaction is included in a block.
 */
interface ITransactionInclusionProver {
    /**
     * @dev Verifies that a transaction is included in a block.
     * @param data The data needed to verify the transaction inclusion.
     * @return A boolean indicating whether the transaction is included in the block.
     */
    function proveTransactionInclusion(ProverDto calldata data) external view returns (bool);
}
