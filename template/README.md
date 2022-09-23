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
  "MIP21_LIQUIDATION_ORACLE": "<address>",
  "RWA_TOKEN_FAB": "<address>",
  "SYMBOL": "${{TOKEN_SYMBOL}}",
  "NAME": "${{TOKEN_NAME}}",
  "ILK": "${{ILK}}",
  "${{TOKEN_SYMBOL}}": "<address>",
  "MCD_JOIN_${{TOKEN_SYMBOL}}_${{TOKEN_LETTER}}": "<address>",
  "${{TOKEN_SYMBOL}}_${{TOKEN_LETTER}}_URN": "<address>",
  "${{TOKEN_SYMBOL}}_${{TOKEN_LETTER}}_JAR": "<address>",
  "${{TOKEN_SYMBOL}}_${{TOKEN_LETTER}}_OUTPUT_CONDUIT": "<address>"
}
```

You can save it using `stdout` redirection:

```bash
make deploy-ces-goerli ILK=${{ILK}} > out/ces-goerli-addresses.json
```
