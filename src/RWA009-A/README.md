# hvb-onboarding

Onboarding [HVB](https://forum.makerdao.com/t/mip6-huntingdon-valley-bank-loan-syndication-collateral-onboarding-application/14219) to MCD. Forked and adapted from [MIP21-RWA-Example](https://github.com/makerdao/MIP21-RWA-Example) template repo.

## Install lib dependencies

```bash
make update
```

## Create a local `.env` file and change the placeholder values

```bash
cp .env.exaples .env # Run in the root of repo
```

## Test contracts

```bash
make test ILK=RWA009-A # Run unit tests
```

## Deploy contracts

```bash
make deploy-ces-goerli ILK=RWA009-A # to deploy contracts for the CES Fork of Goerli MCD
make deploy-goerli ILK=RWA009-A # to deploy contracts for the official Goerli MCD
make deploy-mainnet ILK=RWA009-A # to deploy contracts for the official Mainnet MCD
```

This script outputs a JSON file like this one:

```json
{
  "RWA009_TOKEN": "<address>",
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "ILK": "RWA009-A",
  "RWA009": "<address>",
  "MCD_JOIN_RWA009_A": "<address>",
  "RWA009_A_URN": "<address>",
  "RWA009_A_OUTPUT_CONDUIT": "<address>",
  "RWA009_A_OPERATOR": "<address>",
  "RWA009_A_MATE": "<address>"
}
```

You can save it using `stdout` redirection:

```bash
make deploy-ces-goerli ILK=RWA009-A > out/ces-goerli-addresses.json
```