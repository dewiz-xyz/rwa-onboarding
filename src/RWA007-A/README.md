# RWA007-A

Onboarding RWA007-A Monetalis Clydesdale.

Find [architecture and technical assessment here.](https://github.com/clio-finance/rwa-onboarding/blob/master/src/RWA007-A/tech_assessment.md)

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
make deploy ILK=RWA007-A NETWORK=ces-goerli # to deploy contracts for the CES Fork of Goerli MCD
make deploy ILK=RWA007-A NETWORK=goerli # to deploy contracts for the official Goerli MCD
make deploy ILK=RWA007-A NETWORK=mainnet # to deploy contracts for the official Mainnet MCD
```

This script outputs a JSON file like this one:

```json
{
  "SYMBOL": "<address>",
  "NAME": "<address>",
  "ILK": "<address>",
  "RWA007": "<address>",
  "MCD_JOIN_RWA007_A": "<address>",
  "RWA007_A_URN": "<address>",
  "RWA007_A_JAR": "<address>",
  "RWA007_A_OUTPUT_CONDUIT": "<address>",
  "RWA007_A_INPUT_CONDUIT_JAR": "<address>",
  "RWA007_A_INPUT_CONDUIT_URN": "<address>"
}
```

You can save it using `stdout` redirection:

```bash
make deploy ILK=RWA007-A NETWORK=goerli > out/ces-goerli-addresses.json
```
