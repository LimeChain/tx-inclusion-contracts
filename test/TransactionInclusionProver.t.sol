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

    // Tes correct scenarios
    function testVerifyTrieProof1() public {
        TxReceipt memory txReceipt = Data._getTxReceipt1();

        bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
        bytes memory expectedValue = bytesReceipt;
        if (txReceipt.receiptType > 0) {
            expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
        }

        bool success = Utils.verifyTrieProof(
            0x270ac2ede5bf10426ffb17cd1a0a46f620011ec92ef53f3afb3e656587a2f747, // receiptsRoot
            txReceipt.keyIndex,
            Data._getReceiptsProofBranch1(),
            expectedValue
        );

        assertTrue(success);
    }

    function testVerifyTrieProof2() public {
        bytes[] memory receiptProofBranch = new bytes[](3);
        receiptProofBranch[0] =
            hex"f891a074654fba97d83670520e4e54683bcd3afbfa20742acf0bc94916582df9b1eaa9a02aa47f0d484f2ff7b97cf544ce84ed5bb68db970d3c5bd0680d142069ef0d45ba02ca70a54ac0018d930413e4af9b549a801b8ecf3230aba4de397a20404e9141c8080808080a01e44490691f53f3de1413d47a7db3570c621c481816b0f94805c914c398ef8ed8080808080808080";
        receiptProofBranch[1] =
            hex"f90211a0f84cf80ec85666982d618d60961eb864c8bdfcebe56c8f0b772fcf9c97373fdfa083e5b79ab069cb38d97ffa1cc6bae57080971ed6a27bb94ebf0a5c46cd379577a06306af2bc061298e86bf2c5e32aa7f6fa27567fca6269a520cedf0f9a5780bd6a09fbc6e09b3364d24eab44b292d8635168c3a16c28bf5888124cefa5e14a1e23ea02c2f59aeef516d45811ac3bc89d318c3ca4fcefaabefd3131eddbdb95fb68b78a0ddd505432a46d199b30bdde73ff6b8fdac7e00d5d996cc18074b6ce2ef58874da08c155d0e5e3b6eb2c776a84bb8e060802866285f5ded9ee33098b0ea4894a596a0bb45f1da1ca7378583574bd29de91ccb4eaeb730236e6f3ef1eb8f5c6b3c6faaa09b5a73070350cccc4d0da637c42c81fec63861693a522014fcdbd85fe5de27cba05f60c9a17d3d2975972aa1b844d1e4cda203bef645a0e246a1afb5f6f560bc80a04af2e03b087d810e0feffa03e661a281996ff48b2331154a3f6b390ab8d6c9f8a026654e067145eacf7ceebef44ad6336cb20d86a929fb2dfe46f0740ee3a1b917a01122f4853ab32dcb30ddc7218c62a310b45aee840136fa80825b33ef2acfc65ea03afc0dc6b212c01533d1a745b7ed3163f5f7acdcfc4618c8edaf6e8cd95db217a08079c7cb7578a19da5c0d1e456cce944c420b375a98a53e2d442a2b5b7710f8aa089130f7e59e664141c56679c2d6fc2cbdfd57740b8ff09c848324bc0bb62c38a80";
        receiptProofBranch[2] =
            hex"f9033020b9032c02f9032801830d0426b9010000000000000000000000000000000000002000000000000000000000000000040000002000000000001020001000000000000000001008000000000000000000000000000000000000000200000000000000000000002000001000040000008000000000108000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000020000000000400400000000000000000000000000000020000000000000020000000000000000000000000000000000008020000000000004000000000000000080000000000420000000000000000000000000000000000000000000000000000000000000000000000000f9021df89b94c3511006c04ef1d78af4c8e0e74ec18a6e64ff9ef863a09dbb0e7dda3e09710ce75b801addc87cf9d9c6c581641b3275fca409ad086c62a000000000000000000000000093f4c8f670578f6d10bf8b77826f04e9c3a4b9e2a002778d01ac46b081e7ac3b0cb53614b4925e3adb5ec6ab7eb40bd8e615064e47a00000000000000000000000000000000000000000000000000429d069189e0000f9017d94de29d060d45901fb19ed6c6e959eb22d8626708ef884a0db80dd488acf86d17c747445b0eabb5d57c541d3bd7b6b87af987858e5066b2ba0000000000000000000000000c3511006c04ef1d78af4c8e0e74ec18a6e64ff9ea0073314940630fd6dcda0d772d4c972c4e0a9946bef9dabf4ef84eda8ef542b82a002d757788a8d8d6f21d1cd40bce38a8222d70654214e96ff95d8086e684fbee5b8e00000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000004c4170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000302778d01ac46b081e7ac3b0cb53614b4925e3adb5ec6ab7eb40bd8e615064e470000000000000000000000000000000000000000000000000429d069189e00000000000000000000000000000000000000000000000000000000000000000000";

        TxReceipt memory txReceipt = Data._getTxReceipt2();

        bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
        bytes memory expectedValue = bytesReceipt;
        if (txReceipt.receiptType > 0) {
            expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
        }

        bool success = Utils.verifyTrieProof(
            0x03ad740576271763dfda5d6bce4cb668f44b5d0592b583d2fdbe970b9eb276cc, // receiptsRoot
            txReceipt.keyIndex,
            receiptProofBranch,
            expectedValue
        );

        assertTrue(success);
    }

    function testVerifyTrieProof3() public {
        bytes[] memory receiptProofBranch = new bytes[](3);
        receiptProofBranch[0] =
            hex"f90131a0dc4eb340c97c506352685354b072697c58a46fd0859732d74ac7a2e89d03a67ba0fc41395fa6a7ed43a43c622915a7016dd2e6d26c1e15bffe86935e9d44e318c2a01e2a91ec6127a8c9d83ba35ae79815c654a49971fd24cac6bde4fb0965b2bae4a069f9229570fc548f63bc85673b97bd7b1a7781887740b113a894923ca7e703afa0fe367c8dde446c09301e0e77a8c8b03c10ac8ba5a23540da80132245651bd7a7a0b1375a3d3222187cdf40c1bcba011ac268649a6123abf1bbc41c523be6e6759ba0a4f2fbc5cbc7565084031256f641aad4f96672b7389d1ecbb6bf3eebff73c028a079f6a5cd6288f3393aa1a263f85f345d060bd62fc7f8ee25c0bd313d2ef1d623a0c0f9bc21fd80607feeac50ce29118fe145b078a4902a75a9fac96b191c269d8a8080808080808080";
        receiptProofBranch[1] =
            hex"f901f180a09350a92f9a3fcea6da6a67dde9db1aab57457f97a6abac3da5ab991c6712ce9ca0e95067cd1f97a33362319e21dfa808178991c54a849b644d3374913be0f0064aa0fc622ff7e8f103f7b7bc8f45fe1691659bbcec51a0245ed2737e350f09e5fe67a07a1f79b515638d89423880959f54a6db331d3c69cf27980bd06bea25c79e9de5a01dac1e6505a4645c9e03948f5395abb003b3d89bad68d50886aa1c9668b2b5bea0923b3966a08256fcf5633f7760ef4ee7f0f87dfe8ef052d92e79861ccd286682a0a8a50181ebf208a5cf9bdc92f685c7fa0a05f5c83b5fa835c8d2d7cc2726da42a09cd3d05afbd82e274fd84ffb4cc81a04c9f178a27ba9cd7104c0d336b907cde6a00f02466ad62e0faa503a8eae8a1404da796476817996eea1411475a8cb2a4229a06f375ee36ae9e6c393a81b7315b4f60d89805f081c951f3dc226e65a781ae292a0346a4177227e2f87b4e2aa94591592aa909a3a64e14fc88440a54be7e60e2ed8a063a0c4a30221a28c918691f1cf3d17d8f060b36e197292f8fb985cd965603232a0dc1ab2e922622a6b2076ef74a3a7c960f6fd7b8bf5c57106251709be4696b5b1a05772c661a8ba0b30015497e44c69ba24ca1946395dc5019536bf3295e177565ba070674e739f9d4aa83102166fb9bca9e7daf1ce5efc6967d34436758d9fbf579380";
        receiptProofBranch[2] =
            hex"f9044220b9043e02f9043a01830f7e43b9010000200000000000000000000080000000000100000000000000000000000000000004000000000000000000000000000002000000080100000000000000000000020000080000000000000008000000200000004001000000000000008020000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000001080000080000004000000000000000000000000000000000000000008000000000000000000000000000000000000002000000000000000200000000000020000000001000000000000000000000200000000000000000000000000000001000000008400000000000040000f9032ff87a94c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2f842a0e1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109ca00000000000000000000000003fc91a3afd70395cd496c647d5a6cc9d4b2b7fada0000000000000000000000000000000000000000000000000008e1bc9bf040000f89b94c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2f863a0ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3efa00000000000000000000000003fc91a3afd70395cd496c647d5a6cc9d4b2b7fada0000000000000000000000000105af6ed72d373b685b0a36347be7e08efa87536a0000000000000000000000000000000000000000000000000008e1bc9bf040000f89b9489b16e61e79ff20b0cf0026ea10a12b74bd3ccc0f863a0ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3efa0000000000000000000000000105af6ed72d373b685b0a36347be7e08efa87536a000000000000000000000000073e2ececad90d5e3b8a649220394d239665db05ba00000000000000000000000000000000000000000000000000001212d169919adf87994105af6ed72d373b685b0a36347be7e08efa87536e1a01c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1b840000000000000000000000000000000000000000000000000005b3e0efab536850000000000000000000000000000000000000000000000002d426b7e0ea2bab4f8fc94105af6ed72d373b685b0a36347be7e08efa87536f863a0d78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822a00000000000000000000000003fc91a3afd70395cd496c647d5a6cc9d4b2b7fada000000000000000000000000073e2ececad90d5e3b8a649220394d239665db05bb8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008e1bc9bf0400000000000000000000000000000000000000000000000000000001212d169919ad0000000000000000000000000000000000000000000000000000000000000000";

        TxReceipt memory txReceipt = Data._getTxReceipt3();

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
            0x109d5c51f422cbbfaf1efe27466ecf9137cdc65be8325d99f4bdfa8123565282, //root
            txReceipt.keyIndex,
            receiptProofBranch,
            expectedValue
        );

        assertTrue(success);
    }

    function testVerifyTrieProof4() public {
        bytes[] memory receiptProofBranch = new bytes[](3);
        receiptProofBranch[0] =
            hex"f8d1a0e7e4e1d287e990d928e91eac9a4cedca394a8be3931f23d206c2dc42f2a83ca3a007e365c5ce452ef0feaf230fd76108fa9544a23192c8f80b4085d836a2225e41a07e1505273dab2e40538b4dc1e62bb4c948906fa5e6d9a4656670fb11514306c8a09153af6ab1ce50d33e70405ffc7383281659da0618f3cc623feef1b88b89f16ea0e89ace6a049d831c6e69ac8f845620af9c60da7ece855cfeee71a964edf1e2eb808080a0e58215be848c1293dd381210359d84485553000a82b67410406d183b42adbbdd8080808080808080";
        receiptProofBranch[1] =
            hex"f901f180a0b54775a99637d46fe23c7f1a069a58ce88c22bdb6d43fa50f2dde9c6eede4781a0af9409cd88788b47541a2fb62976c58d04254bb9b1fb1f2ddd2c1c74b6b66d13a03623454f6d8a2f948b0fd89d518c9cb3242db1f9c28716c8b53a5dc6f555e093a0f7ad6c28f82d86f05c5d7f19c1fbdce6378ca9101e9d4cecb77fdd96560bd51ea05cc16bffffa61a7742b925e2a27c49c2b5acc1668075484f43e69b1fa44f7689a0d34b03235432abbdd0a3c41ab34b4c73a77ff01f19156d501d55f80cb79cc9daa0cd436d44ab9039196fdb4c6a465414ab8bae246c3643eaeefa7c0db1a7148820a0520b1498c221479f544799d6b1ad9a0813af6c7e7194ae92153cfa89e62ef27ea018d9047bac24390846f38d84e09db7305c919b6b8321484b9888c6867202b806a0b0da8087898c4debfe6dc4fd857550100762f07391e738bb6f9a679c9b28a27fa054b6aa94ef9436b734117a84ac41944ff0c92ecfbfff360e18db1718530d7a42a04691700e4e915807dddec6f40e693673ffb84ee35cac8c531bbce52708cd48a1a0e8679eda80264850713f9c14f2d64cc21bf996c522c04f20f8f87972a95b5e70a0480c81a39a4e81cdd1d784b097ccdca7ec1275e5861b03f5289d44192ca21c16a03da997586f7b776321e2ace44799006dac5d91d4dbd7e42ed3315fcb046bbf9f80";
        receiptProofBranch[2] =
            hex"f901ae20b901aaf901a70183011b2ab9010000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000200000000000000000000002000000000000000000000000000008000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000010000080000000000040000000000000000020000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000f89df89b94499d11e0b6eac7c0593d8fb292dcbbf815fb29aef863a0ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3efa0000000000000000000000000e84d601e5d945031129a83e5602be0cc7f182cf3a0000000000000000000000000e041593d11bbabfa3af4191eba6829359c77a6a4a00000000000000000000000000000000000000000000000000de0b6b3a7640000";

        TxReceipt memory txReceipt = Data._getTxReceipt4();

        bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
        bytes memory expectedValue = bytesReceipt;
        if (txReceipt.receiptType > 0) {
            expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
        }

        bool success = Utils.verifyTrieProof(
            0x1026f7f0ca1c5c9740019d0c25f4c92a7cfc96388a8f1c03d8e17e871274ae76, // receiptsRoot
            txReceipt.keyIndex,
            receiptProofBranch,
            expectedValue
        );

        assertTrue(success);
    }

    function testProveTransactionInclusion1() public {
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
            txReceipt: Data._getTxReceipt1(),
            blockNumber: uint256(0x10d2ca6),
            receiptProofBranch: Data._getReceiptsProofBranch1()
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }

    function testProveTransactionInclusion5_zeroStateRoot() public {
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
            txReceipt: Data._getTxReceipt5(),
            blockNumber: uint256(0x10d2ca3),
            receiptProofBranch: Data._getReceiptsProofBranch5()
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }

    // Test incorrect scenarios
    function testFailVerifyTrieProof1() public {
        TxReceipt memory txReceipt = Data._getIncorrectTxReceipt1();

        bytes memory bytesReceipt = Utils.encodeReceipt(txReceipt);
        bytes memory expectedValue = bytesReceipt;
        if (txReceipt.receiptType > 0) {
            expectedValue = abi.encodePacked(bytes1(uint8(txReceipt.receiptType)), bytesReceipt);
        }

        bool success = Utils.verifyTrieProof(
            0x270ac2ede5bf10426ffb17cd1a0a46f620011ec92ef53f3afb3e656587a2f747, // receiptsRoot
            txReceipt.keyIndex,
            Data._getReceiptsProofBranch1(),
            expectedValue
        );

        assertTrue(success);
    }

    function testFailProveTransactionInclusion1() public {
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
            txReceipt: Data._getTxReceipt1(),
            blockNumber: uint256(0x10d2ca6),
            receiptProofBranch: Data._getIncorrectReceiptsProofBranch1()
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }
}
