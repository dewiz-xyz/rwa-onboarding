#!/bin/bash
set -eo pipefail

[ "$2" = "--estimate" ] && {
	ESTIMATE=true
}

source "${BASH_SOURCE%/*}/../../../scripts/_common.sh"

NETWORK=$1
shift
ARGS="$@"

[[ "$NETWORK" && ("$NETWORK" == "mainnet" || "$NETWORK" == "goerli" || "$NETWORK" == "ces-goerli") ]] || die "Please set NETWORK to one of ('mainnet', 'goerli', 'ces-goerli')"

check-network $NETWORK

# shellcheck disable=SC1091
source "${BASH_SOURCE%/*}/../../../scripts/build-env-addresses.sh" $NETWORK >&2

FORGE_SCRIPT="${BASH_SOURCE%/*}/../../../scripts/forge-script.sh"

# estimate
[ "$ESTIMATE" = "true" ] && {
    RESPONSE=$($FORGE_SCRIPT "${BASH_SOURCE%/*}/PAXUSDJarDeployment.s.sol:PAXUSDJarDeployment" --json $ARGS tee >(cat 1>&2))
    jq -R 'fromjson? | .logs | .[]' <<<"$RESPONSE" | jq -R 'fromjson?' | jq -s 'map( {(.[0]): .[1]} ) | add'
    exit 0
}

RESPONSE=$($FORGE_SCRIPT "${BASH_SOURCE%/*}/PAXUSDJarDeployment.s.sol:PAXUSDJarDeployment" --json --broadcast --slow --verify --retries 10 $ARGS | tee >(cat 1>&2))
jq -R 'fromjson? | .logs | .[]' <<<"$RESPONSE" | jq -R 'fromjson?' | jq -s 'map( {(.[0]): .[1]} ) | add'

# IF we hit block limit we need to parse output from previouse command and set deployed addresses to the ENV (hopefully Foundry will fix vm.setEnv wich we can use for that)
# Then we can simply run another method of Deployment contract and pick up this ENV vars there using `--sig "secondPartOfDeployment()"` flag of `forge script` command
