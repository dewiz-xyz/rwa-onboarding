// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "forge-std/Script.sol";
import {SolidityTypeConversions as stc} from "../../shared/SolidityTypeConversions.sol";
import {JsonFormatter as jf} from "../../shared/JsonFormatter.sol";
import {Strings as s} from "../../shared/Strings.sol";

import {RwaTokenFactory} from "mip21-toolkit/tokens/RwaTokenFactory.sol";
import {RwaUrn2} from "mip21-toolkit/urns/RwaUrn2.sol";
import {RwaOutputConduit3} from "mip21-toolkit/conduits/RwaOutputConduit3.sol";
import {RwaInputConduit3} from "mip21-toolkit/conduits/RwaInputConduit3.sol";
import {RwaJar} from "mip21-toolkit/jars/RwaJar.sol";

contract RWA007Deployment is Script {
    string NAME;
    string SYMBOL;
    string LETTER;
    string SYMBOL_LETTER;
    bytes32 immutable ILK;

    Changelog CHANGELOG;
    address immutable MCD_PAUSE_PROXY;
    address immutable MCD_DAI;
    address immutable MCD_VAT;
    address immutable MCD_JUG;
    address immutable MCD_JOIN_DAI;
    address immutable MCD_PSM_USDC_A;
    RwaTokenFactory immutable RWA_TOKEN_FAB;
    JoinFab immutable JOIN_FAB;

    constructor() public {
        NAME = vm.envString("NAME");
        SYMBOL = vm.envString("SYMBOL");
        LETTER = vm.envString("LETTER");
        SYMBOL_LETTER = s.concat(SYMBOL, LETTER, "_");
        ILK = stc.toBytes32(s.concat(SYMBOL, LETTER, "-"));

        CHANGELOG = Changelog(vm.envAddress("CHANGELOG"));
        MCD_PAUSE_PROXY = CHANGELOG.getAddress("MCD_PAUSE_PROXY");
        MCD_DAI = CHANGELOG.getAddress("MCD_DAI");
        MCD_VAT = CHANGELOG.getAddress("MCD_VAT");
        MCD_JUG = CHANGELOG.getAddress("MCD_JUG");
        MCD_JOIN_DAI = CHANGELOG.getAddress("MCD_JOIN_DAI");
        MCD_PSM_USDC_A = CHANGELOG.getAddress("MCD_PSM_USDC_A");
        RWA_TOKEN_FAB = RwaTokenFactory(CHANGELOG.getAddress("RWA_TOKEN_FAB"));
        JOIN_FAB = JoinFab(CHANGELOG.getAddress("JOIN_FAB"));
    }

    function run() external {
        vm.startBroadcast();

        // tokenize it
        address RWA_TOKEN = envAddressOptional("RWA_TOKEN");
        if (RWA_TOKEN == address(0)) {
            RWA_TOKEN = address(RWA_TOKEN_FAB.createRwaToken(NAME, SYMBOL, MCD_PAUSE_PROXY));
        }

        // join it
        address RWA_JOIN = envAddressOptional("RWA_JOIN");
        if (RWA_JOIN == address(0)) {
            RWA_JOIN = JOIN_FAB.newAuthGemJoin(MCD_PAUSE_PROXY, ILK, RWA_TOKEN);
        }

        // route it
        address RWA_OUTPUT_CONDUIT = envAddressOptional("RWA_OUTPUT_CONDUIT");
        if (RWA_OUTPUT_CONDUIT == address(0)) {
            RwaOutputConduit3 outputC = new RwaOutputConduit3(MCD_PSM_USDC_A);
            outputC.rely(MCD_PAUSE_PROXY);

            RWA_OUTPUT_CONDUIT = address(outputC);
        }

        // urn it
        address RWA_URN = envAddressOptional("RWA_URN");
        if (RWA_URN == address(0)) {
            RwaUrn2 urn = new RwaUrn2(MCD_VAT, MCD_JUG, RWA_JOIN, MCD_JOIN_DAI, RWA_OUTPUT_CONDUIT);
            urn.rely(MCD_PAUSE_PROXY);
            urn.deny(msg.sender);

            RWA_URN = address(urn);

            // Set _quitTo address to the URN and deny deplyer
            RwaOutputConduit3(RWA_OUTPUT_CONDUIT).file("quitTo", RWA_URN);
            RwaOutputConduit3(RWA_OUTPUT_CONDUIT).deny(msg.sender);
        }

        // jar it
        address RWA_JAR = envAddressOptional("RWA_JAR");
        if (RWA_JAR == address(0)) {
            RWA_JAR = address(new RwaJar(address(CHANGELOG)));
        }

        // route it JAR
        address RWA_INPUT_CONDUIT_JAR = envAddressOptional("RWA_INPUT_CONDUIT_JAR");
        if (RWA_INPUT_CONDUIT_JAR == address(0)) {
            RwaInputConduit3 inputCJar = new RwaInputConduit3(MCD_PSM_USDC_A, RWA_JAR);
            inputCJar.rely(MCD_PAUSE_PROXY);
            inputCJar.deny(msg.sender);

            RWA_INPUT_CONDUIT_JAR = address(inputCJar);
        }

        // route it URN
        address RWA_INPUT_CONDUIT_URN = envAddressOptional("RWA_INPUT_CONDUIT_URN");
        if (RWA_INPUT_CONDUIT_URN == address(0)) {
            RwaInputConduit3 inputCUrn = new RwaInputConduit3(MCD_PSM_USDC_A, RWA_URN);
            inputCUrn.rely(MCD_PAUSE_PROXY);
            inputCUrn.deny(msg.sender);

            RWA_INPUT_CONDUIT_URN = address(inputCUrn);
        }

        vm.stopBroadcast();

        logJSONTuple("SYMBOL", SYMBOL);
        logJSONTuple("NAME", NAME);
        logJSONTuple("ILK", ILK);
        logJSONTuple(SYMBOL, RWA_TOKEN);
        logJSONTuple(s.concat("MCD_JOIN_", SYMBOL_LETTER), RWA_JOIN);
        logJSONTuple(s.concat(SYMBOL_LETTER, "_URN"), RWA_URN);
        logJSONTuple(s.concat(SYMBOL_LETTER, "_JAR"), RWA_JAR);
        logJSONTuple(s.concat(SYMBOL_LETTER, "_OUTPUT_CONDUIT"), RWA_OUTPUT_CONDUIT);
        logJSONTuple(s.concat(SYMBOL_LETTER, "_INPUT_CONDUIT_URN"), RWA_INPUT_CONDUIT_URN);
        logJSONTuple(s.concat(SYMBOL_LETTER, "_INPUT_CONDUIT_JAR"), RWA_INPUT_CONDUIT_JAR);
    }

    // TODO: maybe move the functions below to an abtract contract...

    function envAddressOptional(string memory name) internal returns (address) {
        try vm.envAddress(name) {
            return vm.envAddress(name);
        } catch {
            return address(0);
        }
    }

    function logJSONTuple(string memory key, string memory value) internal view {
        console2.log(jf.toPair(key, value));
    }

    function logJSONTuple(string memory key, address value) internal view {
        console2.log(jf.toPair(key, value));
    }

    function logJSONTuple(string memory key, bytes32 value) internal view {
        console2.log(jf.toPair(key, value));
    }
}

interface Changelog {
    function getAddress(bytes32 what) external returns (address);
}

interface JoinFab {
    function newAuthGemJoin(
        address owner,
        bytes32 ilk,
        address gem
    ) external returns (address);
}
