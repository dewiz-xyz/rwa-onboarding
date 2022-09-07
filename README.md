# RWA Onboardings

This repo containe scripts for RWA deals onboarding

## Content

- [RWA008-A (SocGen)](https://github.com/clio-finance/rwa-onboarding/tree/master/src/RWA008-A)
- [RWA009-A (HvB)](https://github.com/clio-finance/rwa-onboarding/tree/master/src/RWA009-A)

## Usage

### Install lib dependencies

```
make update
```

### Install build dependencies

```
make nodejs-deps
```

### Build contracts

```
make build
```

### Test contracts

```
make test ILK=<ILK_NAME> # Run unit tests for a specific onboarding
```

### Deploy contracts

```
make deploy-ces-goerli ILK=<ILK_NAME> # to deploy contracts for the CES Fork of Goerli MCD
make deploy-goerli ILK=<ILK_NAME> # to deploy contracts for the official Goerli MCD
make deploy-mainnet ILK=<ILK_NAME> # to deploy contracts for the official Mainnet MCD
```
