// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";

// libs
import "../src/lib/RLPWriter.sol";
import "../src/lib/RLPEncoder.sol";
import "../src/lib/RLPReader.sol";
import "../src/lib/Utils.sol";
import "./utils/Data.sol";

// contracts
import "../src/interfaces/IBlockhashStorage.sol";
import "../src/TrustedOracle.sol";
import "../src/TransactionInclusionProver.sol";

// structs
import "../src/structs/BlockData.sol";
import "../src/structs/ProverDto.sol";
import "../src/structs/TxReceipt.sol";
import "../src/structs/TxLog.sol";

contract TransactionInclusionProverTest is BaseTest {
    IBlockhashStorage public blockhashStorage;
    TransactionInclusionProver public prover;

    using RLPReader for bytes;
    using RLPReader for uint256;
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;

    function setUp() public override {
        super.setUp();
        blockhashStorage = new TrustedOracle();
        prover = new TransactionInclusionProver(address(blockhashStorage));
    }

    // Test correct scenarios
    function testVerifyTrieProof() public {
        {
            TxReceipt memory txReceipt = Data.getTxReceipt1();

            bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
            bytes memory expectedValue = bytesReceipt;
            if (txReceipt.receiptType > 0) {
                expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
            }

            bool success = Utils.verifyTrieProof(
                0x270ac2ede5bf10426ffb17cd1a0a46f620011ec92ef53f3afb3e656587a2f747,
                txReceipt.keyIndex,
                Data.getReceiptsProofBranch1(),
                expectedValue
            );

            assertTrue(success);
        }

        {
            TxReceipt memory txReceipt = Data.getTxReceipt2();

            bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
            bytes memory expectedValue = bytesReceipt;
            if (txReceipt.receiptType > 0) {
                expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
            }

            bool success = Utils.verifyTrieProof(
                0x03ad740576271763dfda5d6bce4cb668f44b5d0592b583d2fdbe970b9eb276cc,
                txReceipt.keyIndex,
                Data.getReceiptsProofBranch2(),
                expectedValue
            );

            assertTrue(success);
        }

        {
            TxReceipt memory txReceipt = Data.getTxReceipt3();

            bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
            bytes memory expectedValue = bytesReceipt;
            if (txReceipt.receiptType > 0) {
                expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
            }

            assertEq(
                keccak256(expectedValue.toRlpItem().toRlpBytes()),
                0x266e59d6fb48f7a1abfb141af24de82a9502aa878efd3dfc8469d3355c204658 // receipt hash
            );

            bool success = Utils.verifyTrieProof(
                0x109d5c51f422cbbfaf1efe27466ecf9137cdc65be8325d99f4bdfa8123565282,
                txReceipt.keyIndex,
                Data.getReceiptsProofBranch3(),
                expectedValue
            );

            assertTrue(success);
        }

        {
            TxReceipt memory txReceipt = Data.getTxReceipt4();

            bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
            bytes memory expectedValue = bytesReceipt;
            if (txReceipt.receiptType > 0) {
                expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
            }

            bool success = Utils.verifyTrieProof(
                0x1026f7f0ca1c5c9740019d0c25f4c92a7cfc96388a8f1c03d8e17e871274ae76,
                txReceipt.keyIndex,
                Data.getReceiptsProofBranch4(),
                expectedValue
            );

            assertTrue(success);
        }
    }

    function testProveTransactionInclusion() public {
        blockhashStorage.setBlockHash(
            uint256(0x10d2ca6), 0x1f2274b771312ed973f587848c0e06d43445f92e93acdb52b3ac1b6b008c96a4
        );

        BlockData memory blockData = BlockData({
            parentHash: hex"a71d7d395fa99c10dabcf5727575137127baee8a21f6d7edcd5e39b6dad1d66f",
            sha3Uncles: hex"1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
            miner: 0x388C818CA8B9251b393131C08a736A67ccB19297,
            stateRoot: hex"5fe4dcd7db1f782670184adea5d1eefafa4525fdfd73e2bd3f2231dd7cdaf12e",
            transactionsRoot: hex"820a34c3ff9154472a50386f196fc779a8c44403919e4d33712d86f35e50516f",
            receiptsRoot: hex"270ac2ede5bf10426ffb17cd1a0a46f620011ec92ef53f3afb3e656587a2f747",
            logsBloom: hex"3c3d531e492e5339bd088cc1ce28d2695acb52064b17062941a3800e7c62080cc15599aa481913f972193b8364500b006f0dc2bcbe29f8a05685b8a6b12cb9808bf6d0182276184f2a1a440cbf28746e04295cc70d463a3a0b020e7aab6f872b02488a4a8340ee014156a39058663b29e51c2b5692a84444fa045858288f8dba0b0286784fe980943c4a4c15a35284669698b4e9ebc6e4ccc8b50f634c547966a2a151e3ebd462a25a00e6e6fbee17a4e4544875a2d80aab397b19ca4a0d92c46536c052848fc560821aa4c08c2c72b598cd75b2dca4095c85525f8e1c50f2ad163becabc163c44f86f516be08e468c0e461f226cfb0aa47c07d249c000ff4e7",
            difficulty: uint256(0x0),
            number: uint256(0x10d2ca6),
            gasLimit: uint256(0x1c9c380),
            gasUsed: uint256(0xe2f507),
            timestamp: uint256(0x64a7c6a7),
            extraData: hex"6265617665726275696c642e6f7267",
            mixHash: hex"8da2671e1312eea46891ffa353d09ad2f139ab16c079b2b212d9cf4c63211f24",
            nonce: hex"0000000000000000",
            baseFeePerGas: uint256(0x7a03f8e35),
            withdrawalsRoot: hex"c3be3075835092bcc3a000b8a0ecf4f6e80b63eeaeb09a569af77cff483d1ea9"
        });

        ProverDto memory data = ProverDto({
            blockData: blockData,
            txReceipt: Data.getTxReceipt1(),
            blockNumber: uint256(0x10d2ca6),
            receiptProofBranch: Data.getReceiptsProofBranch1()
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }

    function testProveTransactionInclusion_zeroStartStateRoot() public {
        blockhashStorage.setBlockHash(
            uint256(0x10d2ca3), 0xf8591b5b4e4f7fe47b7adeff8f0113f9e5ce304e3b0539e8a45148473b471f62
        );

        BlockData memory blockData = BlockData({
            parentHash: hex"e0e99e5629c622a14d8bc62154f83a2830fe78daa2b074130c1822f0106c391b",
            sha3Uncles: hex"1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
            miner: 0xeBec795c9c8bBD61FFc14A6662944748F299cAcf,
            stateRoot: hex"0eee2ad48b334bea33d56dd43674fe442116efe09548743b6742ca2da3978fb6",
            transactionsRoot: hex"a552cb1836fc6e603706129b0b1c3cbbe154f256b8242d6f9402c7b92b9e9754",
            receiptsRoot: hex"70ac9c3b5ee026e7dfd5333e4a94e27ebf767212c0c79d33cc901cd07c21eab5",
            logsBloom: hex"632507c108a5e872ed8ca29ba3d0de439d0370e92f390289691d656ff82aea388114b1e56207327657191af3381d2fb48b2d870bee0e3c14378b0220a76c2949c3653acbd3125bef4b61dcaba03e72ab887e90e445c268410794d361d8f81fd0d7c431632282792bd5dfd8c411982c55d41224a0f5244ccdc44c1cbec46e11874924a77f2b68d9811ceac4d853e8047ea0278e89a9066bfa848c02f7f753d9fba359c4627d0aef51feee45fca4918711eef4046026e63b799be58e19042c6a52fbfb12367c4fc85a85059520804f33a64c77db5afa0a81b2e9d2559f8000f3b5b7f6b2885da04ccd97e535eec8e48d72876b1710e22c88d0088839fca905fcdf",
            difficulty: uint256(0x0),
            number: uint256(0x10d2ca3),
            gasLimit: uint256(0x1c9c380),
            gasUsed: uint256(0xdf2716),
            timestamp: uint256(0x64a7c683),
            extraData: hex"6265617665726275696c642e6f7267",
            mixHash: hex"9fedeb693abbb38950e7646e46469398fbf5aa3901258e6215e7b71bc5860f11",
            nonce: hex"0000000000000000",
            baseFeePerGas: uint256(0x7b89ea02a),
            withdrawalsRoot: hex"72b2211cb337dc2c6ff78a3358278bd6772f356f07d0702f05f83170e1a7bc5d"
        });

        ProverDto memory data = ProverDto({
            blockData: blockData,
            txReceipt: Data.getTxReceipt5(),
            blockNumber: uint256(0x10d2ca3),
            receiptProofBranch: Data.getReceiptsProofBranch5()
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }

    // Test incorrect scenarios
    function testFailVerifyTrieProof() public {
        TxReceipt memory txReceipt = Data.getIncorrectTxReceipt1();

        bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
        bytes memory expectedValue = bytesReceipt;
        if (txReceipt.receiptType > 0) {
            expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
        }

        bool success = Utils.verifyTrieProof(
            0x270ac2ede5bf10426ffb17cd1a0a46f620011ec92ef53f3afb3e656587a2f747,
            txReceipt.keyIndex,
            Data.getReceiptsProofBranch1(),
            expectedValue
        );

        assertTrue(success);
    }

    function testFailProveTransactionInclusion() public {
        blockhashStorage.setBlockHash(
            uint256(0x10d2ca6), 0x1f2274b771312ed973f587848c0e06d43445f92e93acdb52b3ac1b6b008c96a4
        );

        BlockData memory blockData = BlockData({
            parentHash: hex"a71d7d395fa99c10dabcf5727575137127baee8a21f6d7edcd5e39b6dad1d66f",
            sha3Uncles: hex"1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
            miner: 0x388C818CA8B9251b393131C08a736A67ccB19297,
            stateRoot: hex"5fe4dcd7db1f782670184adea5d1eefafa4525fdfd73e2bd3f2231dd7cdaf12e",
            transactionsRoot: hex"820a34c3ff9154472a50386f196fc779a8c44403919e4d33712d86f35e50516f",
            receiptsRoot: hex"270ac2ede5bf10426ffb17cd1a0a46f620011ec92ef53f3afb3e656587a2f747",
            logsBloom: hex"3c3d531e492e5339bd088cc1ce28d2695acb52064b17062941a3800e7c62080cc15599aa481913f972193b8364500b006f0dc2bcbe29f8a05685b8a6b12cb9808bf6d0182276184f2a1a440cbf28746e04295cc70d463a3a0b020e7aab6f872b02488a4a8340ee014156a39058663b29e51c2b5692a84444fa045858288f8dba0b0286784fe980943c4a4c15a35284669698b4e9ebc6e4ccc8b50f634c547966a2a151e3ebd462a25a00e6e6fbee17a4e4544875a2d80aab397b19ca4a0d92c46536c052848fc560821aa4c08c2c72b598cd75b2dca4095c85525f8e1c50f2ad163becabc163c44f86f516be08e468c0e461f226cfb0aa47c07d249c000ff4e7",
            difficulty: uint256(0x0),
            number: uint256(0x10d2ca6),
            gasLimit: uint256(0x1c9c380),
            gasUsed: uint256(0xe2f507),
            timestamp: uint256(0x64a7c6a7),
            extraData: hex"6265617665726275696c642e6f7267",
            mixHash: hex"8da2671e1312eea46891ffa353d09ad2f139ab16c079b2b212d9cf4c63211f24",
            nonce: hex"0000000000000000",
            baseFeePerGas: uint256(0x7a03f8e35),
            withdrawalsRoot: hex"c3be3075835092bcc3a000b8a0ecf4f6e80b63eeaeb09a569af77cff483d1ea9"
        });

        ProverDto memory data = ProverDto({
            blockData: blockData,
            txReceipt: Data.getTxReceipt1(),
            blockNumber: uint256(0x10d2ca6),
            receiptProofBranch: Data.getIncorrectReceiptsProofBranch1()
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }
}
