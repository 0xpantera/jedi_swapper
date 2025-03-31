// Library Imports

// Swapper Imports
use jedi_swapper::interfaces::{ISwapAdapterDispatcher, ISwapAdapterDispatcherTrait};
use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, map_entry_address, start_cheat_caller_address,
    stop_cheat_caller_address, store,
};
use starknet::ContractAddress;

const JEDI_ROUTER_ADDR: ContractAddress =
    0x41fd22b238fa21cfcf5dd45a8548974d8263b3a531a60388411c5e230f97023
    .try_into()
    .unwrap();

fn deploy_swapper() -> (ContractAddress, ISwapAdapterDispatcher) {
    let contract = declare("JediSwapper").unwrap().contract_class();
    let constructor_calldata = array![JEDI_ROUTER_ADDR.into()];
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    let dispatcher = ISwapAdapterDispatcher { contract_address };

    (contract_address, dispatcher)
}

#[test]
#[fork("MAINNET_FORK_609051")]
fn test_starknet_jedi_swap() {
    // Tokens involved in the swap
    let token_eth: ContractAddress =
        0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
        .try_into()
        .unwrap();
    let token_usdc: ContractAddress =
        0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8
        .try_into()
        .unwrap();
    let dispatcher_eth = IERC20Dispatcher { contract_address: token_eth };
    let dispatcher_usdc = IERC20Dispatcher { contract_address: token_usdc };

    // The only account we have is Alice :)
    let alice_felt = 1;
    let alice: ContractAddress = alice_felt.try_into().unwrap();

    // Give Alice 1 ETH by overriding the ERC20 balance mapping
    let one_ether: felt252 = 1000000000000000000;
    let one_ether_uint: u256 = one_ether.into();
    store(
        token_eth,
        map_entry_address(selector!("ERC20_balances"), array![alice_felt].span()),
        array![one_ether].span(),
    );
    assert(one_ether_uint == dispatcher_eth.balance_of(alice), 'Alice balacne is wrong');

    // TODO: Deploy the swapper using the helper function
    let (swapper_address, swapper_dispatcher) = deploy_swapper();

    // TODO: Swap ETH to USDC using your swapper
    start_cheat_caller_address(token_eth, alice);
    dispatcher_eth.approve(swapper_address, one_ether_uint);
    stop_cheat_caller_address(token_eth);
    start_cheat_caller_address(swapper_address, alice);
    // Swap 1 ETH for a minimum of 0 USDC (bad! dont do this)
    swapper_dispatcher.swap(token_eth, one_ether_uint, token_usdc, 0, alice);
    stop_cheat_caller_address(swapper_address);

    // Check that Alice's balance of USDC is larger than zero
    assert!(dispatcher_usdc.balance_of(alice) > 0, "Alice balance of USDC is zero");
}
