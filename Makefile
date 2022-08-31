# include .env file and export its env vars
# (-include to ignore error if it does not exist)-include .env
-include .env

update:; forge update
nodejs-deps:; yarn install
lint:; yarn run lint

# install solc version
# example to install other versions: `make solc 0_6_12`
SOLC_VERSION := 0_6_12
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_${SOLC_VERSION}

build:; forge build

estimate:; ./src/${ILK}/scripts/deploy.sh ${NETWORK} --estimate

deploy:; ./src/${ILK}/scripts/deploy.sh ${NETWORK}

# mainnet
deploy-mainnet:; ./src/${ILK}/scripts/deploy-mainnet.sh
# goerli
deploy-goerli:; ./src/${ILK}/scripts/deploy-goerli.sh
# goerli CES fork
deploy-ces-goerli:; ./src/${ILK}/scripts/deploy-ces-goerli.sh

test:; forge test --match-path src/${ILK}/contract/**.t.sol # --ffi # enable if you need the `ffi` cheat code on HEVM

create-onboarding:; ./scripts/create-onboarding.sh ${ILK_NUMBER} ${ILK_LETTER}