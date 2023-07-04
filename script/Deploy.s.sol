// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {TrustedOracle} from "../src/TrustedOracle.sol";
import {ReceiptInclusionProver} from "../src/ReceiptInclusionProver.sol";
import {DummyRefunder} from "../src/DummyRefunder.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PK");
        vm.startBroadcast(deployerPrivateKey);

        TrustedOracle oracle = new TrustedOracle();
        ReceiptInclusionProver prover = new ReceiptInclusionProver(
            address(oracle)
        );
        DummyRefunder refunder = new DummyRefunder(address(prover));

        vm.stopBroadcast();
    }
}
