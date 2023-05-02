# [RWA008] OFH/MIP21 Token CES Domain Team Assessment

## General Information

The previous assessments of RWA006 and RWA007 were used as a general template for this assessment as many implementation details are the same for RWA008.

This assessment deviates from the standard smart contract technical assessment format because of the idiosyncratic nature of the RWA collateral type.

In summary, due to the simple and risk contained nature of the proposed system, and the fact that the majority of the components are already used in production **these smart contracts are considered low risk.**

- **Symbol:** RWA008
- **Token Name:** RWA-008
- **Ilk Registry name: RWA008-A: SG Forge OFH**
- **Relevant MIP information:**
  - [[Security Tokens Refinancing] MIP6 Application for OFH Tokens](https://forum.makerdao.com/t/security-tokens-refinancing-mip6-application-for-ofh-tokens/10605)
  - [MIP21: Real World Assets - Off-Chain Asset Backed Lender](https://forum.makerdao.com/t/mip21-real-world-assets-off-chain-asset-backed-lender/3917)
- **Total supply:** 1 WAD (1 \* 10 ^ 18)
- **Does the contract implement the ERC20 token standards?** Yes.
- **RWA institutional website:** [societegenerale.com](https://www.societegenerale.com/)
- **RWA project website:** [OFH press release](https://www.societegenerale.com/en/news/newsroom/societe-generale-issued-first-covered-bond-security-token-public-blockchain)
- **Github repository:**
  - [](https://github.com/clio-finance/socgen-ofh-onboarding)[https://github.com/clio-finance/socgen-ofh-onboarding](https://github.com/clio-finance/socgen-ofh-onboarding)
  - [](https://github.com/clio-finance/mip21-toolkit)[https://github.com/clio-finance/mip21-toolkit](https://github.com/clio-finance/mip21-toolkit)
- **Can use an existing MCD collateral type adapter?** Yes, this collateral uses the MIP21 [authed join and exit functions](https://github.com/makerdao/dss-gem-joins/blob/c2ba746fd45593136475aa5e308a57db87e7eb7f/src/join-auth.sol).

## Technical Information

- **Does the contract implement the ERC20 token standards?** Yes.
- **Compiler version:** `solidity:0.6.12`
- **Decimals:** 18.
- **Overflow checks:** No.
- **Overflow checks:** Yes.
- **Mitigation against allowance race-condition:** No.
- **Upgradeable contract patterns:** No.
- **Access control or restriction lists:** No.
- **Non-standard features or behaviors:** No.
- **Key addresses:**
  - The `auth` governance address for `RwaInputConduit`, `RwaLiquidationOracle` and `RwaUrn` contracts.
  - The `operator` address that is permitted to operate on the `RwaInputConduit` and `RwaUrn` contracts. This can be multiple addresses, however, each address must be approved by governance.
  - The `mate` address controlled by the security agent DIIS Group that is permitted to call `push()` on the `RwaInputConduit` and `RwaOutputConduit` to transfer Dai in and out of the conduits respectively, but does not have any privileges within the token contract itself.
- **Additional notes:**
  - While there are no overflow checks, no use of a SafeMath library, and no mitigation against the allowance race-condition, the idiosyncratic nature of the contract does not make them a requirement.

## Implementation Design Rationale

While the target collateral asset (the OFH tokens, representing covered bonds) for onboarding actually exists “on chain”, it cannot be easily integrated directly into the Maker Protocol due to a number of technical factors outlined in more detail in the sections below. Furthermore, because no freely accessible price data exists that can be pushed on chain for public consumption, it is difficult to construct a price Oracle for the OFH tokens. Additionally there are no on chain markets where these assets can be sold in the event of a liquidation, making liquidations an “off chain” event. Lastly, the OFH tokens have KYC requirements, which means that they cannot be freely traded on Ethereum.

Due to these facts, it was decided that the MIP21 implementation structure would be utilized to implement the vault, instead of trying to integrate the OFH token directly into the Maker Protocol as a “first class collateral” like ETH. However we are committed to work with SGF to iterate and improve the technical setup to automate the management of the collateral for potential future deals.

Since OFH tokens will not be onboarded directly into the Maker Protocol, SGF will instead transfer the OFH tokens to the `RwaUrn` contract, which can be verified by anyone (e.g. through Etherscan), such that it holds the OFH tokens while the Vault is active. This will improve the transparency of the state of Vault. SGF will covenant to maintain the registration in the OFH token internal balance, and failure to do so will be subject to a liquidation event. The registration and maintenance covenants are backstopped by the French law pledge agreement, whereby SGF pledges the OFH tokens to Maker (through DIIS Group). RWF and incubating LTS will elaborate on these risks in the Risk Assessment.

### Architecture

#### SocGen OFH Token

- Closed source. Has been thoroughly reviewed by the Collateral Engineering Services Core Unit under the supervision of the Protocol Engineering Core Unit.
- Does not conform to ERC20 standard, meaning it cannot be onboarded directly into the Maker Protocol.
- Lacks allowance mechanisms as well as race-conditions mitigation and a `transferFrom()` method.
- Indivisible (0 decimals).
- Would not function properly during Emergency Shutdown if onboarded directly into the Maker Protocol, due to the lack of conformity with the ERC20 standard.
- Complex token semantics and logic.
- Because of the bullet points above, the OFH token will not be onboarded directly into the Maker Protocol. Instead, a RWA-008 token will be utilized in the Maker Protocol to enable Dai generation, similarly to other MIP21-style vaults. As described above, in addition SGF will transfer OFH tokens to the RWAUrn which will hold the tokens while the Vault is active. The Pledge will further evidence Maker’s interest the OFH token.

#### MIP21 Contracts

MIP21 is the component that prevents the borrower from minting more Dai than the Debt Ceiling (`line`) and provides the ability for Maker Governance to trigger a liquidation. **MIP21 by itself does not ensure that enough collateral is present or that the legal agreements underpinning the relationship are sound.**

The core RWA architecture consists of the following contracts:

- RwaToken
- RwaUrn
- RwaConduit
- RwaLiquidationOracle

#### MIP21 Modifications

Minor modifications were made to the standard MIP21 technical implementation to meet the operational and legal requirements of the parties:

- The MKR balance requirement to transfer Dai in and out of the `RwaConduit` via `push()` was replaced with a simple whitelist. DIIS Group, the security agent of this agreement, will be the whitelisted actor to call this function. SocGen will also be whitelisted as a backup for technical reasons, but does not intend to use the function under normal use for legal reasons.
- Removed the need for Maker Governance to whitelist recipients (`to`) of “pushed” Dai in the `RwaOutputConduit`. This means that Maker Governance does not need to approve recipients of Dai generated from the vault in an executive spell, instead we leave this to the discretion of SocGen to decide freely where to route generated Dai.
- Modified the `exit` function to allow the operator of the `RwaUrn` (SocGen) to withdraw Dai deposited into `RwaUrn` to the `RwaOutputConduit`, e.g. in case excess Dai is deposited by accident. Previously this function could only be called during emergency shutdown. However, if SocGen by accident were to send more Dai than their outstanding debt, there is no easy way to recover the excess Dai. Even in the instance they pay back Dai to the `RwaUrn`, but decide they do not want to repay their loan yet, there is no way to transfer the Dai back from the `RwaUrn`, thus the only way to get Dai back would be to pay down the debt and generate new Dai. This change in the function makes the operation of the vault more flexible, and removes some potential operational issues, without introducing additional risks.

These changes are simple in nature and were done under the supervision of the Protocol Engineering Core Unit, and does not impose any added technical risk to the Maker Protocol itself.

#### RwaToken

[Source code](https://github.com/clio-finance/mip21-toolkit/blob/master/src/tokens/RwaToken.sol)

A standard implementation of the ERC20 token standard, with the `balanceOf(address)` of the deployer of the contract being set to `1` WAD at deployment. There are 18 decimals of precision.

There are three state changing functions, that are all available to the tokenholder, and are specific to the ERC20 token standard:

- `transfer(address dst, uint wad) external returns (bool);`
- `transferFrom(address src, address dst, uint wad) public returns (bool);`
- `approve(address usr, uint wad) external returns (bool);`

#### RwaUrn

[Source code](https://github.com/clio-finance/mip21-toolkit/blob/master/src/urns/RwaUrn2.sol)

The `RwaUrn` is unique to each MIP21 collateral type. Aside from the core DSS `wards`, `can`, `rely(address)`, `deny(address)`, `hope(address)`, and `nope(address)` functions, there are five functions:

- `file(bytes32,address)`
- `lock(uint256)`
- `free(uint256)`
- `draw(uint256)`
- `wipe(uint256)`
- `exit(uint256)`

The `file` function can only be called by governance (via the `auth` modifier).

The rest of the functions can only be called by those who have been given `operator` permission (`hoped` or `noped`) on the `RwaUrn` contract. And any Dai drawn by the `RwaUrn` can only be sent to the `RwaOutputConduit` address defined by governance when deploying the contract.

**Note:** The `exit` function was modified to allow the `operator` to withdraw Dai deposited in the `RwaUrn` to `RwaOutputConduit`, as explained in the modifcations section above.

#### RwaConduits

[Source code](https://github.com/clio-finance/mip21-toolkit/blob/master/src/conduits/RwaInputConduit2.sol)

The `RwaInputConduit` and `RwaOutputConduit` are two simple contracts aimed at handling Dai routing.

`RwaOutputConduit` has two main functions: `pick(address)` and `push()`.

- `pick(address)` can be called by actors who have been whitelisted using `hope(address)` to specify an Ethereum address that Dai should be routed to.
- The `push()` function holds transitory funds, that upon being called, are transferred to the `to` address set using the `pick(address)`.
  - **Note:** The `push()` function has been modified from standard MIP21, and can now only be called by actors who have been whitelisted using the `mate(address)`function - in this case DIIS Group and SG Forge. Furthermore, it is no longer necessary for Maker Governance to authorize the `to` address through `kiss`. In this implementation, we allow SGF to send the generated Dai to whichever address they desire, with no limitation from Maker Governance.

`RwaInputConduit` functions in a very similar manner, but lacks the `pick(address)` method as routing of Dai can only happen to `RwaUrn`.

#### RwaLiquidationOracle

[Source code](https://github.com/clio-finance/mip21-toolkit/blob/master/src/oracles/RwaLiquidationOracle.sol)

The `RwaLiquidationOracle` contract consists of six state-changing functions (besides the usual DSS `rely(address)`, `deny(address)`), all protected by the auth modifier and can only be called by governance:

- `file(bytes32,address)`
- `init(bytes32 ilk,bytes32 val,address doc,uint48 tau)`
- `bump(bytes32 ilk,uint256 val)`
- `tell(bytes32)`
- `cure(bytes32)`
- `cull(bytes32)`

There is one externally accessible view function called `good(bytes32)` that anyone can use to check the liquidation status of the position. This function does not change the contract state.

This is not a typical Maker oracle. It will only report on the liquidation status of the `RwaUrn`, and can only be acted upon by governance. To state it plainly, this oracle is not vulnerable to flash loan attacks or any manipulation aside from a governance attack.

`file` can be called by governance to change the `vow` address (used in `cull`).

`init` is the initialization function. It takes 4 parameters:

- `ilk`: name of the vault, in this case, RWA008.
- `val`: estimated value of the collateral token.
- `doc`: link to legal documents representing the underlying legal scheme.
- `tau`: minimum delay between the soft-liquidation and the hard-liquidation/write-off.

`bump` can be called by governance to increase or decrease the estimated value of the collateral.

`tell` can be called by governance to start a soft-liquidation.

`cure` can be called by governance after a soft-liquidation has been triggered to stop it.

`cull` can be called by governance to start a hard-liquidation/write-off. This will mark all the remaining debt of the vault as bad debt and impact the Surplus Buffer (`vow`).

#### Overview of technical setup and actors

The following diagrams showcase the high level technical setup and flow of funds (Maker smart contracts in Orange, SGF smart contracts in blue) and the involved actors (grey).

![](https://i.imgur.com/ElHayA1.png)

The figure above outlines the steps to borrow Dai.

**Step 1, 2, 3:** Societe Generale Forge (SGF) will in step 1, 2, and 3 call various functions in the OFH token to register RWAUrn as the holder of the OFH tokens. This registration represents, in the OFH token, a transfer to the RWAUrn contract. MakerDAO will have visibility on the registration in the OFH token.

**Step 4:** SGF will lock the RWA-008 token, which will be provided to them through an executive spell, into the `RwaUrn`. This step only needs to be done once, when SGF initially opens the Vault, and is purely a technical step to allow Dai generation in the Maker Protocol, the RWA-008 token does not represent the underlying collateral

**Step 5:** Once the RWA-008 token is locked, SGF can call `draw` to generate Dai, which is immediately sent to the `RwaOutputConduit` contract.

**Step 6:** Afterwards, SGF will call pick to choose a recipient address (in normal cases they themselves will be the recipient) of the drawn Dai.

**Step 7:** Finally, in order to finalize this transfer, DIIS group, the security agent, must call push to transfer the Dai to the recipient that SGF specified. The Dai tokens should now be in the custody of the recipient, in this case SGF.

![](https://i.imgur.com/fTvh29X.png)

The figure above outlines the steps to repay Dai.

**Step 1:** SGF transfers Dai to the `RwaInputConduit`.

**Step 2:** DIIS group verifies the transaction in the provided UI, and executes the function push to transfer Dai to the `RwaUrn`.

**Step 3:** SGF calls wipe to repay Dai debt in the Vault.

**Step 4, 5, 6:** SGF calls 3 functions on the OFH token to release the pledged tokens from the `RwaUrn`, and transferring them to SGF.

## Contract Risk Summary

**Risk Analysis Conclusion: Low technical risk**

The RWA code implementation resides within a sandbox-like environment, and any operation not related to locking, freeing, drawing, or wiping in the `RwaUrn` contract must be voted on by governance. The code itself is lightweight. This implementation uses simplified Oracle and Urn contracts to achieve the functionality required for this specific instance of RWA. Furthermore, MIP21 contract have been live in production for over a year, and are thus deemed low risk to reuse for this implementation.

Slight modifications were made to the standard MIP21 contract to support legal and operational requirements of the parties. These modifications were simple and do not present additional considerable complexity or liability to the contracts. To once again summarize the changes were:

- Make `push` a whitelisted function in RWA Conduits.
- Remove requirement for Maker Governance to whitelist recipient addresses of generated Dai
- Allow `operator`s of the `RwaUrn` to withdraw Dai sitting in the contract to the `RwaOutputConduit`.

These changes are implemented in MIP21, which is already a sandboxed environment that does not have direct authorizations on the MCD core contracts, and thus does not pose any direct technical risks to the Maker Protocol Core itself.

## Supporting Materials

### UX Improvements

To further facilitate the usability of RWA-008, CES has [built a UI](https://github.com/clio-finance/diis-group-ui) for the security agent to help facilitate the transfer of Dai in and out of the conduits. These can be reused for any similar future deal, to lower the barrier for third parties to interact with the Vaults.

The repository can be found here: [](https://github.com/clio-finance/diis-group-ui)[https://github.com/clio-finance/diis-group-ui](https://github.com/clio-finance/diis-group-ui)

This tool will be actively used by SocGen and DIIS Group to manage on-chain processes.

CES has also created a contract called [RwaUrnProxyView](https://github.com/clio-finance/socgen-ofh-onboarding/blob/master/src/RwaUrnProxyView.sol), that help calculate accrued stability fee for a future timestamp. These functions are out of scope of the assessment, as they are only user facing and do not pose any technical risks directly to the Maker Protocol.

Furthermore CES is deploying an onchain [RWA token factory](https://github.com/clio-finance/mip21-toolkit/blob/master/src/tokens/RwaTokenFactory.sol), to further automate the process of deploying MIP21-style loan agreements.

### Sūrya Description Report

#### Files Description Table

| File Name                | SHA-1 Hash                               |
| ------------------------ | ---------------------------------------- |
| RwaInputConduit2.sol     | 9bf23537fcb5cbce505aeaee14df3e273333e0f4 |
| RwaOutputConduit2.sol    | 3f7cbfa8b41239a3a74c8d95e50af936f565d7bd |
| RwaToken.sol             | 8d75732d93e0ad82a7bf3e0faf34550082291775 |
| RwaUrn2.sol              | ce511f510a5d456cf686a9f64a5b46a064043c31 |
| RwaLiquidationOracle.sol | 88c2b4fac899d39af0198c1fb4776171e4249c19 |

#### Contracts Description Table

```markdown
|         Contract         |       Type        |     Bases      |                |               |
| :----------------------: | :---------------: | :------------: | :------------: | :-----------: |
|            └             | **Function Name** | **Visibility** | **Mutability** | **Modifiers** |
|                          |                   |                |                |               |
|   **RwaInputConduit2**   |  Implementation   |                |                |               |
|            └             |   <Constructor>   |   Public ❗️   |       🛑       |     NO❗️     |
|            └             |       rely        |  External ❗️  |       🛑       |     auth      |
|            └             |       deny        |  External ❗️  |       🛑       |     auth      |
|            └             |       mate        |  External ❗️  |       🛑       |     auth      |
|            └             |       hate        |  External ❗️  |       🛑       |     auth      |
|            └             |       push        |  External ❗️  |       🛑       |     NO❗️     |
|                          |                   |                |                |               |
|  **RwaOutputConduit2**   |  Implementation   |                |                |               |
|            └             |   <Constructor>   |   Public ❗️   |       🛑       |     NO❗️     |
|            └             |       rely        |  External ❗️  |       🛑       |     auth      |
|            └             |       deny        |  External ❗️  |       🛑       |     auth      |
|            └             |       mate        |  External ❗️  |       🛑       |     auth      |
|            └             |       hate        |  External ❗️  |       🛑       |     auth      |
|            └             |       hope        |  External ❗️  |       🛑       |     auth      |
|            └             |       nope        |  External ❗️  |       🛑       |     auth      |
|            └             |       pick        |   Public ❗️   |       🛑       |     NO❗️     |
|            └             |       push        |  External ❗️  |       🛑       |     NO❗️     |
|                          |                   |                |                |               |
|       **RwaToken**       |  Implementation   |                |                |               |
|            └             |        add        |  Internal 🔒   |                |               |
|            └             |        sub        |  Internal 🔒   |                |               |
|            └             |   <Constructor>   |   Public ❗️   |       🛑       |     NO❗️     |
|            └             |     transfer      |  External ❗️  |       🛑       |     NO❗️     |
|            └             |   transferFrom    |   Public ❗️   |       🛑       |     NO❗️     |
|            └             |      approve      |  External ❗️  |       🛑       |     NO❗️     |
|                          |                   |                |                |               |
|       **RwaUrn2**        |  Implementation   |                |                |               |
|            └             |   <Constructor>   |   Public ❗️   |       🛑       |     NO❗️     |
|            └             |       rely        |  External ❗️  |       🛑       |     auth      |
|            └             |       deny        |  External ❗️  |       🛑       |     auth      |
|            └             |       hope        |  External ❗️  |       🛑       |     auth      |
|            └             |       nope        |  External ❗️  |       🛑       |     auth      |
|            └             |       file        |  External ❗️  |       🛑       |     auth      |
|            └             |       lock        |  External ❗️  |       🛑       |   operator    |
|            └             |       free        |  External ❗️  |       🛑       |   operator    |
|            └             |       draw        |  External ❗️  |       🛑       |   operator    |
|            └             |       wipe        |  External ❗️  |       🛑       |     NO❗️     |
|            └             |       quit        |  External ❗️  |       🛑       |     NO❗️     |
|            └             |        add        |  Internal 🔒   |                |               |
|            └             |        sub        |  Internal 🔒   |                |               |
|            └             |        mul        |  Internal 🔒   |                |               |
|            └             |       divup       |  Internal 🔒   |                |               |
|            └             |        rad        |  Internal 🔒   |                |               |
|                          |                   |                |                |               |
| **RwaLiquidationOracle** |  Implementation   |                |                |               |
|            └             |       rely        |  External ❗️  |       🛑       |     auth      |
|            └             |       deny        |  External ❗️  |       🛑       |     auth      |
|            └             |        add        |  Internal 🔒   |                |               |
|            └             |        mul        |  Internal 🔒   |                |               |
|            └             |   <Constructor>   |   Public ❗️   |       🛑       |     NO❗️     |
|            └             |       file        |  External ❗️  |       🛑       |     auth      |
|            └             |       init        |  External ❗️  |       🛑       |     auth      |
|            └             |       bump        |  External ❗️  |       🛑       |     auth      |
|            └             |       tell        |  External ❗️  |       🛑       |     auth      |
|            └             |       cure        |  External ❗️  |       🛑       |     auth      |
|            └             |       cull        |  External ❗️  |       🛑       |     auth      |
|            └             |       good        |  External ❗️  |                |     NO❗️     |
```

#### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑   | Function can modify state |
|   💵   | Function is payable       |

#### Contract Inheritance Graph

The smart contracts do not inherit other smart contracts.
![](https://i.imgur.com/axHkUDs.png)

#### Contract Call Graph

![](https://i.imgur.com/ReaNMrI.png)
