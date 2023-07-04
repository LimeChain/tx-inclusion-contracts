// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {TrustedOracle} from "../src/TrustedOracle.sol";
import {TransactionInclusionProver} from "../src/TransactionInclusionProver.sol";
import {DummyRefunder} from "../src/DummyRefunder.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        vm.startBroadcast(deployerPrivateKey);

        TrustedOracle oracle = new TrustedOracle();
        TransactionInclusionProver prover = new TransactionInclusionProver(
            address(oracle)
        );
        DummyRefunder refunder = new DummyRefunder(address(prover));

        vm.stopBroadcast();
    }
}
