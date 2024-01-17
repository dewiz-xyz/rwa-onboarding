// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";

import {RwaSwapInputConduit2} from "rwa-toolkit/conduits/RwaSwapInputConduit2.sol";

contract RWA009_A_UrnInputConduitDeploymentScript is Script {
    ChainlogLike CHANGELOG;
    address MCD_PAUSE_PROXY;
    address MCD_DAI;
    address MCD_PSM_USDC_A;
    address USDC;
    address RWA009_A_URN;

    function run() external returns (Result memory) {
        CHANGELOG = ChainlogLike(vm.envAddress("CHANGELOG"));
        MCD_PAUSE_PROXY = CHANGELOG.getAddress("MCD_PAUSE_PROXY");
        MCD_DAI = CHANGELOG.getAddress("MCD_DAI");
        MCD_PSM_USDC_A = CHANGELOG.getAddress("MCD_PSM_USDC_A");
        USDC = CHANGELOG.getAddress("USDC");
        RWA009_A_URN = CHANGELOG.getAddress("RWA009_A_URN");

        vm.startBroadcast();

        RwaSwapInputConduit2 inputCUrn = new RwaSwapInputConduit2(MCD_DAI, USDC, MCD_PSM_USDC_A, RWA009_A_URN);
        inputCUrn.rely(MCD_PAUSE_PROXY);
        inputCUrn.deny(msg.sender);
        address RWA009_A_INPUT_CONDUIT = address(inputCUrn);
        console2.log("RWA009_A_INPUT_CONDUIT: %s", RWA009_A_INPUT_CONDUIT);

        vm.stopBroadcast();


        return Result({
            inputConduit: RWA009_A_INPUT_CONDUIT
        });
    }
}

struct Result {
    address inputConduit;
}

interface ChainlogLike {
    function getAddress(bytes32 what) external returns (address);
}
