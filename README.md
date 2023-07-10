[![MIT License][license-shield]][license-url]

## Installation

```
forge install
```

## Run tests

```
forge test
```

## Start local node

```
anvil
```

## Environment variables

Create an .env file in the main dir and fill the variables as shown in .env.example

## Deploy contracts to local node

In another terminal execute:

```
source .env && forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --broadcast
```

## Generate typechain types for usage in TypeScript

If you want to generate typings for JS usage install typechain globally:

```
npm install -g typechain @typechain/ethers-v5
```

\*the example is for ethers v5, change the version if you're using a different one

And run the command for generating the types:

```
typechain --target ethers-v5 --out-dir ./typechain './out/**/*.json'
```

[license-url]: https://github.com/LimeChain/tx-inclusion-contracts/blob/main/LICENSE.txt
[license-shield]: https://img.shields.io/badge/License-MIT-green.svg
