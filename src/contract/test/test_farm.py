from unittest import TestCase
from contextlib import contextmanager
from copy import deepcopy
from pytezos import ContractInterface, MichelsonRuntimeError, pytezos
from pytezos.michelson.types.big_map import big_map_diff_to_lazy_diff
import time
import json 

alice = 'tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur'
admin = 'tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK'
bob = 'tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF'
oscar = 'tz1Phy92c2n817D17dUGzxNgw1qCkNSTWZY2'
fox = 'tz1XH5UyhRCUmCdUUbqD4tZaaqRTgGaFXt7q'

sec_week = 604800
farm_address = "KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" # Hardcoded farm address for tests
compiled_contract_path = "compiled/farm.tz"

initial_storage = ContractInterface.from_file(compiled_contract_path).storage.dummy()
initial_storage["admin"] = admin
initial_storage["input_token_address"] ="KT1XtQeSap9wvJGY1Lmek84NU6PK6cjzC9Qd"
initial_storage["reward_token_address"] = "KT1TwzD6zV3WeJ39ukuqxcfK2fJCnhvrdN1X"
initial_storage["reward_reserve_address"] = "tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK"
initial_storage["total_reward"] = 10000000
initial_storage["total_weeks"] = 5
initial_storage["rate"] = 7500
initial_storage["user_stakes"] = {}
initial_storage["user_points"] = {}
initial_storage["farm_points"] = []
initial_storage["creation_time"] = 0

only_admin = "Only the contract admin can change the contract administrator or increase reward"
unknown_input_token_entrypoint = "Cannot connect to the input token entrypoint"
unknown_reward_token_entrypoint = "Cannot connect to the reward token entrypoint"
amount_is_null = "The farm staking amount must be greater than zero"
increase_amount_is_null = "The increase amount must be greater than zero"
amount_must_be_zero_tez = "You must not send Tezos to the smart contract"
time_too_early = "Please try again in few seconds" 
no_stakes = "You did not stake any token yet"
unstake_more_than_stake = "You cannot unstake more than your farm staking"
no_week_left = "There are no more weeks left for staking in the farm"
contract_already_initialized = "The contract is already initialized"

