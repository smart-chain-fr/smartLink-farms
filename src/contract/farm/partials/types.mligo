type week = nat
type week_in_seconds = nat
type stake_param = nat
type reward_param = nat
type fa12_transfer = address * (address * nat)
type fa2_transfer = address * (address * (nat * nat)) list


type storage_farm = {
    admin: address;
    creation_time: timestamp;
    input_token_address: address;
    input_fa2_token_id_opt: nat option;
    reward_token_address: address;
    reward_fa2_token_id_opt: nat option;
    reward_reserve_address: address;
    rate: nat;
    reward_at_week : nat list;
    farm_points : nat list;
    total_reward: nat;
    user_points : (address, nat list) big_map;
    user_stakes : (address, nat) big_map;
    total_weeks: nat;
    initialized: bool
}

type no_operation = operation list
type return = operation list * storage_farm

type entrypoint = 
| Initialize of (unit)
| Stake of (stake_param)
| Unstake of (stake_param)
| Claim_all of (unit)
| Set_admin of (address)
| Increase_reward of (reward_param)