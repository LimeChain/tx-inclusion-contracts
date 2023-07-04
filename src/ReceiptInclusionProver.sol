// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "forge-std/console.sol";
import "Solidity-RLP/RLPReader.sol";

import "./structs/BlockData.sol";
import "./structs/ProverDto.sol";
import "./interfaces/ITrustedOracle.sol";
import "./interfaces/IReceiptInclusionProver.sol";
import "./lib/RLPEncoder.sol";
import "./lib/DynamicBufferLib.sol";

contract ReceiptInclusionProver is IReceiptInclusionProver {
    using RLPReader for bytes;
    using RLPReader for uint256;
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;
    using RLPEncoder for bytes;
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;

    ITrustedOracle private _oracle;

    constructor(address oracleAddress) {
        _oracle = ITrustedOracle(oracleAddress);
    }

    function proveReceiptInclusion(ProverDto memory data) external view returns (bool) {
        if (!data.txReceipt.status) return false;

        if (_oracle.getBlockHash(data.blockNumber) != _getBlockHash(data.blockData)) return false;

        bytes32 txReceiptHash = _getReceiptHash(data.txReceipt);
        if (MerkleProof.verify(data.receiptProofBranch, data.blockData.receiptsRoot, txReceiptHash)) return false;

        return true;
    }

    function _getReceiptHash(Receipt memory data) internal pure returns (bytes32) {
        bytes memory receiptHashBytes = abi.encode(data.status, data.cumulativeGasUsed, data.bitvector, data.logs);

        RLPReader.RLPItem memory rlpItem = receiptHashBytes.toRlpItem();
        return keccak256(rlpItem.toRlpBytes());
    }

    function _getBlockHash(BlockData memory blockData) internal view returns (bytes32) {
        DynamicBufferLib.DynamicBuffer memory buffer;

        bytes memory rootHashes = (
            abi.encode(
                blockData.parentHash,
                blockData.sha3Uncles,
                blockData.miner,
                blockData.stateRoot,
                blockData.transactionsRoot,
                blockData.receiptsRoot
            )
        ).encodeCallData(0);

        buffer.append(rootHashes);

        bytes memory logsBloomEncoded = blockData.logsBloom.encodeBytes();
        buffer.append(logsBloomEncoded);

        bytes memory integers = (
            abi.encode(
                blockData.difficulty, blockData.number, blockData.gasLimit, blockData.gasUsed, blockData.timestamp
            )
        ).encodeCallData(0);
        buffer.append(integers);

        bytes memory extraDataEncoded = blockData.extraData.encodeBytes();
        buffer.append(extraDataEncoded);

        buffer.append((abi.encode(blockData.mixHash)).encodeCallData(0));

        bytes memory encodedNonce = blockData.nonce.encodeBytes();
        buffer.append(encodedNonce);

        buffer.append((abi.encode(blockData.baseFeePerGas, blockData.withdrawalsRoot)).encodeCallData(0));

        bytes memory rlp = RLPWriter.writeList(buffer.data);
        console.log("BLOCKHASH: ");
        console.log("0x3f0fc945187c3d7d31a45d2bbebeded546aaa880ab58c2afa85b74682ea3ed88");
        console.logBytes32(keccak256(rlp));

        return keccak256(rlp);
    }
}
