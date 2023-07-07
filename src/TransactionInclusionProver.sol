// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "Solidity-RLP/RLPReader.sol";
import "solady/src/utils/DynamicBufferLib.sol";

import "./structs/BlockData.sol";
import "./structs/ProverDto.sol";
import "./interfaces/IBlockhashStorage.sol";
import "./interfaces/ITransactionInclusionProver.sol";
import "./lib/RLPEncoder.sol";

/**
 * @title TransactionInclusionProver
 * @dev A contract which uses MerkleProof in order to verify whether a transaction is included in a block.
 */
contract TransactionInclusionProver is ITransactionInclusionProver {
    using RLPReader for bytes;
    using RLPReader for uint256;
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;
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
    function proveTransactionInclusion(ProverDto memory data) external view returns (bool) {
        if (!data.txReceipt.status) return false;

        if (_blockhashStorage.getBlockHash(data.blockNumber) != _getBlockHash(data.blockData)) return false;

        bytes32 txReceiptHash = _getReceiptHash(data.txReceipt);
        if (MerkleProof.verify(data.receiptProofBranch, data.blockData.receiptsRoot, txReceiptHash)) {
            return false;
        }

        return true;
    }

    /**
     * @dev Computes the hash of a transaction receipt.
     * @param data The transaction receipt data.
     * @return The hash of the transaction receipt.
     */
    function _getReceiptHash(Receipt memory data) internal pure returns (bytes32) {
        bytes memory receiptHashBytes = abi.encode(data.status, data.cumulativeGasUsed, data.logsBloom, data.logs);

        RLPReader.RLPItem memory rlpItem = receiptHashBytes.toRlpItem();
        return keccak256(rlpItem.toRlpBytes());
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
        buffer.append(abi.encodePacked(blockData.logsBloom).encodeBytes());

        bytes memory integers = (
            abi.encode(
                blockData.difficulty, blockData.number, blockData.gasLimit, blockData.gasUsed, blockData.timestamp
            )
        ).encodeCallData(0);
        buffer.append(integers);

        buffer.append(abi.encodePacked(blockData.extraData).encodeBytes());
        buffer.append(abi.encodePacked(blockData.mixHash).encodeBytes());
        buffer.append(abi.encodePacked(blockData.nonce).encodeBytes());

        buffer.append((abi.encodePacked(blockData.baseFeePerGas)).encodeCallData(0));

        buffer.append(abi.encodePacked(blockData.withdrawalsRoot).encodeBytes());

        bytes memory rlp = RLPWriter.writeList(buffer.data);

        return keccak256(rlp);
    }
}
