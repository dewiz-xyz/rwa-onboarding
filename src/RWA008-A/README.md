# SocGen OFH Onboarding

Repository for onboarding SocGen's [OFH](https://forum.makerdao.com/t/security-tokens-refinancing-mip6-application-for-ofh-tokens/10605/8) to MCD.

## Architecture Overview

TODO.

### Install lib dependencies

```bash
make update
```

### Build contracts

```bash
make build
```

### Test contracts

```bash
make test-local # using a local node listening on http://localhost:8545
make test-remote # using a remote node (alchemy). Requires ALCHEMY_API_KEY env var.
```

### Deploy contracts

```bash
make deploy-ces-goerli RWA008-A # to deploy contracts for the CES Fork of Goerli MCD
make deploy-goerli RWA008-A # to deploy contracts for the official Goerli MCD
make deploy-mainnet RWA008-A # to deploy contracts for the official Mainnet MCD
```

This script outputs a JSON file like this one:

```json
{
  "SYMBOL": "RWA008AT5",
  "NAME": "RWA-008-AT5",
  "ILK": "RWA008AT5-A",
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "RWA_TOKEN_FACTORY": "<address>",
  "RWA_URN_PROXY_ACTIONS": "<address>",
  "RWA008AT5": "<address>",
  "MCD_JOIN_RWA008AT5_A": "<address>",
  "RWA008_A_URN": "<address>",
  "RWA008_A_INPUT_CONDUIT": "<address>",
  "RWA008_A_OUTPUT_CONDUIT": "<address>",
  "RWA008_A_OPERATOR": "<address>",
  "RWA008_A_MATE": "<address>"
}
```
