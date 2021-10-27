type farm_metadata = {
    lp_address : address;
    farm_lp_info : string
}

type farms_storage = {
    admin : address;
    all_farms : address set;
    all_farms_data : (address, farm_metadata) big_map
}

type addFarmParameter = {
    farm_address: address;
    lp_address: address;
    farm_lp_info : string
}

type farms_entrypoints = 
| AddFarm of addFarmParameter
| Nothing of unit

let noOperations : operation list = []

type return_farms = operation list * farms_storage

let addFarm(p, s : addFarmParameter * farms_storage) : return_farms =
    let _check_admin : bool = if Tezos.sender = s.admin then true else (failwith("Only admin") : bool) in
    let modified_set : address set = Set.add p.farm_address s.all_farms in 
    let modified_map : (address, farm_metadata) big_map = Big_map.add p.farm_address { lp_address = p.lp_address; farm_lp_info = p.farm_lp_info } s.all_farms_data in
    (noOperations, { s with all_farms = modified_set; all_farms_data = modified_map })

let main(action, store : farms_entrypoints * farms_storage) : return_farms =
    match action with
    | AddFarm(fp) -> addFarm(fp, store)
    | Nothing -> (noOperations, store)
