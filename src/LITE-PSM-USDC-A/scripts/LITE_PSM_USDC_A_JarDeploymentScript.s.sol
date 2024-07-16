// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";

import {RwaSwapInputConduit2} from "rwa-toolkit/conduits/RwaSwapInputConduit2.sol";
import {RwaJar} from "rwa-toolkit/jars/RwaJar.sol";

contract LITE_PSM_USDC_A_JarDeploymentScript is Script {
    ChainlogLike CHANGELOG;
    address MCD_PAUSE_PROXY;
    address MCD_DAI;
    address MCD_LITE_PSM_USDC_A;
    address USDC;

    function run() external returns (Result memory) {
        CHANGELOG = ChainlogLike(vm.envAddress("CHANGELOG"));
        MCD_PAUSE_PROXY = CHANGELOG.getAddress("MCD_PAUSE_PROXY");
        MCD_DAI = CHANGELOG.getAddress("MCD_DAI");
        MCD_LITE_PSM_USDC_A = vm.envAddress("MCD_LITE_PSM_USDC_A");
        USDC = CHANGELOG.getAddress("USDC");

        vm.startBroadcast();

        address RWA_JAR = address(new RwaJar(address(CHANGELOG)));
        console2.log("RWA_JAR: %s", RWA_JAR);


        RwaSwapInputConduit2 inputCJar = new RwaSwapInputConduit2(MCD_DAI, USDC, MCD_LITE_PSM_USDC_A, RWA_JAR);
        inputCJar.rely(MCD_PAUSE_PROXY);
        inputCJar.deny(msg.sender);
        address RWA_INPUT_CONDUIT_JAR = address(inputCJar);
        console2.log("RWA_INPUT_CONDUIT_JAR: %s", RWA_INPUT_CONDUIT_JAR);

        vm.stopBroadcast();


        return Result({
            jar: RWA_JAR,
            inputConduitJar: RWA_INPUT_CONDUIT_JAR
        });
    }
}

struct Result {
    address jar;
    address inputConduitJar;
}

interface ChainlogLike {
    function getAddress(bytes32 what) external returns (address);
}
