// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RLPEncoder.sol";
import "./MPT.sol";

import "../structs/TxReceipt.sol";

library Utils {
    function encodeReceipt(TxReceipt memory _txReceipt) internal pure returns (bytes memory output) {
        bytes[] memory list = new bytes[](4);
        list[0] = RLPEncoder.encodeUint(_txReceipt.postStateOrStatus);
        list[1] = RLPEncoder.encodeUint(_txReceipt.cumulativeGasUsed);
        list[2] = RLPEncoder.encodeBytes(_txReceipt.bloom);
        bytes[] memory listLog = new bytes[](_txReceipt.logs.length);
        bytes[] memory loglist = new bytes[](3);
        for (uint256 j = 0; j < _txReceipt.logs.length; j++) {
            loglist[0] = RLPEncoder.encodeAddress(_txReceipt.logs[j].addr);
            bytes[] memory loglist1 = new bytes[](_txReceipt.logs[j].topics.length);

            for (uint256 i = 0; i < _txReceipt.logs[j].topics.length; i++) {
                loglist1[i] = RLPEncoder.encodeBytes(_txReceipt.logs[j].topics[i]);
            }
            loglist[1] = RLPEncoder.encodeList(loglist1);
            loglist[2] = RLPEncoder.encodeBytes(_txReceipt.logs[j].data);
            bytes memory logBytes = RLPEncoder.encodeList(loglist);
            listLog[j] = logBytes;
        }
        list[3] = RLPEncoder.encodeList(listLog);
        output = RLPEncoder.encodeList(list);
    }

    function verifyTrieProof(bytes32 root, bytes memory key, bytes[] memory proof, bytes memory node)
        internal
        view
        returns (bool)
    {
        MPT.MerkleProof memory mp = MPT.MerkleProof({
            expectedRoot: root,
            key: key,
            proof: proof,
            keyIndex: 0,
            proofIndex: 0,
            expectedValue: node
        });
        return MPT.verifyTrieProof(mp);
    }
}
