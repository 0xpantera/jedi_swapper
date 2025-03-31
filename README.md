# JediSwapper

A simple StarkNet contract that interacts with JediSwap DEX to perform token swaps.

## Overview

JediSwapper is a smart contract implementation on StarkNet that provides a simplified interface for executing swaps on JediSwap, a decentralized exchange on StarkNet. This project demonstrates how to integrate with DeFi protocols on StarkNet using Cairo.

## Features

- Swap ERC20 tokens using JediSwap
- Simple interface to handle token approvals and swaps in a single transaction
- Testing infrastructure using StarkNet Foundry

## Project Structure

```
jedi_swapper/
├── src/
│   ├── interfaces.cairo    # Interface definitions
│   ├── lib.cairo           # Library exports
│   └── swapper.cairo       # Main contract implementation
├── tests/
│   └── test_contract.cairo # Test using fork testing
├── Scarb.toml              # Package configuration
└── snfoundry.toml          # StarkNet Foundry configuration
```

## Contract Interfaces

### `ISwapAdapter`

```cairo
#[starknet::interface]
pub trait ISwapAdapter<TContractState> {
    fn swap(
        self: @TContractState,
        token_from_address: ContractAddress,
        token_from_amount: u256,
        token_to_address: ContractAddress,
        token_to_min_amount: u256,
        to: ContractAddress,
    );
}
```

## Installation

1. Make sure you have [Scarb](https://docs.swmansion.com/scarb/) and [StarkNet Foundry](https://foundry-rs.github.io/starknet-foundry/) installed

2. Clone the repository:
```bash
git clone https://github.com/yourusername/jedi_swapper.git
cd jedi_swapper
```

3. Build the project:
```bash
scarb build
```

## Testing

The project includes fork tests that simulate interactions with real contracts on StarkNet mainnet. To run the tests:

```bash
scarb test
# or
snforge test
```

The test simulates:
1. Creating an account with 1 ETH
2. Deploying the JediSwapper contract
3. Swapping ETH for USDC through JediSwap
4. Verifying that the swap was successful

## Usage Example

To use this contract after deployment:

```cairo
// Instantiate the dispatcher
let swapper = ISwapAdapterDispatcher { contract_address: deployed_address };

// Approve tokens first (not shown here)
// ...

// Execute a swap
swapper.swap(
    token_from_address,  // Address of token to swap from
    amount_to_swap,      // Amount to swap
    token_to_address,    // Address of token to receive
    min_amount_out,      // Minimum amount to receive (slippage protection)
    recipient_address    // Address to receive swapped tokens
);
```

## How It Works

1. The `swap` function takes the input token and amount, and the desired output token
2. It transfers tokens from the caller to the contract
3. It approves the JediSwap router to spend these tokens
4. It calls the JediSwap router to execute the swap
5. The swapped tokens are sent directly to the specified recipient

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This is example code for educational purposes. It is not audited and should not be used in production without proper security review.
