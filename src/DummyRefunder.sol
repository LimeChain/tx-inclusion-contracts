// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IReceiptInclusionProver.sol";
import "./structs/ProverDto.sol";

contract DummyRefunder {
    IReceiptInclusionProver private _prover;

    constructor(address proverAddress) {
        _prover = IReceiptInclusionProver(proverAddress);
    }

    function claim(ProverDto calldata data) external view returns (bool) {
        return _prover.proveReceiptInclusion(data);
    }
}
