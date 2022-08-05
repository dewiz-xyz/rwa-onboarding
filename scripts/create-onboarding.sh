#!/bin/bash
set -eo pipefail

log() {
  echo -e "$@" >&2
}

GREEN='\033[0;32m' # Green
NC='\033[0m'   

logSuccess() {
  printf '%b\n' "${GREEN}${*}${NC}" >&2
}

createOnboarding() {
    local RWA_NUMBER=$1
    local ILK_LETTER=$2

    if [ -z "$RWA_NUMBER" ]; then
        read -p "Enter RWA number: " RWA_NUMBER
    fi

    if ! [[ "$RWA_NUMBER" =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then 
        log "Inputs must be a numbers" 
        exit 0 
    fi
    
    if [[ ${#RWA_NUMBER} < 3 ]]; then
      RWA_NUMBER="0$RWA_NUMBER"
    fi

    if [ -z "$ILK_LETTER" ]; then
        ILK_LETTER="A"
    fi

    if ! [[ "$ILK_LETTER" =~ [A-Z] ]]; then 
      log "ILK_LETTER: Inputs must be a one letter" 
      exit 0 
    fi

    local TOKEN_NAME="RWA-$RWA_NUMBER"
    local TOKEN_SYMBOL="RWA$RWA_NUMBER"
    local ILK="$TOKEN_SYMBOL-$ILK_LETTER"
    local TEMPLATE_DIR="${BASH_SOURCE%/*}/../template"
    local ONBOARDING_DIR="${BASH_SOURCE%/*}/../src/$ILK"

    # Check if we already have onboading for that ILK 
    if [ -d "$ONBOARDING_DIR" ]; then
      log "Onboarding for ILK: $ILK already exist"
      exit 0
    fi

    # Create onboarding in src by cp the template dir
    cp -R $TEMPLATE_DIR $ONBOARDING_DIR
        
    # Rename TOKEN_SYMBOL, TOKEN_NAME and ILK_LETTER in deployment script and README
    sed -i "" -e "s/\${{TOKEN_NAME}}/$TOKEN_NAME/g" "$ONBOARDING_DIR/scripts/deploy-goerli.sh"
    sed -i "" -e "s/\${{TOKEN_SYMBOL}}/$TOKEN_SYMBOL/g" "$ONBOARDING_DIR/scripts/deploy-goerli.sh"
    sed -i "" -e "s/\${{ILK_LETTER}}/$ILK_LETTER/g" "$ONBOARDING_DIR/scripts/deploy-goerli.sh"

    sed -i "" -e "s/\${{TOKEN_NAME}}/$TOKEN_NAME/g" "$ONBOARDING_DIR/scripts/deploy-mainnet.sh"
    sed -i "" -e "s/\${{TOKEN_SYMBOL}}/$TOKEN_SYMBOL/g" "$ONBOARDING_DIR/scripts/deploy-mainnet.sh"
    sed -i "" -e "s/\${{ILK_LETTER}}/$ILK_LETTER/g" "$ONBOARDING_DIR/scripts/deploy-mainnet.sh"

    sed -i "" -e "s/\${{TOKEN_NAME}}/$TOKEN_NAME/g" "$ONBOARDING_DIR/scripts/deploy-ces-goerli.sh"
    sed -i "" -e "s/\${{TOKEN_SYMBOL}}/$TOKEN_SYMBOL/g" "$ONBOARDING_DIR/scripts/deploy-ces-goerli.sh"
    sed -i "" -e "s/\${{ILK_LETTER}}/$ILK_LETTER/g" "$ONBOARDING_DIR/scripts/deploy-ces-goerli.sh"

    sed -i "" -e "s/\${{ILK}}/$ILK/g" "$ONBOARDING_DIR/README.md"

    logSuccess "Onboarding for $ILK created!"
}


usage() {
  cat <<MSG
create-onboarding.sh <RWA_NUMBER> <ILK_LETTER>(optional, default "A")

Examples:
    # Create onboarding with default ilk letter (A) 
    create-onboarding.sh 010

    # Create onboarding with ilk letter C 
    create-onboarding.sh 010 C
MSG
}

if [ "$0" = "$BASH_SOURCE" ]; then
  [ "$1" = "-h" -o "$1" = "--help" ] && {
    echo -e "\n$(usage)\n"
    exit 0
  }

  createOnboarding "$@"
fi