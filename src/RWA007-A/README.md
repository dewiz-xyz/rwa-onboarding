# RWA007-A

Onboarding [RWA007-A](TODO)

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
make deploy-ces-goerli ILK=RWA007-A # to deploy contracts for the CES Fork of Goerli MCD
make deploy-goerli ILK=RWA007-A # to deploy contracts for the official Goerli MCD
make deploy-mainnet ILK=RWA007-A # to deploy contracts for the official Mainnet MCD
```

This script outputs a JSON file like this one:

```json
{
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "RWA_TOKEN_FAB": "<address>",
  "SYMBOL": "<address>",
  "NAME": "<address>",
  "ILK": "<address>",
  "RWA007": "<address>",
  "MCD_JOIN_RWA007_A": "<address>",
  "RWA007_A_URN": "<address>",
  "RWA007_JAR": "<address>",
  "RWA007_A_OUTPUT_CONDUIT": "<address>",
  "RWA007_A_INPUT_CONDUIT_JAR": "<address>",
  "RWA007_A_INPUT_CONDUIT_URN": "<address>",
}
```

You can save it using `stdout` redirection:

```bash
make deploy-ces-goerli ILK=RWA007-A > out/ces-goerli-addresses.json
```