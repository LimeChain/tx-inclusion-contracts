// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ITransactionInclusionProver.sol";
import "./structs/ProverDto.sol";

contract DummyRefunder {
    ITransactionInclusionProver private _prover;

    constructor(address proverAddress) {
        _prover = ITransactionInclusionProver(proverAddress);
    }

    function claim(ProverDto calldata data) external view returns (bool) {
        return _prover.proveTransactionInclusion(data);
    }
}
