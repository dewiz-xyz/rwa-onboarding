// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "forge-std/Script.sol";
import "../contract/Import.sol";

interface Changelog {
    function getAddress(bytes32 what) external returns (address);
}

interface JoinFab {
    function newAuthGemJoin(address owner, bytes32 ilk, address gem) external returns (address);
}

contract RWA007Deployment is Script {
    address immutable MCD_PAUSE_PROXY;
    address immutable MCD_DAI;
    address immutable MCD_VAT;
    address immutable MCD_JUG;
    address immutable MCD_JOIN_DAI;
    address immutable MCD_PSM_USDC_A;
    RwaTokenFactory immutable RWA_TOKEN_FAB;
    JoinFab immutable JOIN_FAB;
    Changelog CHANGELOG;

    string NAME;
    string SYMBOL;
    string LETTER;

    bytes32 immutable ILK;

    event Result(address RwaToken);
    constructor() public {
        CHANGELOG                 = Changelog(getEnvAddressRequired("CHANGELOG"));
        MCD_PAUSE_PROXY           = CHANGELOG.getAddress(bytes32("MCD_PAUSE_PROXY"));
        MCD_DAI                   = CHANGELOG.getAddress(bytes32("MCD_DAI"));
        MCD_VAT                   = CHANGELOG.getAddress(bytes32("MCD_VAT"));
        MCD_JUG                   = CHANGELOG.getAddress(bytes32("MCD_JUG"));
        MCD_JOIN_DAI              = CHANGELOG.getAddress(bytes32("MCD_JOIN_DAI"));
        MCD_PSM_USDC_A            = CHANGELOG.getAddress(bytes32("MCD_PSM_USDC_A"));
        RWA_TOKEN_FAB             = RwaTokenFactory(CHANGELOG.getAddress(bytes32("RWA_TOKEN_FAB")));
        JOIN_FAB                  = JoinFab(CHANGELOG.getAddress(bytes32("JOIN_FAB")));

        NAME                      = getEnvStringRequired("NAME");
        SYMBOL                    = getEnvStringRequired("SYMBOL");
        LETTER                    = getEnvStringRequired("LETTER");

        ILK                       = bytesToBytes32((abi.encodePacked(SYMBOL, string("-"), LETTER)));
    }

    function run() external {
        vm.startBroadcast();

        // tokenize it
        address RWA_TOKEN = getEnvAddress("RWA_TOKEN");
        if (RWA_TOKEN == address(0)) {
            RWA_TOKEN = address(RWA_TOKEN_FAB.createRwaToken(NAME, SYMBOL, MCD_PAUSE_PROXY));
        }
        logDeployment("RWA_TOKEN", RWA_TOKEN);

        // join it
        address RWA_JOIN = getEnvAddress("RWA_JOIN");
        if (RWA_JOIN == address(0)) {
            RWA_JOIN =  JOIN_FAB.newAuthGemJoin(MCD_PAUSE_PROXY, ILK, RWA_TOKEN);
        }
        logDeployment("RWA_JOIN", RWA_JOIN);

        // route it
        address RWA_OUTPUT_CONDUIT = getEnvAddress("RWA_OUTPUT_CONDUIT");
        if (RWA_OUTPUT_CONDUIT == address(0)) {
            RwaOutputConduit3 outputC =  new RwaOutputConduit3(MCD_PSM_USDC_A, address(0)); // TODO remove quiteTo from constructor, better to set it in the spell
            outputC.rely(MCD_PAUSE_PROXY);

            RWA_OUTPUT_CONDUIT = address(outputC);
        }
        logDeployment("RWA_OUTPUT_CONDUIT", RWA_OUTPUT_CONDUIT);
        
        // urn it
        address RWA_URN = getEnvAddress("RWA_URN");
        if (RWA_URN == address(0)) {
            RwaUrn2 urn = new RwaUrn2(MCD_VAT, MCD_JUG, RWA_JOIN, MCD_JOIN_DAI, RWA_OUTPUT_CONDUIT);
            urn.rely(MCD_PAUSE_PROXY);
            urn.deny(msg.sender);

            RWA_URN = address(urn);

            // Set _quitTo address to the URN and deny deplyer
            RwaOutputConduit3(RWA_OUTPUT_CONDUIT).file("quitTo", RWA_URN);
            RwaOutputConduit3(RWA_OUTPUT_CONDUIT).deny(msg.sender);
        }
        logDeployment("RWA_URN", RWA_URN);

        // jar it
        address RWA_JAR = getEnvAddress("RWA_JAR");
        if (RWA_JAR == address(0)) {
            RWA_JAR = address(new RwaJar(address(CHANGELOG)));
        }
        logDeployment("RWA_JAR", RWA_JAR);

        // route it JAR
        address RWA_INPUT_CONDUIT_JAR = getEnvAddress("RWA_INPUT_CONDUIT_JAR");
        if (RWA_INPUT_CONDUIT_JAR == address(0)) {
            RwaInputConduit3 inputCJar = new RwaInputConduit3(MCD_PSM_USDC_A, RWA_JAR, address(0)); // TODO remove quiteTo from constructor, better to set it in the spell
            inputCJar.rely(MCD_PAUSE_PROXY);
            inputCJar.deny(msg.sender);

            RWA_INPUT_CONDUIT_JAR = address(inputCJar);
        }
        logDeployment("RWA_INPUT_CONDUIT_JAR", RWA_INPUT_CONDUIT_JAR);

        // route it URN
        address RWA_INPUT_CONDUIT_URN = getEnvAddress("RWA_INPUT_CONDUIT_URN");
        if (RWA_INPUT_CONDUIT_URN == address(0)) {
            RwaInputConduit3 inputCUrn = new RwaInputConduit3(MCD_PSM_USDC_A, RWA_URN, address(0)); // TODO remove quiteTo from constructor, better to set it in the spell
            inputCUrn.rely(MCD_PAUSE_PROXY);
            inputCUrn.deny(msg.sender);

            RWA_INPUT_CONDUIT_URN = address(inputCUrn);
        }
        logDeployment("RWA_INPUT_CONDUIT_URN", RWA_INPUT_CONDUIT_URN);
        
        vm.stopBroadcast();

    }

    function getEnvAddressRequired(string memory name) internal returns (address) {
        try vm.envAddress(name) {
            return vm.envAddress(name);
        } catch {
            revert(string(abi.encodePacked("ENV/", name, "-not-defined")));
        }
    }

    function getEnvStringRequired(string memory name) internal returns (string memory) {
        try vm.envString(name) {
            return vm.envString(name);
        } catch {
            revert(string(abi.encodePacked("ENV/", name, "-not-defined")));
        }
    }

    function getEnvAddress(string memory name) internal returns (address) {
        try vm.envAddress(name) {
            return vm.envAddress(name);
        } catch {
            return address(0);
        }
    }

    function bytesToBytes32(bytes memory data) internal pure returns (bytes32 result) {
        if (data.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(data, 32))
        }
    }

    function logDeployment(string memory name, address addr) internal {
        console2.log(vm.toString(abi.encodePacked('["', name, '","', vm.toString(addr), '"]')));

    }
}