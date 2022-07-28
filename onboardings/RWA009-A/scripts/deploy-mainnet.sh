#!/bin/bash
# bash scripts/deploy-mainnet.sh
set -eo pipefail

source "${BASH_SOURCE%/*}/_common.sh"
# shellcheck disable=SC1091
source "${BASH_SOURCE%/*}/build-env-addresses.sh" mainnet >&2

[ -f "${BASH_SOURCE%/*}/../.env" ] && source "${BASH_SOURCE%/*}/../.env"

[[ "$ETH_RPC_URL" && "$(cast chain)" == "ethlive" ]] || die "Please set a mainnet ETH_RPC_URL"
[[ -z "$CHANGELOG" ]] && die 'Please set the CHANGELOG env var'
[[ -z "$MCD_PAUSE_PROXY" ]] && die 'Please set the MCD_PAUSE_PROXY env var'
[[ -z "$MIP21_LIQUIDATION_ORACLE" ]] && die 'Please set the MIP21_LIQUIDATION_ORACLE env var'
[[ -z "$RWA_TOKEN_FAB" ]] && die 'Please set the RWA_TOKEN_FAB env var'
[[ -z "$MCD_VAT" ]] && die 'Please set the MCD_VAT env var'
[[ -z "$MCD_JUG" ]] && die 'Please set the MCD_JUG env var'
[[ -z "$MCD_JOIN_DAI" ]] && die 'Please set the MCD_JOIN_DAI env var'
[[ -z "$DESTINATION_ADDRESS" ]] && die 'Please set the DESTINATION_ADDRESS env var'

# TODO: confirm for mainnet deployment
# export ETH_GAS=6000000

# TODO: confirm if name/symbol is going to follow the RWA convention
# TODO: confirm with DAO at the time of mainnet deployment if OFH will indeed be 007
[[ -z "$NAME" ]] && NAME="RWA-009"
[[ -z "$SYMBOL" ]] && SYMBOL="RWA009"
#
# WARNING (2021-09-08): The system cannot currently accomodate any LETTER beyond
# "A".  To add more letters, we will need to update the PIP naming convention
# to include the letter.  Unfortunately, while fixing this on-chain and in our
# code would be easy, RWA001 integrations may already be using the old PIP
# naming convention.  So, before we can have new letters we must:
# 1. Change the existing PIP naming convention
# 2. Change all the places that depend on that convention (this script included)
# 3. Make sure all integrations are ready to accomodate that new PIP name.
# ! TODO: check with team/PE if this is still the case
#
[[ -z "$LETTER" ]] && LETTER="A";

ILK="${SYMBOL}-${LETTER}"
ILK_ENCODED=$(cast --to-bytes32 "$(cast --from-ascii ${ILK})")

# build it
make build

FORGE_DEPLOY="${BASH_SOURCE%/*}/forge-deploy.sh"
CAST_SEND="${BASH_SOURCE%/*}/cast-send.sh"

confirm_before_proceed() {
    local REPLY
    read -p "$1 [Y/n] " -n 1 -r REPLY >&2
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 1
    else
        return 0
    fi
}

# tokenize it
[[ -z "$RWA_TOKEN" ]] && {
    debug 'WARNING: `$RWA_TOKEN` not set. Deploying it...'
    confirm_before_proceed "Deploy RWA_TOKEN?"

    TX=$($CAST_SEND "${RWA_TOKEN_FAB}" 'createRwaToken(string,string,address)' "$NAME" "$SYMBOL" "$MCD_PAUSE_PROXY")
    debug "TX: $TX"

    RECEIPT="$(cast receipt --json $TX)"
    TX_STATUS="$(jq -r '.status' <<<"$RECEIPT")"
    [[ "$TX_STATUS" != "0x1" ]] && die "Failed to create ${SYMBOL} token in tx ${TX}."

    RWA_TOKEN="$(jq -r ".logs[0].address" <<<"$RECEIPT")"
    debug "${SYMBOL}: ${RWA_TOKEN}"
}

# route it
debug "${SYMBOL}_${LETTER}_OUTPUT_CONDUIT: ${DESTINATION_ADDRESS}"

# join it
[[ -z "$RWA_JOIN" ]] && {
    confirm_before_proceed "Deploy RWA_JOIN?"

	TX=$($CAST_SEND "${JOIN_FAB}" 'newAuthGemJoin(address,bytes32,address)' "$MCD_PAUSE_PROXY" "$ILK_ENCODED" "$RWA_TOKEN")
    debug "TX: $TX"

    RECEIPT="$(cast receipt --json $TX)"
    TX_STATUS="$(jq -r '.status' <<<"$RECEIPT")"
    [[ "$TX_STATUS" != "0x1" ]] && die "Failed to create ${SYMBOL} token in tx ${TX}."

	RWA_JOIN="$(jq -r ".logs[0].address" <<<"$RECEIPT")"
	debug "MCD_JOIN_${SYMBOL}_${LETTER}: ${RWA_JOIN}"
}

# urn it
[[ -z "$RWA_URN" ]] && {
    confirm_before_proceed "Deploy RWA_URN?"
    RWA_URN=$($FORGE_DEPLOY --verify RwaUrn2 --constructor-args "$MCD_VAT" "$MCD_JUG" "$RWA_JOIN" "$MCD_JOIN_DAI" "$DESTINATION_ADDRESS")
    debug "${SYMBOL}_${LETTER}_URN: ${RWA_URN}"
    $CAST_SEND "$RWA_URN" 'rely(address)' "$MCD_PAUSE_PROXY" &&
        $CAST_SEND "$RWA_URN" 'deny(address)' "$ETH_FROM"
}

# jar it
[[ -z "$RWA_JAR" ]] && {
    confirm_before_proceed "Deploy RWA_JAR?"
    RWA_JAR=$($FORGE_DEPLOY --verify RwaJar --constructor-args "$CHANGELOG")
}
debug "${SYMBOL}_${LETTER}_JAR: ${RWA_JAR}"

# print it
cat <<JSON
{
    "MIP21_LIQUIDATION_ORACLE": "${MIP21_LIQUIDATION_ORACLE}",
    "RWA_TOKEN_FAB": "${RWA_TOKEN_FAB}",
    "SYMBOL": "${SYMBOL}",
    "NAME": "${NAME}",
    "ILK": "${ILK}",
    "${SYMBOL}": "${RWA_TOKEN}",
    "MCD_JOIN_${SYMBOL}_${LETTER}": "${RWA_JOIN}",
    "${SYMBOL}_${LETTER}_URN": "${RWA_URN}",
    "${SYMBOL}_${LETTER}_JAR": "${RWA_JAR}",
    "${SYMBOL}_${LETTER}_OUTPUT_CONDUIT": "${DESTINATION_ADDRESS}"
}
JSON
