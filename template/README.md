# ${{ILK}}

Onboarding [${{ILK}}](TODO)

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
  "${{ILK}}_TOKEN": "<address>",
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "ILK": "${{ILK}}",
  "${{ILK}}": "<address>",
  "MCD_JOIN_${{ILK}}_A": "<address>",
  "${{ILK}}_A_URN": "<address>",
  "${{ILK}}_A_OUTPUT_CONDUIT": "<address>",
  "${{ILK}}_A_OPERATOR": "<address>",
  "${{ILK}}_A_MATE": "<address>"
}
```

You can save it using `stdout` redirection:

```bash
make deploy-ces-goerli ILK=${{ILK}} > out/ces-goerli-addresses.json
```