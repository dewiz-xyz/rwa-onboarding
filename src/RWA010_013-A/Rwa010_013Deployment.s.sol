// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Script.sol";
import {SolidityTypeConversions as stc} from "../shared/SolidityTypeConversions.sol";
import {JsonFormatter as jf} from "../shared/JsonFormatter.sol";
import {Strings as s} from "../shared/Strings.sol";

import {RwaTokenFactory} from "mip21-toolkit/tokens/RwaTokenFactory.sol";
import {RwaUrn} from "mip21-toolkit/urns/RwaUrn.sol";
import {GemJoinAbstract} from "dss-interfaces/dss/GemJoinAbstract.sol";

contract Rwa010_013Deployment is Script {
    Changelog CHANGELOG;
    address immutable MCD_PAUSE_PROXY;
    address immutable MCD_DAI;
    address immutable MCD_VAT;
    address immutable MCD_JUG;
    address immutable MCD_JOIN_DAI;
    RwaTokenFactory immutable RWA_TOKEN_FAB;
    JoinFab immutable JOIN_FAB;

    string constant RWA010 = "RWA010";
    string constant RWA011 = "RWA011";
    string constant RWA012 = "RWA012";
    string constant RWA013 = "RWA013";

    mapping(string => string) names; // names[symbol]
    mapping(string => bytes32) ilks; // ilks[symbol]
    mapping(string => string) symbolLetters; // symbolLetters[symbol]

    mapping(uint256 => mapping(string => address)) tinlakeManagers; // tinlakeManagers[chainId][symbol]

    uint256 constant CHAIN_ID_MAINNET = 1;
    uint256 constant CHAIN_ID_GOERLI = 5;

    struct DeployDependencies {
        string name;
        string symbol;
        string symbolLetter;
        bytes32 ilk;
        address mgr;
    }

    constructor() public {
        CHANGELOG = Changelog(vm.envAddress("CHANGELOG"));
        MCD_PAUSE_PROXY = CHANGELOG.getAddress("MCD_PAUSE_PROXY");
        MCD_DAI = CHANGELOG.getAddress("MCD_DAI");
        MCD_VAT = CHANGELOG.getAddress("MCD_VAT");
        MCD_JUG = CHANGELOG.getAddress("MCD_JUG");
        MCD_JOIN_DAI = CHANGELOG.getAddress("MCD_JOIN_DAI");
        RWA_TOKEN_FAB = RwaTokenFactory(CHANGELOG.getAddress("RWA_TOKEN_FAB"));
        JOIN_FAB = JoinFab(CHANGELOG.getAddress("JOIN_FAB"));

        names[RWA010] = "RWA-010";
        ilks[RWA010] = stc.toBytes32(s.concat(RWA010, "A", "-"));
        symbolLetters[RWA010] = s.concat(RWA010, "A", "_");

        names[RWA011] = "RWA-011";
        ilks[RWA011] = stc.toBytes32(s.concat(RWA011, "A", "-"));
        symbolLetters[RWA011] = s.concat(RWA011, "A", "_");

        names[RWA012] = "RWA-012";
        ilks[RWA012] = stc.toBytes32(s.concat(RWA012, "A", "-"));
        symbolLetters[RWA012] = s.concat(RWA012, "A", "_");

        names[RWA013] = "RWA-013";
        ilks[RWA013] = stc.toBytes32(s.concat(RWA013, "A", "-"));
        symbolLetters[RWA013] = s.concat(RWA013, "A", "_");

        tinlakeManagers[CHAIN_ID_MAINNET][RWA010] = 0x1F5C294EF3Ff2d2Da30ea9EDAd490C28096C91dF;
        tinlakeManagers[CHAIN_ID_MAINNET][RWA011] = 0x8e74e529049bB135CF72276C1845f5bD779749b0;
        tinlakeManagers[CHAIN_ID_MAINNET][RWA012] = 0x795b917eBe0a812D406ae0f99D71caf36C307e21;
        tinlakeManagers[CHAIN_ID_MAINNET][RWA013] = 0x615984F33604011Fcd76E9b89803Be3816276E61;

        tinlakeManagers[CHAIN_ID_GOERLI][RWA010] = 0x8828D2B96fa09864851244a8a2434C5A9a7B7AbD;
        tinlakeManagers[CHAIN_ID_GOERLI][RWA011] = 0xcBd44c9Ec0D2b9c466887e700eD88D302281E098;
        tinlakeManagers[CHAIN_ID_GOERLI][RWA012] = 0xaef64c80712d5959f240BE1339aa639CDFA858Ff;
        tinlakeManagers[CHAIN_ID_GOERLI][RWA013] = 0xc5A1418aC32B5f978460f1211B76B5D44e69B530;
    }

    function run() external {
        uint256 _chainid;
        assembly {
            _chainid := chainid()
        }

        vm.startBroadcast();

        deployComponents(
            DeployDependencies({
                name: names[RWA010],
                symbol: RWA010,
                symbolLetter: symbolLetters[RWA010],
                ilk: ilks[RWA010],
                mgr: tinlakeManagers[_chainid][RWA010]
            })
        );

        deployComponents(
            DeployDependencies({
                name: names[RWA011],
                symbol: RWA011,
                symbolLetter: symbolLetters[RWA011],
                ilk: ilks[RWA011],
                mgr: tinlakeManagers[_chainid][RWA011]
            })
        );

        deployComponents(
            DeployDependencies({
                name: names[RWA012],
                symbol: RWA012,
                symbolLetter: symbolLetters[RWA012],
                ilk: ilks[RWA012],
                mgr: tinlakeManagers[_chainid][RWA012]
            })
        );

        deployComponents(
            DeployDependencies({
                name: names[RWA013],
                symbol: RWA013,
                symbolLetter: symbolLetters[RWA013],
                ilk: ilks[RWA013],
                mgr: tinlakeManagers[_chainid][RWA013]
            })
        );

        vm.stopBroadcast();
    }

    function deployComponents(DeployDependencies memory deps) internal {
        address rwaToken = address(RWA_TOKEN_FAB.createRwaToken(deps.name, deps.symbol, MCD_PAUSE_PROXY));

        address rwaJoin = JOIN_FAB.newAuthGemJoin(MCD_PAUSE_PROXY, deps.ilk, rwaToken);

        address rwaOutputConduit = deps.mgr;
        address rwaInputConduit = deps.mgr;
        address rwaOperator = deps.mgr;

        address rwaUrn = address(new RwaUrn(MCD_VAT, MCD_JUG, rwaJoin, MCD_JOIN_DAI, rwaOutputConduit));
        // RwaUrn(rwaUrn).hope(rwaOperator);
        RwaUrn(rwaUrn).rely(MCD_PAUSE_PROXY);
        RwaUrn(rwaUrn).deny(msg.sender);

        logJSONTuple(deps.symbol, rwaToken);
        logJSONTuple(s.concat("MCD_JOIN_", deps.symbolLetter), rwaJoin);
        logJSONTuple(s.concat(deps.symbolLetter, "_URN"), rwaUrn);
        logJSONTuple(s.concat(deps.symbolLetter, "_OUTPUT_CONDUIT"), rwaOutputConduit);
        logJSONTuple(s.concat(deps.symbolLetter, "_INPUT_CONDUIT"), rwaInputConduit);
        logJSONTuple(s.concat(deps.symbolLetter, "_OPERATOR"), rwaOperator);
    }

    function envAddressOptional(string memory name) internal view returns (address) {
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
