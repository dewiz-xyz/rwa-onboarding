#!/bin/bash
set -eo pipefail

source "${BASH_SOURCE%/*}/_common.sh"

deploy() {
  normalize-env-vars

  local PASSWORD="$(extract-password)"
  local PASSWORD_OPT=()
  if [ -n "$PASSWORD" ]; then
    PASSWORD_OPT=(--password "$PASSWORD")
  fi

  check-required-etherscan-api-key

  local RESPONSE=
  # Log the command being issued, making sure not to expose the password
  log "forge script --broadcast --slow --verify --retries 10 --json --sender $ETH_FROM --rpc-url $ETH_RPC_URL --gas-price $ETH_GAS --gas-limit $FOUNDRY_GAS_LIMIT --keystores="$FOUNDRY_ETH_KEYSTORE_FILE" $(sed 's/ .*$/ [REDACTED]/' <<<"${PASSWORD_OPT[@]}")" $(printf ' %q' "$@")
  # Currently `forge script` sends the logs to stdout instead of stderr.
  # This makes it hard to compose its output with other commands, so here we are:
  # 1. Duplicating stdout to stderr through `tee`
  # 2. Extracting only the address of the deployed contract to stdout
  RESPONSE=$(forge script --broadcast --slow --verify --retries 10 --json --sender $ETH_FROM --rpc-url $ETH_RPC_URL --gas-price $ETH_GAS --gas-limit $FOUNDRY_GAS_LIMIT --keystores="$FOUNDRY_ETH_KEYSTORE_FILE" "${PASSWORD_OPT[@]}" "$@" | tee >(cat 1>&2))
  # jq -R 'fromjson? | .logs | .[]' <<<"$RESPONSE" | xargs -I@ cast --to-ascii @ | jq -R 'fromjson?' | jq -s 'map( {(.[0]): .[1]} ) | add'
}

estimate() {
  normalize-env-vars

  local PASSWORD="$(extract-password)"
  local PASSWORD_OPT=()
  if [ -n "$PASSWORD" ]; then
    PASSWORD_OPT=(--password "$PASSWORD")
  fi

  check-required-etherscan-api-key

  local RESPONSE=
  RESPONSE=$(forge script --json --sender $ETH_FROM --rpc-url $ETH_RPC_URL --gas-price $ETH_GAS --gas-limit $FOUNDRY_GAS_LIMIT --keystores="$FOUNDRY_ETH_KEYSTORE_FILE" "${PASSWORD_OPT[@]}" "$@" | tee >(cat 1>&2))
}

check-required-etherscan-api-key() {
  # Require the Etherscan API Key if --verify option is enabled
  set +e
  if grep -- '--verify' <<<"$@" >/dev/null; then
    [ -n "$FOUNDRY_ETHERSCAN_API_KEY" ] || die "$(err-msg-etherscan-api-key)"
  fi
  set -e
}

usage() {
  cat <<MSG
forge-script.sh [<src>:]<contract> 

Examples:

    # deploy
    forge-script.sh script/DeployGoerli.s.sol:Goerli

    # estimate
    forge-script.sh script/DeployGoerli.s.sol:Goerli --estimate
MSG
}

if [ "$0" = "$BASH_SOURCE" ]; then
  [ "$1" = "-h" -o "$1" = "--help" ] && {
    echo -e "\n$(usage)\n"
    exit 0
  }

  [ "$2" = "--estimate" ] && {
    estimate "$1"
    exit 0
  }

  deploy "$@"
fi
