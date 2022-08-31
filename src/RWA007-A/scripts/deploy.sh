#!/bin/bash
set -eo pipefail

[ "$2" = "--estimate" ] && {
    ESTIMATE=true
}

source "${BASH_SOURCE%/*}/../../../scripts/_common.sh"

NETWORK=$1
[[ "$NETWORK" && ("$NETWORK" == "mainnet" || "$NETWORK" == "goerli" || "$NETWORK" == "ces-goerli") ]] || die "Please set NETWORK to one of ('mainnet', 'goelri', 'ces-goerli')"

# shellcheck disable=SC1091
source "${BASH_SOURCE%/*}/../../../scripts/build-env-addresses.sh" $NETWORK >&2

[[ "$ETH_RPC_URL" && "$(seth chain)" == "${NETWORK}" ]] || die "Please set a "${NETWORK}" ETH_RPC_URL"

export ETH_GAS=6000000

[[ -z "$NAME" ]] && export NAME="RWA-007AT1"
[[ -z "$SYMBOL" ]] && export SYMBOL="RWA007AT1"
#
# WARNING (2021-09-08): The system cannot currently accomodate any LETTER beyond
# "A".  To add more letters, we will need to update the PIP naming convention
# naming convention.  So, before we can have new letters we must:
# 1. Change the existing PIP naming convention
# 2. Change all the places that depend on that convention (this script included)
# 3. Make sure all integrations are ready to accomodate that new PIP name.
# ! TODO: check with team/PE if this is still the case
#
[[ -z "$LETTER" ]] && export LETTER="A"

FORGE_SCRIPT="${BASH_SOURCE%/*}/../../../scripts/forge-script.sh"

echo $1
# estimate
[ "$ESTIMATE" = "true" ] && {
    $FORGE_SCRIPT "${BASH_SOURCE%/*}/RWA007Deployment.s.sol:RWA007Deployment" "--estimate"
    exit 0
}

$FORGE_SCRIPT "${BASH_SOURCE%/*}/RWA007Deployment.s.sol:RWA007Deployment"

# TODO: 
#  - Figure out how to grab logs from outout 
#  - Verify contracts which are created through factories (RwaToken, Join)

# # print it
# cat <<JSON
# {
#     "MIP21_LIQUIDATION_ORACLE": "${MIP21_LIQUIDATION_ORACLE}",
#     "RWA_TOKEN_FAB": "${RWA_TOKEN_FAB}",
#     "SYMBOL": "${SYMBOL}",
#     "NAME": "${NAME}",
#     "ILK": "${ILK}",
#     "${SYMBOL}": "${RWA_TOKEN}",
#     "MCD_JOIN_${SYMBOL}_${LETTER}": "${RWA_JOIN}",
#     "${SYMBOL}_${LETTER}_URN": "${RWA_URN}",
#     "${SYMBOL}_${LETTER}_JAR": "${RWA_JAR}",
#     "${SYMBOL}_${LETTER}_OUTPUT_CONDUIT": "${RWA_OUTPUT_CONDUIT}"
#     "${SYMBOL}_${LETTER}_INPUT_CONDUIT_JAR": "${RWA_INPUT_CONDUIT_JAR}"
#     "${SYMBOL}_${LETTER}_INPUT_CONDUIT_URN": "${RWA_INPUT_CONDUIT_URN}"
# }
# JSON