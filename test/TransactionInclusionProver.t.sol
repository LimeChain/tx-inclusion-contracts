// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";
import "../src/TrustedOracle.sol";
import "../src/TransactionInclusionProver.sol";

import "../src/structs/BlockData.sol";
import "../src/structs/ProverDto.sol";
import {Receipt as ReceiptStruct} from "../src/structs/Receipt.sol";
import "../src/structs/Log.sol";

contract TransactionInclusionProverTest is BaseTest {
    TrustedOracle public oracle;
    TransactionInclusionProver public prover;

    function setUp() public override {
        super.setUp();
        oracle = new TrustedOracle();
        prover = new TransactionInclusionProver(address(oracle));
    }

    function testProveTransactionInclusion() public {
        oracle.setBlockHash(uint256(0x10d1026), 0x2e832b0df569469e0be5ebe6fabadb46b59439128c86a5ba412d9626f2a98d0e);

        BlockData memory blockData = BlockData({
            parentHash: hex"3286eb1ffad639ae2824fac18439d1ebbe9943902665c924013e0b4620a6f98d",
            sha3Uncles: hex"1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
            miner: hex"690B9A9E9aa1C9dB991C7721a92d351Db4FaC990",
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
            bitvector: hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
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

        assertEq(prover.proveTransactionInclusion(data), true);
    }
}
