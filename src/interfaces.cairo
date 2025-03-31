use starknet::ContractAddress;

#[starknet::interface]
pub trait IJediSwapRouter<TContractState> {
    fn swap_exact_tokens_for_tokens(
        self: @TContractState,
        amountIn: u256,
        amountOutMin: u256,
        path: Array<ContractAddress>,
        to: ContractAddress,
        deadline: u64,
    ) -> Array<u256>;
}

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
