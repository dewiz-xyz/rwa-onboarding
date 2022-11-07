# SocGen OFH Onboarding

Repository for onboarding SocGen's [OFH](https://forum.makerdao.com/t/security-tokens-refinancing-mip6-application-for-ofh-tokens/10605/8) to MCD.

Find [architecture and technical assessment here.](https://github.com/clio-finance/rwa-onboarding/blob/master/src/RWA008-A/tech_assessment.md)

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
make test ILK=RWA008-A # Run unit tests
```

## Deploy contracts

```bash
make deploy-ces-goerli ILK=RWA008-A # to deploy contracts for the CES Fork of Goerli MCD
make deploy-goerli ILK=RWA008-A # to deploy contracts for the official Goerli MCD
make deploy-mainnet ILK=RWA008-A # to deploy contracts for the official Mainnet MCD
```

This script outputs a JSON file like this one:

```json
{
  "SYMBOL": "RWA008",
  "NAME": "RWA-008",
  "ILK": "RWA008-A",
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "RWA_TOKEN_FACTORY": "<address>",
  "RWA_URN_PROXY_ACTIONS": "<address>",
  "RWA008": "<address>",
  "MCD_JOIN_RWA008_A": "<address>",
  "RWA008_A_URN": "<address>",
  "RWA008_A_INPUT_CONDUIT": "<address>",
  "RWA008_A_OUTPUT_CONDUIT": "<address>",
  "RWA008_A_OPERATOR": "<address>",
  "RWA008_A_MATE": "<address>"
}
```
