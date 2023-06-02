# RWA014-A

Onboarding [RWA014-A](TODO)

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
make deploy-ces-goerli ILK=RWA014-A # to deploy contracts for the CES Fork of Goerli MCD
make deploy-goerli ILK=RWA014-A # to deploy contracts for the official Goerli MCD
make deploy-mainnet ILK=RWA014-A # to deploy contracts for the official Mainnet MCD
```

This script outputs a JSON file like this one:

```json
{
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "RWA_TOKEN_FAB": "<address>",
  "SYMBOL": "RWA014",
  "NAME": "RWA-014",
  "ILK": "RWA014-A",
  "RWA014": "<address>",
  "MCD_JOIN_RWA014_": "<address>",
  "RWA014__URN": "<address>",
  "RWA014__JAR": "<address>",
  "RWA014__OUTPUT_CONDUIT": "<address>"
}
```

You can save it using `stdout` redirection:

```bash
make deploy-ces-goerli ILK=RWA014-A > out/ces-goerli-addresses.json
```
