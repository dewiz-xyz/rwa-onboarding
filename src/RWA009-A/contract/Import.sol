pragma solidity 0.6.12;

// Listing all contracts used by the deploy scripts to force dapp.tools to build them
import "rwa-toolkit/tokens/RwaTokenFactory.sol";
import "rwa-toolkit/tokens/RwaToken.sol";
import "rwa-toolkit/urns/RwaUrn2.sol";
import "rwa-toolkit/conduits/RwaOutputConduit2.sol";
import "rwa-toolkit/jars/RwaJar.sol";
import "rwa-toolkit/oracles/RwaLiquidationOracle.sol";
import "dss-gem-joins/join-auth.sol";
import "forward-proxy/ForwardProxy.sol";
