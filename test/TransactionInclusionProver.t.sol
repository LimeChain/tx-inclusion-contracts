// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";
import "../src/interfaces/IBlockhashStorage.sol";
import "../src/TrustedOracle.sol";
import "../src/TransactionInclusionProver.sol";

import "../src/structs/BlockData.sol";
import "../src/structs/ProverDto.sol";
import {Receipt as ReceiptStruct} from "../src/structs/Receipt.sol";
import "../src/structs/Log.sol";

contract TransactionInclusionProverTest is BaseTest {
    IBlockhashStorage public blockhashStorage;
    TransactionInclusionProver public prover;

    function setUp() public override {
        super.setUp();
        blockhashStorage = new TrustedOracle();
        prover = new TransactionInclusionProver(address(blockhashStorage));
    }

    function testProveTransactionInclusion1() public {
        blockhashStorage.setBlockHash(
            uint256(0x10d1026), 0x6b79c79696905e45fb822940f45556631339d57f9c6e644f3cd78cfbc2985735
        );

        BlockData memory blockData = BlockData({
            parentHash: hex"3286eb1ffad639ae2824fac18439d1ebbe9943902665c924013e0b4620a6f98d",
            sha3Uncles: hex"1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
            miner: 0x690B9A9E9aa1C9dB991C7721a92d351Db4FaC990,
            stateRoot: hex"a9f813e38625a51b7bd7b8c3290d6632de6f20083992ff10884d6c2956c8deb2",
            transactionsRoot: hex"bb590db959162c9fb6e8f7f88b38490e929cd3b00759629e49365746ec997b24",
            receiptsRoot: hex"75a55868341896b7911644b2d1f7de9b2babc2c0cc816847a205ab12937be9bf",
            logsBloom: hex"b0f40349c10410c2c42b92c0c1813393901140534306602020b1461c4710291400c1808540810120d80819051cb809942e061a90ae8320030690ee0023222d004070708c80082c2c2805e04e1302a8282195611c014a9a591c04294288e0a1001b444050572309c301c8a029c6481c18e010dfa5d2b86c01e20055368048ad064900a1e402080910094a0490010c3104e418a9a52d091688848226e104b69522ba110d02410063a9080062c518006f884770a0880621111b02a00c0020a11a440009144219054d63902430204cc0900300416b72020a22102a4ec522100828061e30e03c00a0006830250520008849948000d046e088416406301a030c000041",
            difficulty: uint256(0x0),
            number: uint256(0x10d1026),
            gasLimit: uint256(0x1c9c380),
            gasUsed: uint256(0xb8fe94),
            timestamp: uint256(0x64a66cf3),
            extraData: hex"6275696c64657230783639",
            mixHash: hex"7094110458c76faabdee7820a92777fda0d7d30189fa65928f27bb48014f415d",
            nonce: hex"0000000000000000",
            baseFeePerGas: uint256(0xd1ec505dd),
            withdrawalsRoot: hex"cae960f35f6928349b154f1c48ad82a19e3cc7b3b3ea175e382a0a2b88af64f9"
        });

        Log[] memory logs = new Log[](0);

        ReceiptStruct memory txReceipt = ReceiptStruct({
            status: true,
            cumulativeGasUsed: uint256(0x3ed7a4),
            logsBloom: hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            logs: logs
        });

        bytes32[] memory receiptProofBranch = new bytes32[](3);
        receiptProofBranch[0] = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        receiptProofBranch[1] = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        receiptProofBranch[2] = 0x075137d0ea46044b3b2640eb411a87d1cdf7645d6faacc012e25c01ac1111e85;

        ProverDto memory data = ProverDto({
            blockData: blockData,
            txReceipt: txReceipt,
            blockNumber: uint256(0x10d1026),
            receiptProofBranch: receiptProofBranch
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }

    function testProveTransactionInclusion2() public {
        blockhashStorage.setBlockHash(
            uint256(0x10d1026), 0x3286eb1ffad639ae2824fac18439d1ebbe9943902665c924013e0b4620a6f98d
        );

        BlockData memory blockData = BlockData({
            parentHash: 0x305ba59e43d9805fe41f1517cf17e5267b64b36aca0507327a987d0081325c59,
            sha3Uncles: 0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347,
            miner: 0x388C818CA8B9251b393131C08a736A67ccB19297,
            stateRoot: 0x20df3a1649c181e62de637e9d68aafdfdabd81ddc04d85fee90ed68f9868dfd9,
            transactionsRoot: 0x77a44d58b3717e1c85db71b825f8dbacca242cae2c75c4be1c8565a19b5f1c72,
            receiptsRoot: 0x4383a3e9f188afb16fbbf8419bd90bd3bd1797b93da3b03d4d316ce87a3e1843,
            logsBloom: hex"8cb7d48a5000108210889020d8951031000288102404c00004110406c0024800b20080a0d0090a312a080142520159302a650802ad25b001800cc8810a2d0cd18024a50c04a8490bf91443ea5450802818244a080ec5481010001013c829e8495a4032011a0212a20140148c891a2808c008040901048cc2922850bcb009710b0e101042205601410049410a4104080a20880183ad25003cc4114a4018941020aa800b60b808e0148002c89198403400051742000404201b01103e0081041212c020be028c0001084ce01480b88c812722c1000080200c1525404d4b0a01f000023821080080889311ac0014409008e4923010a0002a326000190a9322012605",
            difficulty: uint256(0x0),
            number: uint256(0x10d1025),
            gasLimit: uint256(0x1c9c380),
            gasUsed: uint256(0x50e4e8),
            timestamp: uint256(0x64a66ce7),
            extraData: hex"6265617665726275696c642e6f7267",
            mixHash: 0x767dab8d252203fa6c228ea45f14c5783008dfff5eda59d31b1364d8914ec62e,
            nonce: hex"0000000000000000",
            baseFeePerGas: uint256(0xe4618f11b),
            withdrawalsRoot: 0x5b53a1c5fa08ccdd3793c58ba12b85c3526d326880e381c065bbdd5ff07fe7bc
        });

        Log[] memory logs = new Log[](0);

        ReceiptStruct memory txReceipt = ReceiptStruct({
            status: true,
            cumulativeGasUsed: uint256(0x158301),
            logsBloom: hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            logs: logs
        });

        bytes32[] memory receiptProofBranch = new bytes32[](3);
        receiptProofBranch[0] = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        receiptProofBranch[1] = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        receiptProofBranch[2] = 0xca0fe200275cd527d579df1f8cced80a167c593eede3635c9e83b006ebdd51ec;

        ProverDto memory data = ProverDto({
            blockData: blockData,
            txReceipt: txReceipt,
            blockNumber: uint256(0x10d1026),
            receiptProofBranch: receiptProofBranch
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }

    function testProveTransactionInclusionWithStateRootZeroBeginning() public {
        blockhashStorage.setBlockHash(
            uint256(0x10d1026), 0x3e4a7402b80b7fd315d51399ce95fb84f9d65246901b3506e8fcc0abcc38401d
        );

        BlockData memory blockData = BlockData({
            parentHash: 0x1f2274b771312ed973f587848c0e06d43445f92e93acdb52b3ac1b6b008c96a4,
            sha3Uncles: 0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347,
            miner: 0x690B9A9E9aa1C9dB991C7721a92d351Db4FaC990,
            stateRoot: 0x0aebc93cd08f5cdbcba648bee33cf61e03b60bc3f424fabd6c0a4221d6426c8d,
            transactionsRoot: 0x90194abd8e79573c61b7a43f48b8e21183b18bd18b054b6d08c19ebd56dc84fa,
            receiptsRoot: 0x109d5c51f422cbbfaf1efe27466ecf9137cdc65be8325d99f4bdfa8123565282,
            logsBloom: hex"04e416134584563998408880a700d200400b20648b172282c30b873ef6ea0100e24557a4c5a60ea0b2005b0a04104fac06838b269b2368a0858126323020251d8a074208357819ce482a524948600d6a60550ec1154e9c3212a08c548a201829700809d28292e743006422928014180db6116b62f0fd6412e6508412c90e8f1c078c87799c08534204e2441b0a004065d11e84abe944884fc020017007d074607fa115c2b22824a01a917dcd34409e01a9f44c9c9e90eae188e08ce62e094182a1015527018fc52282aa204b0824747418d17029740a093808df54da4802a9e9143ae808c8adc2558d05068400c2244490a5981e01988ec1e46d7b810004548b",
            difficulty: uint256(0x0),
            number: uint256(0x10d2ca7),
            gasLimit: uint256(0x1c9c380),
            gasUsed: uint256(0xcc7aa4),
            timestamp: uint256(0x64a7c6b3),
            extraData: hex"6275696c64657230783639",
            mixHash: 0x7584fd8ee4124e9780a7079ec94e87a7d21a644345535e79916a8a0216cf8fd8,
            nonce: hex"0000000000000000",
            baseFeePerGas: uint256(0x79e323879),
            withdrawalsRoot: 0x04ac2427e475e8b2f6c8b5bea344b094abde87b0ed987c826be5c3f110689cd4
        });

        Log[] memory logs = new Log[](0);

        ReceiptStruct memory txReceipt = ReceiptStruct({
            status: true,
            cumulativeGasUsed: uint256(0x694dd),
            logsBloom: hex"00200000000000000000000080000000000100000000000000000000000000000004000000000000000000000000000002000000080000000000000000000000020000080000000000000008000000200000004001000000000000008020000000000000000002000000000000000000000000000000000000000010000000000000000000000000000000000000000000000001080000080000004000000000000000000000000000000001000000008000000000000000000000000000000000000002000000000000000000000000000000000000001000000000000000000000200000000000000000000000000000001000000008400000200000040000",
            logs: logs
        });

        bytes32[] memory receiptProofBranch = new bytes32[](3);
        receiptProofBranch[0] = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        receiptProofBranch[1] = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        receiptProofBranch[2] = 0x23480def6656562362b7cd5f16fe53855a2280e013b5091ef613cca574b718fb;

        ProverDto memory data = ProverDto({
            blockData: blockData,
            txReceipt: txReceipt,
            blockNumber: uint256(0x10d1026),
            receiptProofBranch: receiptProofBranch
        });

        assertTrue(prover.proveTransactionInclusion(data));
    }
}
