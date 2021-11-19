#include "partials/methods.mligo"

let main (action, s : entrypoint * storage_farm) : return =
    match action with
    | Set_admin(admin) -> set_admin(admin, s)
    | Stake(value) -> stake_some(value, s)
    | Unstake(value) -> unstake_some(value, s)
    | Claim_all() -> claim_all(s)
    | Increase_reward(value) -> increase_reward(value, s)