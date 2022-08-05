# ${{ILK}}

Onboarding [ILK](TODO)

### Install lib dependencies

```bash
make update
```

### Create a local `.env` file and change the placeholder values

```bash
cp .env.exaples .env
```

### Deploy contracts

```bash
make deploy-ces-goerli ILK=${{ILK}} # to deploy contracts for the CES Fork of Goerli MCD
make deploy-goerli ILK=${{ILK}} # to deploy contracts for the official Goerli MCD
make deploy-mainnet ILK=${{ILK}} # to deploy contracts for the official Mainnet MCD
```

This script outputs a JSON file like this one:

```json
{
  "RWA009_TOKEN": "<address>",
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "ILK": "${{ILK}}",
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
make deploy-ces-goerli ILK=${{ILK}} > out/ces-goerli-addresses.json
```