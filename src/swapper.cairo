#[starknet::contract]
mod JediSwapper {
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use crate::interfaces::{
        IJediSwapRouterDispatcher, IJediSwapRouterDispatcherTrait, ISwapAdapter,
    };

    #[storage]
    struct Storage {
        jedi_router: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, _jedi_router: ContractAddress) {
        self.jedi_router.write(_jedi_router);
    }

    #[abi(embed_v0)]
    impl JediswapAdapter of ISwapAdapter<ContractState> {
        fn swap(
            self: @ContractState,
            token_from_address: ContractAddress,
            token_from_amount: u256,
            token_to_address: ContractAddress,
            token_to_min_amount: u256,
            to: ContractAddress,
        ) {
            let caller = get_caller_address();
            let contract_address = get_contract_address();
            let token_from_dispatcher = IERC20Dispatcher { contract_address: token_from_address };

            // Get the tokens from the user
            token_from_dispatcher.transfer_from(caller, contract_address, token_from_amount);

            // Approve the router to spend the tokens
            token_from_dispatcher.approve(self.jedi_router.read(), token_from_amount);

            // Prepare swap parameters
            let path = array![token_from_address, token_to_address];
            // Danger don't do this in prod. It's basically disabling deadline.
            let deadline = get_block_timestamp();

            // Perform swap
            IJediSwapRouterDispatcher { contract_address: self.jedi_router.read() }
                .swap_exact_tokens_for_tokens(
                    token_from_amount, token_to_min_amount, path, to, deadline,
                );
        }
    }
}