class FarmsContractTest(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.farms = ContractInterface.from_file(compiled_contract_path)
        cls.maxDiff = None

    @contextmanager
    def raisesMichelsonError(self, error_message):
        with self.assertRaises(MichelsonRuntimeError) as r:
            yield r

        error_msg = r.exception.format_stdout()
        if "FAILWITH" in error_msg:
            self.assertEqual(f"FAILWITH: '{error_message}'", r.exception.format_stdout())
        else:
            self.assertEqual(f"'{error_message}': ", r.exception.format_stdout())

    #######################
    # Tests for set_admin #
    #######################

    def test_set_admin_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        res = self.farms.set_admin(bob).interpret(storage=init_storage, sender=admin, now=int(sec_week + sec_week/2))
        self.assertEqual(bob, res.storage["admin"])
        self.assertEqual([], res.operations)

    def test_set_admin_user_sets_new_admin_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(only_admin):
            self.farms.set_admin(bob).interpret(storage=init_storage, sender=alice, now=int(sec_week + sec_week/2))

    def test_set_admin_sending_XTZ_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(amount_must_be_zero_tez):
            self.farms.set_admin(bob).interpret(storage=init_storage, sender=admin, now=int(sec_week + sec_week/2), amount=1)

    #######################
    # Test for initialize #
    #######################


    def test_initializeReward_5week_20Kreward_75rate_initialization_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["total_weeks"] = 5
        init_storage["rate"] = 7500
        # Execute entrypoint
        res = self.farms.initialize().interpret(storage=init_storage, sender=admin)
        expected_rewards = [6555697, 4916773, 3687580, 2765685, 2074263]
        self.assertEqual(res.storage["reward_at_week"], expected_rewards)

    def test_initializeReward_5week_30Kreward_80rate_initialization_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 30_000_000
        init_storage["total_weeks"] = 5
        init_storage["rate"] = 8000
        # Execute entrypoint
        res = self.farms.initialize().interpret(storage=init_storage, sender=admin)
        expected_rewards = [8924321, 7139457, 5711565, 4569252, 3655402]
        self.assertEqual(res.storage["reward_at_week"], expected_rewards)

    def test_initializeReward_3week_40Kreward_60rate_initialization_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 40_000_000
        init_storage["total_weeks"] = 3
        init_storage["rate"] = 6000
        # Execute entrypoint
        res = self.farms.initialize().interpret(storage=init_storage, sender=admin)
        expected_rewards = [20408163, 12244897, 7346938]
        self.assertEqual(res.storage["reward_at_week"], expected_rewards)

    #########################
    # Test increase rewards #
    #########################

    def test_increase_reward_reward_50k_on_week_3_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["total_weeks"] = 5
        init_storage["rate"] = 7500
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        # Execute entrypoint
        res = self.farms.increase_reward(50_000_000).interpret(storage=init_storage, sender=admin, now=int(sec_week * 2 + sec_week/2))
        expected_rewards = [6555697, 4916773, 25309201, 18981901, 14236425]
        self.assertEqual(res.storage["total_reward"], 70000000)
        self.assertEqual(res.storage["total_weeks"], 5)
        self.assertEqual(res.storage["reward_at_week"], expected_rewards)

    def test_increase_reward_reward_20k_on_week_2_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 10_000_000
        init_storage["total_weeks"] = 3
        init_storage["rate"] = 7500
        init_storage["reward_at_week"] = [4324324, 3243243, 2432432]
        # Execute entrypoint
        res = self.farms.increase_reward(20_000_000).interpret(storage=init_storage, sender=admin, now=int(sec_week + sec_week/2))
        expected_rewards = [4324324, 14671814, 11003860]
        self.assertEqual(res.storage["total_reward"], 30000000)
        self.assertEqual(res.storage["total_weeks"], 3)
        self.assertEqual(res.storage["reward_at_week"], expected_rewards)

    def test_increase_reward_if_not_admin_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        # Execute entrypoint
        with self.raisesMichelsonError(only_admin):
            res = self.farms.increase_reward(20_000_000).interpret(storage=init_storage, sender=fox, now=int(sec_week + sec_week/2))

    def test_increase_reward_after_end_of_pool_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        # Execute entrypoint
        with self.raisesMichelsonError(no_week_left):
            res = self.farms.increase_reward(20_000_000).interpret(storage=init_storage, sender=admin, now=int(sec_week * 20 + sec_week/2))

    ######################
    # Tests for Staking #
    ######################

    def test_stake_one_time_on_second_week_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        locked_amount = 20
        # Execute entrypoint
        res = self.farms.stake(locked_amount).interpret(storage=init_storage, sender=bob, now=int(sec_week + sec_week/2))
        self.assertEqual(len(res.operations), 1)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(bob, transfer_tx_params[0]['string'])
        self.assertEqual(farm_address, transfer_tx_params[1]['string'])
        self.assertEqual(locked_amount, int(transfer_tx_params[2]['int']))
        self.assertEqual(locked_amount, res.storage["user_stakes"][bob])
        expected_user_points = [0, sec_week * locked_amount / 2, sec_week * locked_amount, sec_week * locked_amount, sec_week * locked_amount]
        self.assertEqual(res.storage["user_points"][bob], expected_user_points)
        self.assertEqual(res.storage["farm_points"], expected_user_points)

    def test_stake_with_XTZ_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(amount_must_be_zero_tez):
            self.farms.stake(20).interpret(storage=init_storage, sender=bob, now=int(sec_week + sec_week/2), amount=1)

    def test_stake_two_times_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][bob] = 300
        init_storage["user_points"][bob] = [0,0,int(300 * sec_week / 2),300 * sec_week, 300 * sec_week ]
        init_storage["farm_points"] = [0,0,int(300 * sec_week / 2),300 * sec_week, 300 * sec_week ]
        # Execute entrypoint
        res = self.farms.stake(500).interpret(storage=init_storage, sender=bob, now=int(3 * sec_week + sec_week*2/3))
        self.assertEqual(len(res.operations), 1)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(bob, transfer_tx_params[0]['string'])
        self.assertEqual(farm_address, transfer_tx_params[1]['string'])
        self.assertEqual(500, int(transfer_tx_params[2]['int']))
        self.assertEqual(800, res.storage["user_stakes"][bob])
        expected_user_points = [0, 0, int(sec_week * 300 / 2), int(sec_week * 300 + sec_week * 500 / 3), int(sec_week * 300 + sec_week * 500) ]
        self.assertEqual(res.storage["user_points"][bob], expected_user_points)
        self.assertEqual(res.storage["farm_points"], expected_user_points)

    def test_stake_with_two_different_users_should_work(self):
        # Init
        new_storage = deepcopy(initial_storage)
        new_storage["user_stakes"][bob] = 300
        new_storage["user_points"][bob] = [0,0,int(300 * sec_week / 2),300 * sec_week, 300 * sec_week ]
        new_storage["farm_points"] = [0,0,int(300 * sec_week / 2),300 * sec_week, 300 * sec_week ]
        # Execute entrypoint
        res = self.farms.stake(400).interpret(storage=new_storage, sender=alice, now=int(2*sec_week + sec_week*2/3))
        self.assertEqual(len(res.operations), 1)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(alice, transfer_tx_params[0]['string'])
        self.assertEqual(farm_address, transfer_tx_params[1]['string'])
        self.assertEqual(400, int(transfer_tx_params[2]['int']))
        self.assertEqual(400, res.storage["user_stakes"][alice])
        expected_user_points = [0, 0, int(sec_week * 400 / 3), sec_week * 400, sec_week * 400 ]
        expected_farm_points = [0, 0, int(sec_week * 400 / 3) + int(300 * sec_week / 2), sec_week * 700, sec_week * 700 ]
        self.assertEqual(res.storage["user_points"][alice], expected_user_points)
        self.assertEqual(res.storage["farm_points"], expected_farm_points)

    def test_stake_0_LP_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(amount_is_null):
            res = self.farms.stake(0).interpret(storage=init_storage, sender=alice, now=int(sec_week + sec_week/2))
    
    def test_stake_after_end_of_pool_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(no_week_left):
            self.farms.stake(10).interpret(storage=init_storage, sender=alice, now=int(5 * sec_week + sec_week/2))

    #####################
    # Tests for Unstake #
    #####################

    def test_unstake_basic_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.unstake(250).interpret(sender=alice, storage=init_storage, now=int(sec_week + sec_week/2))
        expected_user_points = [int(500 * sec_week/2), int((500+250) * sec_week/2), 250 * sec_week, 250 * sec_week, 250 * sec_week]
        self.assertEqual(res.storage["user_stakes"][alice], 250)
        self.assertEqual(res.storage["user_points"][alice], expected_user_points)
        self.assertEqual(res.storage["farm_points"], expected_user_points)

    def test_unstake_same_week_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.unstake(499).interpret(sender=alice, storage=init_storage, now=int(sec_week*3/4))
        expected_user_points = [int(500 * sec_week/2) - int(499 * sec_week/4), sec_week, sec_week, sec_week, sec_week ]
        self.assertEqual(res.storage["user_points"][alice], expected_user_points)
        self.assertEqual(res.storage["farm_points"], expected_user_points)
        self.assertEqual(res.storage["user_stakes"][alice], 1)

    def test_unstake_total_stake_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.unstake(500).interpret(sender=alice, storage=init_storage, now=int(sec_week + sec_week/2))
        expected_user_points = [int(500 * sec_week/2), int(500 * sec_week/2), 0, 0, 0 ]
        self.assertEqual(res.storage["user_points"][alice], expected_user_points)
        self.assertEqual(res.storage["farm_points"], expected_user_points)
        self.assertEqual(res.storage["user_stakes"][alice], 0)

    def test_unstake_more_than_staked_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        with self.raisesMichelsonError(unstake_more_than_stake):
            self.farms.unstake(501).interpret(sender=alice, storage=init_storage, now=int(sec_week + sec_week / 2))

    def test_unstake_with_0_staked_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        with self.raisesMichelsonError(no_stakes):
            self.farms.unstake(10).interpret(storage=init_storage, sender=bob)

    def test_unstake_with_two_users_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][bob] = 600
        init_storage["user_points"][bob] = [0, 0, int(600 * sec_week / 3), 600 * sec_week, 600 * sec_week]
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week / 2), 500 * sec_week, int(600 * sec_week / 3) + 500 * sec_week, 600 * sec_week + 500 * sec_week, 600 * sec_week + 500 * sec_week]
        # Execute entrypoint
        res = self.farms.unstake(100).interpret(storage=init_storage, sender=bob, now=int(3 * sec_week + sec_week * 6 / 7))
        expected_userpoint_bob = [0, 0, int(600 * sec_week / 3), int((600 * (6 / 7) + 500 / 7) * sec_week), 500 * sec_week]
        expected_userpoint_alice = [int(500 * sec_week / 2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        expected_farmpoint = [int(500 * sec_week / 2), 500 * sec_week, int(600 * sec_week / 3) + 500 * sec_week, int((600 * (6 / 7) + 500 / 7) * sec_week) + 500 * sec_week, 500 * sec_week + 500 * sec_week]
        self.assertEqual(res.storage["user_points"][bob], expected_userpoint_bob)
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["farm_points"], expected_farmpoint)
        self.assertEqual(res.storage["user_stakes"][bob], 500)

    def test_unstake_should_work_after_pool_end(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.unstake(250).interpret(sender=alice, storage=init_storage, now=sec_week * 1000)
        expected_userpoint_alice = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        self.assertEqual(res.storage["user_stakes"][alice], 250)
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["farm_points"], expected_userpoint_alice)

    def test_unstake_with_two_users_at_the_pool_end_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["user_stakes"][bob] = 600
        init_storage["user_points"][bob] = [0, 0, int(600 * sec_week / 3), 600 * sec_week, 600 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, int(600 * sec_week / 3) + 500 * sec_week, 1100 * sec_week, 1100 * sec_week]
        # Execute entrypoint
        res = self.farms.unstake(500).interpret(storage=init_storage, sender=bob, now=int(30 * sec_week + sec_week * 6 / 7))
        expected_userpoint_alice = [int(500 * sec_week / 2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        expected_userpoint_bob = [0, 0, int(600 * sec_week / 3), 600 * sec_week, 600 * sec_week]
        expected_farmpoint = [int(500 * sec_week/2), 500 * sec_week, int(600 * sec_week / 3) + 500 * sec_week, 1100 * sec_week, 1100 * sec_week]
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["user_stakes"][bob], 100)
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_points"][bob], expected_userpoint_bob)
        self.assertEqual(res.storage["farm_points"], expected_farmpoint)

    def test_unstake_everything_with_two_users_at_the_pool_end_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["user_stakes"][bob] = 600
        init_storage["user_points"][bob] = [0, 0, int(600 * sec_week / 3), 600 * sec_week, 600 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, int(600 * sec_week / 3) + 500 * sec_week, 1100 * sec_week, 1100 * sec_week]
        # Execute entrypoint
        res = self.farms.unstake(600).interpret(storage=init_storage, sender=bob, now=int(30 * sec_week + sec_week * 6 / 7))
        expected_userpoint_alice = [int(500 * sec_week / 2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        expected_userpoint_bob = [0, 0, int(600 * sec_week / 3), 600 * sec_week, 600 * sec_week]
        expected_farmpoint = [int(500 * sec_week/2), 500 * sec_week, int(600 * sec_week / 3) + 500 * sec_week, 1100 * sec_week, 1100 * sec_week]
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["user_stakes"][bob], 0)
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_points"][bob], expected_userpoint_bob)
        self.assertEqual(res.storage["farm_points"], expected_farmpoint)

    def test_unstake_after_increasing_reward_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 10_000_000
        init_storage["total_weeks"] = 3
        init_storage["rate"] = 7500
        init_storage["reward_at_week"] = [4324324, 3243243, 2432432]
        # Execute entrypoint
        res = self.farms.increase_reward(20_000_000).interpret(storage=init_storage, sender=admin, now=int(sec_week + sec_week/2))
        res2 = self.farms.stake(10000).interpret(storage=res.storage, sender=alice, now=int(2 * sec_week + sec_week/2))
        res3 = self.farms.unstake(10000).interpret(storage=res2.storage, sender=alice, now=int(3 * sec_week + sec_week/2))
        self.assertEqual(res3.storage["total_reward"], 30000000)
        self.assertEqual(res3.storage["total_weeks"], 3)
        self.assertEqual(res3.storage["admin"], admin)
        transfer_tx_params = res3.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], farm_address)
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int']), 10000)
        expected_farmpoint = [0, 0, int(10000*sec_week/2)]
        self.assertEqual(res3.storage["farm_points"], expected_farmpoint)
        self.assertEqual(res3.storage["user_stakes"][alice], 0)

    ######################
    # Tests for ClaimAll #
    ######################

    def test_claimall_with_0_points_should_work_with_0_operation(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.claim_all().interpret(storage=init_storage, sender=bob, now=int(sec_week * 7 + sec_week/2))
        self.assertEqual(res.storage["admin"], admin)
        self.assertEqual(res.operations, [])

    def test_claimall_2rd_week_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.claim_all().interpret(storage=init_storage, sender=alice, now=int(sec_week + sec_week/2))
        self.assertEqual(res.storage["admin"], admin)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], initial_storage["reward_reserve_address"])
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int']), init_storage["reward_at_week"][0])
        expected_userpoint_alice = [0, 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["farm_points"], init_storage["farm_points"] )

    def test_claimall_3rd_week_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.claim_all().interpret(storage=init_storage, sender=alice, now=int(sec_week * 2 + sec_week/2))
        self.assertEqual(res.storage["admin"], admin)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], initial_storage["reward_reserve_address"])
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int']), sum(init_storage["reward_at_week"][:2]))
        expected_userpoint_alice = [0, 0, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["farm_points"], init_storage["farm_points"] )

    def test_claimall_with_2_stakers_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [0, int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["user_stakes"][bob] = 100
        init_storage["user_points"][bob] = [0, int(100 * sec_week * (1 - 1/2)), 100 * sec_week, 100 * sec_week, 100 * sec_week]
        init_storage["farm_points"] = [x + y for x, y in zip(init_storage["user_points"][alice],init_storage["user_points"][bob])]
        alice_week1_reward_expected = init_storage["reward_at_week"][1] * init_storage["user_points"][alice][1]/ init_storage["farm_points"][1] 
        alice_week2_reward_expected = init_storage["reward_at_week"][2] * init_storage["user_points"][alice][2]/ init_storage["farm_points"][2] 
        # Execute entrypoint
        res = self.farms.claim_all().interpret(storage=init_storage, sender=alice, now=int(sec_week * 3 + sec_week / 2))
        self.assertEqual(res.storage["admin"], admin)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], initial_storage["reward_reserve_address"])
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int'])+1, int(alice_week1_reward_expected+alice_week2_reward_expected))
        expected_userpoint_alice = [0, 0, 0, 500 * sec_week, 500 * sec_week]
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["farm_points"], init_storage["farm_points"] )

    def test_claimall_with_2_stakers_not_staking_middle_week_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [500 * sec_week, 0, int(500 * sec_week * (1 - 2/3)), 500 * sec_week, 500 * sec_week]
        init_storage["user_stakes"][bob] = 500
        init_storage["user_points"][bob] = [500 * sec_week, 0, int(500 * sec_week * (1 - 1/2)), 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [x + y for x, y in zip(init_storage["user_points"][alice],init_storage["user_points"][bob])]
        # Execute entrypoint
        res = self.farms.claim_all().interpret(storage=init_storage, sender=alice, now=int(sec_week * 3 + sec_week / 2))
        reward_expected = int(6555697/2) + int((int(500 * sec_week * (1 - 2/3)) / int(500 * sec_week * (1 - 2/3) + 500 * sec_week * (1 - 1/2)) )* 3687580) - 1
        self.assertEqual(res.storage["admin"], admin)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], initial_storage["reward_reserve_address"])
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int'])-1, reward_expected)
        expected_userpoint_alice = [0, 0, 0, 500 * sec_week, 500 * sec_week]
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["farm_points"], init_storage["farm_points"] )

    def test_claimall_after_pool_end_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week / 2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week / 2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        res = self.farms.claim_all().interpret(storage=init_storage, sender=alice, now=sec_week * 100)
        self.assertEqual(res.storage["admin"], admin)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], initial_storage["reward_reserve_address"])
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int']) + 2, init_storage["total_reward"])
        expected_userpoint_alice = [0, 0, 0, 0, 0]
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["farm_points"], init_storage["farm_points"] )

    def test_claimall_with_2_stakers_not_staking_last_week_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["total_reward"] = 20_000_000
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week, 0]
        init_storage["user_stakes"][bob] = 500
        init_storage["user_points"][bob] = [500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week, 0]
        init_storage["farm_points"] = [x + y for x, y in zip(init_storage["user_points"][alice],init_storage["user_points"][bob])]
        # Execute entrypoint
        res = self.farms.claim_all().interpret(storage=init_storage, sender=alice, now=int(sec_week * 6 + sec_week / 2))
        reward_expected = int(6555697 / 2) + int(4916773 / 2) + int(3687580 / 2)  + int(2765685 / 2) 
        self.assertEqual(res.storage["admin"], admin)
        transfer_tx_params = res.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], initial_storage["reward_reserve_address"])
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int']), reward_expected)
        expected_userpoint_alice = [0]*5
        self.assertEqual(res.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res.storage["user_stakes"][alice], 500)
        self.assertEqual(res.storage["farm_points"], init_storage["farm_points"] )

    def test_claimall_with_XTZ_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 500
        init_storage["user_points"][alice] = [int(500 * sec_week/2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        init_storage["farm_points"] = [int(500 * sec_week / 2), 500 * sec_week, 500 * sec_week, 500 * sec_week, 500 * sec_week]
        # Execute entrypoint
        with self.raisesMichelsonError(amount_must_be_zero_tez):
            self.farms.claim_all().interpret(storage=init_storage, sender=bob, now=sec_week * 12, amount=1)


    def test_claimall_two_times_after_unstake_and_staking_two_times_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        init_storage["reward_at_week"] = [6555697, 4916773, 3687580, 2765685, 2074263]
        init_storage["creation_time"] = 0
        init_storage["user_stakes"][alice] = 0
        init_storage["user_points"][alice] = [int(500 * sec_week/2), int(500 * sec_week) +  int(500 * sec_week / 2 ) - int(1000 * sec_week / 3 ), 0, 0, 0]
        init_storage["farm_points"] = [int(500 * sec_week/2), int(500 * sec_week) +  int(500 * sec_week / 2 ) - int(1000 * sec_week / 3 ), 0, 0, 0]
        res = self.farms.claim_all().interpret(sender=alice, storage=init_storage, now=int(sec_week + sec_week*3/4))
        # Execute entrypoint
        res2 = self.farms.claim_all().interpret(sender=alice, storage=res.storage, now=int(sec_week * 2 + sec_week*3/4))
        self.assertEqual(res2.storage["admin"], admin)
        transfer_tx_params = res2.operations[0]["parameters"]["value"]['args']
        self.assertEqual(transfer_tx_params[0]['string'], initial_storage["reward_reserve_address"])
        self.assertEqual(transfer_tx_params[1]['string'], alice)
        self.assertEqual(int(transfer_tx_params[2]['int']), 4916773)
        expected_userpoint_alice = [0]*5
        self.assertEqual(res2.storage["user_points"][alice], expected_userpoint_alice)
        self.assertEqual(res2.storage["user_stakes"][alice], 0)
        self.assertEqual(res2.storage["farm_points"], init_storage["farm_points"] )