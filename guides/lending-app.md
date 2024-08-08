# Build an application that leverages GLIF for earning rewards on Filecoin tokens

**NOTE** GLIF V2 is scheduled for Filecoin Mainnet August 21, 2024. If you are looking for the V1 -> V2 migration guide, see [here]().

## Basic concepts

### wFIL (Wrapped FIL)

Wrapped FIL is an ERC20 token that GLIF uses internally within the protocol. WFIL has extra functionality that makes it easier and safer to work with inside a DeFi project.

All methods on GLIF, whether it's for adding OR removing liquidity, can both accept WFIL tokens and native FIL tokens. You can find more information on these different methods later on in this guide.

### iFIL

When building an application on GLIF to earn rewards on FIL, it's important to understand the role of iFIL - an ERC20 token that Liquidity Providers (LPs) hold to earn rewards.

Whenever a LP adds liquidity to GLIF, they receive new iFIL tokens in return. Whenever an LP removes liquidity from GLIF, they must burn iFIL tokens to receive the underlying asset back.

iFIL tokens increase in price over time - iFIL is NOT a rebasing token that is pegged 1:1 with Filecoin.

You can read more about iFIL [here](https://docs.glif.io/for-liquidity-providers/glif-reward-mechanism-ifil).

### Deposit vs Mint

There are two ways to provide liquidity to GLIF - via `deposit` or `mint`

- Deposit -> specify an amount of FIL (or wFIL) to provide in liquidity, get back a proportionate amount of iFIL tokens based on the current price of iFIL
- Mint -> specify an amount of iFIL tokens to receive, and GLIF will transfer the appropriate amount of wFIL tokens from the depositor to mint the specified amount of iFIL tokens

Most application builders will prefer to use the `deposit` functionality, because it's simpler due to specifying the amount of FIL to add in liquidity.

Application builders can use the `previewDeposit` and `previewMint` functions to determine the exchange of iFIL/FIL tokens that will result in a call to `deposit` or `mint`

### Withdraw vs Redeem

There are also two ways to remove liquidity from GLIF - via `withdraw` or `redeem`

- Withdraw -> specify an amount of FIL to receive, the pool will burn the proportionate amount of iFIL tokens
- Redeem -> specify an amount of iFIL tokens to burn, the pool will return the proporionate amount of FIL tokens

Application builders can use the `previewWithdraw` and `previewRedeem` functions to determine the exchange of iFIL/FIL tokens that will result in a call to `withdraw` or `redeem`

### Approvals

When using any of: `deposit`, `mint`, `withdraw`, `redeem`, the `msg.sender` will need to have granted a sufficient allowance to GLIF to spend the appropriate amount of wFIL or iFIL tokens. To grant an allowance, use `iFIL.approve` method - see the ERC20 interface for more information.

### ConvertToAssets and ConvertToShares

- `convertToAssets` calculates the amount of FIL a specific amount of iFIL tokens corresponds to. You can use `convertToAssets` to get the current iFIL price.
- `convertToShares` calculates the amount of iFIL a specific amount of FIL is worth.

## JS code examples (using Ethers V6)

### Add liquidity to GLIF

```js
import { abi: InfinityPoolV2ABI } from "abis/InfinityPoolV2";
import { abi: WFILABI } from "abis/WFIL";
import { abi: ERC20ABI } from "abis/ERC20";

// Connected to a Signer; can make state changing transactions,
// which will cost the account ether
pool = new Contract("<infinity-pool-v2-address>", InfinityPoolV2ABI, signer);
wfil = new Contract("<wfil-address>", WFILABI, signer)
ifil = new Contract("<ifil-address>", ERC20ABI, signer)

// 1 FIL worth of liquidity added
amount = parseUnits("1.0", 18);

// receiver of iFIL tokens
receiver = "0x...";

/*//////////////////////////////////////////////////////////////
                    Deposit native FIL tokens
//////////////////////////////////////////////////////////////*/

// deposit native FIL, this does not require any approvals / allowances
tx = await pool.deposit(receiver, { value: amount });

// wait for the tx to be confirmed
await tx.wait();

/*//////////////////////////////////////////////////////////////
                    Deposit Wrapped FIL tokens
//////////////////////////////////////////////////////////////*/

// wrap FIL tokens to receive WFIL
tx = await wfil.deposit({value: amount})
await tx.wait()

// approve the pool to spend `amount` of wFIL tokens
tx = await wfil.approve("<infinity-pool-v2-address", amount)
await tx.wait()

// deposit wFIL tokens into the pool
tx = await pool.deposit(amount, receiver)
await tx.wait()

/*//////////////////////////////////////////////////////////////
                    Mint iFIL tokens
//////////////////////////////////////////////////////////////*/

// this call specifies the amount of iFIL we'd like to receive, rather than the amount of FIL to deposit

// specify an amount of iFIL to receive from a call to `mint`
amountOfIFILToReceive = parseUnits("2.0", 18)

// calculate the amount of FIL required to mint the amount
wfilRequired = await pool.convertToAssets(amountOfIFILToReceive)

// assuming the wallet has enough wFIL tokens, approve the pool to spend
tx = await wfil.approve("<infinity-pool-v2-address", wfilRequired)
await tx.wait()

// mint iFIL tokens from the pool - the associated amount of WFIL tokens will be transferred into the pool
tx = await pool.mint(amountOfIFILToReceive, receiver)
await tx.wait()
```

### Remove liquidity from GLIF

```js
import { abi: InfinityPoolV2ABI } from "abis/InfinityPoolV2";
import { abi: WFILABI } from "abis/WFIL";
import { abi: ERC20ABI } from "abis/ERC20";

// Connected to a Signer; can make state changing transactions,
// which will cost the account ether
pool = new Contract("<infinity-pool-v2-address>", InfinityPoolV2ABI, signer);
wfil = new Contract("<wfil-address>", WFILABI, signer)
ifil = new Contract("<ifil-address>", ERC20ABI, signer)

// owner of the iFIL tokens before the exit
owner = "0x..."
// receiver of FIL/WFIL tokens after exit
receiver = "0x..."

/*//////////////////////////////////////////////////////////////
                          Redeem
//////////////////////////////////////////////////////////////*/

// 1 iFIL token to redeem
iFILToBurn = parseUnits("1.0", 18);

// preview the redeem
previewFILToReceive = await pool.previewRedeem(iFILToBurn)
// if the pool has no liquidity, previewRedeem will return 0, so we save ourselves an extra call if there's no liquidity
if (previewFILToReceive > 0) {
  // approve the pool to spend the necessary iFIL
  tx = ifil.approve("<infinity-pool-v2-address>", iFILToBurn)
  await tx.wait()

  // TO RECEIVE FIL - use redeemF
  tx = await pool.redeemF(iFILToBurn, receiver, owner)
  // TO RECEIVE WFIL - use redeem
  // tx = await pool.redeem(iFILToBurn, receiver, owner)
  await tx.wait()
}

/*//////////////////////////////////////////////////////////////
                          Withdraw
//////////////////////////////////////////////////////////////*/

// 1 FIL token to receive from a withdrawal
filToReceive = parseUnits("1.0", 18);

// figure out how many iFIL tokens we need to burn to receive `filToReceive`
iFILToBurn = await pool.previewWithdraw(filToReceive)
// if the pool has no liquidity, previewWithdraw will return 0, so we save ourselves an extra call if there's no liquidity
if (iFILToBurn > 0) {
  // approve the pool to spend the necessary iFIL
  tx = ifil.approve("<infinity-pool-v2-address>", iFILToBurn)
  await tx.wait()

  // TO RECEIVE FIL - use withdrawF
  tx = await pool.withdrawF(filToReceive, receiver, owner)
  // TO RECEIVE WFIL - use redeem
  // tx = await pool.withdraw(filToReceive, receiver, owner)
  await tx.wait()
}
```
