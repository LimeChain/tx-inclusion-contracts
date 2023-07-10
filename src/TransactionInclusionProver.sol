// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "solady/src/utils/DynamicBufferLib.sol";
import "./lib/RLPEncoder.sol";
import "./lib/Utils.sol";
import "./lib/RLPWriter.sol";

import "./structs/BlockData.sol";
import "./structs/ProverDto.sol";
import "./interfaces/IBlockhashStorage.sol";
import "./interfaces/ITransactionInclusionProver.sol";

/**
 * @title TransactionInclusionProver
 * @dev A contract which uses MerkleProof in order to verify whether a transaction is included in a block.
 */
contract TransactionInclusionProver is ITransactionInclusionProver {
    using RLPEncoder for bytes;
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;

    IBlockhashStorage private _blockhashStorage;

    /**
     * @dev Initializes the contract with the address of the trusted blockhashStorage.
     * @param blockhashStorageAddress The address of the trusted blockhashStorage.
     */
    constructor(address blockhashStorageAddress) {
        _blockhashStorage = IBlockhashStorage(blockhashStorageAddress);
    }

    /**
     * @dev Verifies that a transaction is included in a block.
     * @param data The data needed to verify the transaction inclusion.
     * @return A boolean indicating whether the transaction is included in the block.
     */
    function proveTransactionInclusion(ProverDto calldata data) external view returns (bool) {
        if (data.txReceipt.postStateOrStatus != 1) return false;

        if (_blockhashStorage.getBlockHash(data.blockNumber) != _getBlockHash(data.blockData)) return false;

        bytes memory encodedReceipt = _getEncodedReceipt(data.txReceipt);

        return Utils.verifyTrieProof(
            data.blockData.receiptsRoot, data.txReceipt.keyIndex, data.receiptProofBranch, encodedReceipt
        );
    }

    /**
     * @dev Computes the hash of a transaction TxReceipt.
     * @param txReceipt The transaction TxReceipt data.
     * @return The hash of the transaction TxReceipt.
     */
    function _getEncodedReceipt(TxReceipt memory txReceipt) internal pure returns (bytes memory) {
        bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
        bytes memory expectedValue = bytesReceipt;
        if (txReceipt.receiptType > 0) {
            expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
        }
        return expectedValue;
    }

    /**
     * @dev Computes the hash of a block.
     * @param blockData The block data.
     * @return The hash of the block.
     */
    function _getBlockHash(BlockData memory blockData) internal pure returns (bytes32) {
        DynamicBufferLib.DynamicBuffer memory buffer;

        buffer.append(abi.encodePacked(blockData.parentHash).encodeBytes());
        buffer.append(abi.encodePacked(blockData.sha3Uncles).encodeBytes());
        buffer.append(abi.encodePacked(blockData.miner).encodeBytes());
        buffer.append(abi.encodePacked(blockData.stateRoot).encodeBytes());
        buffer.append(abi.encodePacked(blockData.transactionsRoot).encodeBytes());
        buffer.append(abi.encodePacked(blockData.receiptsRoot).encodeBytes());
        buffer.append(blockData.logsBloom.encodeBytes());

        bytes memory integers = (
            abi.encode(
                blockData.difficulty, blockData.number, blockData.gasLimit, blockData.gasUsed, blockData.timestamp
            )
        ).encodeCallData(0);
        buffer.append(integers);

        buffer.append(blockData.extraData.encodeBytes());
        buffer.append(abi.encodePacked(blockData.mixHash).encodeBytes());
        buffer.append(blockData.nonce.encodeBytes());

        buffer.append((abi.encodePacked(blockData.baseFeePerGas)).encodeCallData(0));

        buffer.append(abi.encodePacked(blockData.withdrawalsRoot).encodeBytes());

        bytes memory rlp = RLPWriter.writeList(buffer.data);

        return keccak256(rlp);
    }
}
