{ parameter
    (or (or (or (unit %claim_all) (nat %increase_reward))
            (or (unit %initialize) (address %set_admin)))
        (or (nat %stake) (nat %unstake))) ;
  storage
    (pair (pair (pair (pair (address %admin) (timestamp %creation_time))
                      (pair (list %farm_points nat) (address %lp_token_address)))
                (pair (pair (nat %rate) (address %reserve_address))
                      (pair (list %reward_at_week nat) (address %smak_address))))
          (pair (pair (nat %total_reward) (nat %total_weeks))
                (pair (big_map %user_points address (list nat)) (big_map %user_stakes address nat)))) ;
  code { UNPAIR ;
         IF_LEFT
           { IF_LEFT
               { IF_LEFT
                   { DROP ;
                     SENDER ;
                     PUSH string "You must not send Tezos to the smart contract" ;
                     PUSH mutez 0 ;
                     AMOUNT ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     CDR ;
                     CDR ;
                     CAR ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     GET ;
                     IF_NONE
                       { DROP ; NIL operation ; PAIR }
                       { DUP 3 ;
                         CAR ;
                         CDR ;
                         CDR ;
                         CAR ;
                         DUP 4 ;
                         CAR ;
                         CAR ;
                         CDR ;
                         CAR ;
                         PAIR ;
                         SWAP ;
                         DUP ;
                         DUG 2 ;
                         PUSH nat 0 ;
                         PAIR ;
                         PAIR ;
                         LEFT nat ;
                         LOOP_LEFT
                           { UNPAIR ;
                             UNPAIR ;
                             DIG 2 ;
                             UNPAIR ;
                             SWAP ;
                             DUP ;
                             DUG 2 ;
                             SWAP ;
                             DUP ;
                             DUG 2 ;
                             DUP 6 ;
                             IF_CONS
                               { DIG 2 ;
                                 IF_CONS
                                   { DIG 4 ;
                                     IF_CONS
                                       { DIG 5 ;
                                         DIG 5 ;
                                         SWAP ;
                                         DROP ;
                                         DIG 4 ;
                                         DIG 4 ;
                                         SWAP ;
                                         DROP ;
                                         DIG 3 ;
                                         DIG 3 ;
                                         SWAP ;
                                         DROP ;
                                         DIG 2 ;
                                         MUL ;
                                         EDIV ;
                                         IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                                         CAR ;
                                         DIG 3 ;
                                         ADD ;
                                         DUG 2 ;
                                         PAIR ;
                                         DUG 2 ;
                                         PAIR ;
                                         PAIR ;
                                         LEFT nat }
                                       { DROP 8 ; PUSH string "size don't match" ; FAILWITH } }
                                   { DROP 7 ; PUSH string "size don't match" ; FAILWITH } }
                               { DIG 2 ;
                                 DIG 3 ;
                                 DIG 5 ;
                                 DROP 3 ;
                                 IF_CONS
                                   { DROP 4 ; PUSH string "size don't match" ; FAILWITH }
                                   { IF_CONS
                                       { DROP 3 ; PUSH string "size don't match" ; FAILWITH }
                                       { RIGHT (pair (pair nat (list nat)) (pair (list nat) (list nat))) } } } } ;
                         DUP 4 ;
                         CAR ;
                         CDR ;
                         CDR ;
                         CDR ;
                         CONTRACT %transfer (pair address (pair address nat)) ;
                         IF_NONE { PUSH string "Cannot connect to the SMAK contract" ; FAILWITH } {} ;
                         PUSH mutez 0 ;
                         DIG 2 ;
                         DUP 5 ;
                         PAIR ;
                         DUP 6 ;
                         CAR ;
                         CDR ;
                         CAR ;
                         CDR ;
                         PAIR ;
                         TRANSFER_TOKENS ;
                         SWAP ;
                         MAP { DROP ; PUSH nat 0 } ;
                         DUP 4 ;
                         CDR ;
                         CDR ;
                         CDR ;
                         DUP 5 ;
                         CDR ;
                         CDR ;
                         CAR ;
                         DIG 2 ;
                         SOME ;
                         DIG 4 ;
                         UPDATE ;
                         PAIR ;
                         DUP 3 ;
                         CDR ;
                         CAR ;
                         PAIR ;
                         DIG 2 ;
                         CAR ;
                         PAIR ;
                         NIL operation ;
                         DIG 2 ;
                         CONS ;
                         PAIR } }
                   { SWAP ;
                     DUP ;
                     DUG 2 ;
                     CDR ;
                     CAR ;
                     CDR ;
                     NOW ;
                     DUP 4 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CDR ;
                     DUP 5 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CDR ;
                     NOW ;
                     SUB ;
                     ABS ;
                     PUSH nat 1 ;
                     PUSH nat 604800 ;
                     DIG 2 ;
                     EDIV ;
                     IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                     CAR ;
                     ADD ;
                     PUSH string
                          "Only the contract admin can change the contract administrator or increase reward" ;
                     DUP 7 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CAR ;
                     SENDER ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     PUSH string "You must not send Tezos to the smart contract" ;
                     PUSH mutez 0 ;
                     AMOUNT ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     PUSH string "There are no more weeks left for staking" ;
                     PUSH nat 604800 ;
                     DUP 6 ;
                     MUL ;
                     INT ;
                     DUP 4 ;
                     ADD ;
                     DUP 5 ;
                     COMPARE ;
                     LT ;
                     IF { DROP } { FAILWITH } ;
                     PUSH string "The increase amount must be greater than zero" ;
                     PUSH nat 0 ;
                     DUP 7 ;
                     COMPARE ;
                     GT ;
                     IF { DROP } { FAILWITH } ;
                     PUSH nat 1 ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     DIG 5 ;
                     SUB ;
                     ABS ;
                     ADD ;
                     DUP 6 ;
                     CAR ;
                     CDR ;
                     CAR ;
                     CAR ;
                     NIL nat ;
                     DUP 3 ;
                     PAIR ;
                     LEFT (list nat) ;
                     LOOP_LEFT
                       { UNPAIR ;
                         PUSH nat 0 ;
                         SWAP ;
                         DUP ;
                         DUG 2 ;
                         COMPARE ;
                         EQ ;
                         IF { DROP ; RIGHT (pair nat (list nat)) }
                            { SWAP ;
                              PUSH nat 1 ;
                              DUP 3 ;
                              SUB ;
                              ABS ;
                              DUP ;
                              DUP 5 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              SWAP ;
                              DUP ;
                              DUG 2 ;
                              PUSH nat 10000 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              DUP 6 ;
                              PUSH nat 10000 ;
                              SUB ;
                              ABS ;
                              DIG 3 ;
                              PUSH nat 10000 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              SWAP ;
                              MUL ;
                              DUP 7 ;
                              DUP 7 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              DUP 8 ;
                              PUSH nat 10000 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              SUB ;
                              ABS ;
                              DIG 2 ;
                              MUL ;
                              DIG 2 ;
                              DUP 11 ;
                              DIG 3 ;
                              MUL ;
                              MUL ;
                              EDIV ;
                              IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                              CAR ;
                              CONS ;
                              PUSH nat 1 ;
                              DIG 2 ;
                              SUB ;
                              ABS ;
                              PAIR ;
                              LEFT (list nat) } } ;
                     SWAP ;
                     DIG 2 ;
                     DROP 2 ;
                     PUSH nat 1 ;
                     DIG 2 ;
                     SUB ;
                     ABS ;
                     SWAP ;
                     PAIR ;
                     LEFT (list nat) ;
                     LOOP_LEFT
                       { UNPAIR ;
                         PUSH nat 0 ;
                         DUP 3 ;
                         COMPARE ;
                         EQ ;
                         IF { SWAP ; DROP ; RIGHT (pair (list nat) nat) }
                            { PUSH nat 1 ;
                              DIG 2 ;
                              SUB ;
                              ABS ;
                              SWAP ;
                              PUSH nat 0 ;
                              CONS ;
                              PAIR ;
                              LEFT (list nat) } } ;
                     NIL nat ;
                     NIL nat ;
                     DIG 2 ;
                     DUP 7 ;
                     CAR ;
                     CDR ;
                     CDR ;
                     CAR ;
                     PAIR ;
                     PAIR ;
                     LEFT (list nat) ;
                     LOOP_LEFT
                       { UNPAIR ;
                         UNPAIR ;
                         IF_CONS
                           { DIG 2 ;
                             IF_CONS
                               { PUSH bool True ;
                                 PUSH bool True ;
                                 COMPARE ;
                                 EQ ;
                                 IF { DIG 2 ; ADD } { DIG 2 ; SUB ; ABS } ;
                                 DIG 3 ;
                                 SWAP ;
                                 CONS ;
                                 SWAP ;
                                 DIG 2 ;
                                 PAIR ;
                                 PAIR ;
                                 LEFT (list nat) }
                               { DROP 3 ; PUSH string "size don't match" ; FAILWITH } }
                           { IF_CONS
                               { DROP 3 ; PUSH string "size don't match" ; FAILWITH }
                               { RIGHT (pair (pair (list nat) (list nat)) (list nat)) } } } ;
                     PAIR ;
                     LEFT (list nat) ;
                     LOOP_LEFT
                       { UNPAIR ;
                         IF_CONS
                           { DIG 2 ; SWAP ; CONS ; SWAP ; PAIR ; LEFT (list nat) }
                           { RIGHT (pair (list nat) (list nat)) } } ;
                     DUP 5 ;
                     CDR ;
                     CDR ;
                     DUP 6 ;
                     CDR ;
                     CAR ;
                     CDR ;
                     DUP 6 ;
                     DUP 8 ;
                     CDR ;
                     CAR ;
                     CAR ;
                     ADD ;
                     PAIR ;
                     PAIR ;
                     DIG 5 ;
                     CAR ;
                     PAIR ;
                     DUP ;
                     CDR ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     CAR ;
                     CDR ;
                     CDR ;
                     CDR ;
                     DIG 3 ;
                     PAIR ;
                     DUP 3 ;
                     CAR ;
                     CDR ;
                     CAR ;
                     PAIR ;
                     DIG 2 ;
                     CAR ;
                     CAR ;
                     PAIR ;
                     PAIR ;
                     DUP ;
                     CDR ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     CAR ;
                     CDR ;
                     DUP 3 ;
                     CAR ;
                     CAR ;
                     CDR ;
                     PUSH nat 0 ;
                     DIG 7 ;
                     COMPARE ;
                     EQ ;
                     IF { DIG 4 ; DROP ; DIG 4 } { DIG 5 ; DROP ; DIG 4 } ;
                     DIG 4 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CAR ;
                     PAIR ;
                     PAIR ;
                     PAIR ;
                     PAIR ;
                     NIL operation ;
                     PAIR } }
               { IF_LEFT
                   { DROP ;
                     NOW ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CDR ;
                     NOW ;
                     SUB ;
                     ABS ;
                     PUSH nat 1 ;
                     PUSH nat 604800 ;
                     DIG 2 ;
                     EDIV ;
                     IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                     CAR ;
                     ADD ;
                     DROP ;
                     PUSH string
                          "Only the contract admin can change the contract administrator or increase reward" ;
                     DUP 3 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CAR ;
                     SENDER ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     PUSH string "You must not send Tezos to the smart contract" ;
                     PUSH mutez 0 ;
                     AMOUNT ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     PUSH string "There are no more weeks left for staking" ;
                     PUSH nat 604800 ;
                     INT ;
                     DUP 4 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CDR ;
                     ADD ;
                     DUP 3 ;
                     COMPARE ;
                     LT ;
                     IF { DROP } { FAILWITH } ;
                     PUSH string "The contract is already initialized" ;
                     PUSH nat 0 ;
                     DUP 4 ;
                     CAR ;
                     CDR ;
                     CDR ;
                     CAR ;
                     SIZE ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     CDR ;
                     CAR ;
                     CDR ;
                     DUP 3 ;
                     CAR ;
                     CDR ;
                     CAR ;
                     CAR ;
                     NIL nat ;
                     DUP 3 ;
                     PAIR ;
                     LEFT (list nat) ;
                     LOOP_LEFT
                       { UNPAIR ;
                         PUSH nat 0 ;
                         SWAP ;
                         DUP ;
                         DUG 2 ;
                         COMPARE ;
                         EQ ;
                         IF { DROP ; RIGHT (pair nat (list nat)) }
                            { SWAP ;
                              PUSH nat 1 ;
                              DUP 3 ;
                              SUB ;
                              ABS ;
                              DUP ;
                              DUP 5 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              SWAP ;
                              DUP ;
                              DUG 2 ;
                              PUSH nat 10000 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              DUP 6 ;
                              PUSH nat 10000 ;
                              SUB ;
                              ABS ;
                              DIG 3 ;
                              PUSH nat 10000 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              SWAP ;
                              MUL ;
                              DUP 7 ;
                              DUP 7 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              DUP 8 ;
                              PUSH nat 10000 ;
                              PUSH nat 1 ;
                              PAIR ;
                              PAIR ;
                              LEFT nat ;
                              LOOP_LEFT
                                { UNPAIR ;
                                  UNPAIR ;
                                  PUSH nat 0 ;
                                  DUP 4 ;
                                  COMPARE ;
                                  EQ ;
                                  IF { SWAP ; DIG 2 ; DROP 2 ; RIGHT (pair (pair nat nat) nat) }
                                     { PUSH nat 1 ;
                                       DIG 3 ;
                                       SUB ;
                                       ABS ;
                                       DIG 2 ;
                                       DUP ;
                                       DIG 3 ;
                                       MUL ;
                                       PAIR ;
                                       PAIR ;
                                       LEFT nat } } ;
                              SUB ;
                              ABS ;
                              DIG 2 ;
                              MUL ;
                              DIG 2 ;
                              DUP 9 ;
                              CDR ;
                              CAR ;
                              CAR ;
                              DIG 3 ;
                              MUL ;
                              MUL ;
                              EDIV ;
                              IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                              CAR ;
                              CONS ;
                              PUSH nat 1 ;
                              DIG 2 ;
                              SUB ;
                              ABS ;
                              PAIR ;
                              LEFT (list nat) } } ;
                     SWAP ;
                     DIG 2 ;
                     DROP 2 ;
                     DUP 3 ;
                     CDR ;
                     DUP 4 ;
                     CAR ;
                     CDR ;
                     CDR ;
                     CDR ;
                     DIG 2 ;
                     PAIR ;
                     DUP 4 ;
                     CAR ;
                     CDR ;
                     CAR ;
                     PAIR ;
                     DIG 3 ;
                     CAR ;
                     CAR ;
                     PAIR ;
                     PAIR ;
                     DUP ;
                     CDR ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     CAR ;
                     CDR ;
                     DUP 3 ;
                     CAR ;
                     CAR ;
                     CDR ;
                     DIG 4 ;
                     DIG 4 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CAR ;
                     PAIR ;
                     PAIR ;
                     PAIR ;
                     PAIR ;
                     NIL operation ;
                     PAIR }
                   { PUSH string
                          "Only the contract admin can change the contract administrator or increase reward" ;
                     DUP 3 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CAR ;
                     SENDER ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     PUSH string "You must not send Tezos to the smart contract" ;
                     PUSH mutez 0 ;
                     AMOUNT ;
                     COMPARE ;
                     EQ ;
                     IF { DROP } { FAILWITH } ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     CDR ;
                     DUP 3 ;
                     CAR ;
                     CDR ;
                     DUP 4 ;
                     CAR ;
                     CAR ;
                     CDR ;
                     DIG 4 ;
                     CAR ;
                     CAR ;
                     CAR ;
                     CDR ;
                     DIG 4 ;
                     PAIR ;
                     PAIR ;
                     PAIR ;
                     PAIR ;
                     NIL operation ;
                     PAIR } } }
           { IF_LEFT
               { NOW ;
                 SENDER ;
                 DUP 4 ;
                 CAR ;
                 CAR ;
                 CDR ;
                 CAR ;
                 DUP 5 ;
                 CDR ;
                 CDR ;
                 CAR ;
                 DUP 6 ;
                 CAR ;
                 CAR ;
                 CDR ;
                 CDR ;
                 CONTRACT
                   (or (or (or (pair %approve (address %spender) (nat %value))
                               (pair %getAllowance
                                  (pair %request (address %owner) (address %spender))
                                  (contract %callback nat)))
                           (or (pair %getBalance (address %owner) (contract %callback nat))
                               (pair %getTotalSupply (unit %request) (contract %callback nat))))
                       (or (pair %mintOrBurn (int %quantity) (address %target))
                           (pair %transfer (address %from) (pair (address %to) (nat %value))))) ;
                 IF_NONE
                   { PUSH string "This farm works with a different LP token" ; FAILWITH }
                   {} ;
                 DUP 7 ;
                 CAR ;
                 CAR ;
                 CAR ;
                 CDR ;
                 NOW ;
                 SUB ;
                 ABS ;
                 PUSH nat 1 ;
                 PUSH nat 604800 ;
                 DIG 2 ;
                 EDIV ;
                 IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                 CAR ;
                 ADD ;
                 PUSH nat 604800 ;
                 SWAP ;
                 DUP ;
                 DUG 2 ;
                 MUL ;
                 INT ;
                 DUP 9 ;
                 CAR ;
                 CAR ;
                 CAR ;
                 CDR ;
                 ADD ;
                 PUSH string "You must not send Tezos to the smart contract" ;
                 PUSH mutez 0 ;
                 AMOUNT ;
                 COMPARE ;
                 EQ ;
                 IF { DROP } { FAILWITH } ;
                 PUSH string "The staking amount must be greater than zero" ;
                 PUSH nat 0 ;
                 DUP 10 ;
                 COMPARE ;
                 GT ;
                 IF { DROP } { FAILWITH } ;
                 PUSH string "There are no more weeks left for staking" ;
                 PUSH nat 604800 ;
                 DUP 11 ;
                 CDR ;
                 CAR ;
                 CDR ;
                 MUL ;
                 INT ;
                 DUP 11 ;
                 CAR ;
                 CAR ;
                 CAR ;
                 CDR ;
                 ADD ;
                 DUP 9 ;
                 COMPARE ;
                 LT ;
                 IF { DROP } { FAILWITH } ;
                 PUSH string "Please try again in few seconds" ;
                 PUSH int 0 ;
                 DUP 3 ;
                 DUP 10 ;
                 SUB ;
                 COMPARE ;
                 LT ;
                 IF { DROP } { FAILWITH } ;
                 DUP 6 ;
                 SELF_ADDRESS ;
                 DUP 10 ;
                 SWAP ;
                 PAIR ;
                 SWAP ;
                 PAIR ;
                 DIG 3 ;
                 PUSH mutez 0 ;
                 DIG 2 ;
                 RIGHT (pair int address) ;
                 RIGHT
                   (or (or (pair address nat) (pair (pair address address) (contract nat)))
                       (or (pair address (contract nat)) (pair unit (contract nat)))) ;
                 TRANSFER_TOKENS ;
                 DUP 9 ;
                 CDR ;
                 CDR ;
                 CDR ;
                 DUP 7 ;
                 GET ;
                 IF_NONE
                   { DUP 9 ; CDR ; CDR ; CDR ; DUP 9 ; DUP 8 ; SWAP ; SOME ; SWAP ; UPDATE }
                   { DUP 10 ; CDR ; CDR ; CDR ; SWAP ; DUP 10 ; ADD ; SOME ; DUP 8 ; UPDATE } ;
                 DIG 2 ;
                 DIG 7 ;
                 SUB ;
                 ABS ;
                 DUP 8 ;
                 SWAP ;
                 MUL ;
                 DIG 7 ;
                 PUSH nat 604800 ;
                 MUL ;
                 NIL nat ;
                 DUP 10 ;
                 CDR ;
                 CAR ;
                 CDR ;
                 PAIR ;
                 LEFT (list nat) ;
                 LOOP_LEFT
                   { UNPAIR ;
                     PUSH nat 0 ;
                     SWAP ;
                     DUP ;
                     DUG 2 ;
                     COMPARE ;
                     EQ ;
                     IF { DROP ; RIGHT (pair nat (list nat)) }
                        { SWAP ;
                          DUP 7 ;
                          DUP 3 ;
                          COMPARE ;
                          LT ;
                          IF { PUSH nat 0 }
                             { DUP 7 ; DUP 3 ; COMPARE ; EQ ; IF { DUP 4 } { DUP 3 } } ;
                          CONS ;
                          PUSH nat 1 ;
                          DIG 2 ;
                          SUB ;
                          ABS ;
                          PAIR ;
                          LEFT (list nat) } } ;
                 SWAP ;
                 DIG 2 ;
                 DIG 5 ;
                 DROP 3 ;
                 DUP 6 ;
                 DUP 5 ;
                 SWAP ;
                 GET ;
                 IF_NONE
                   { DUP }
                   { NIL nat ;
                     NIL nat ;
                     DUP 4 ;
                     DIG 3 ;
                     PAIR ;
                     PAIR ;
                     LEFT (list nat) ;
                     LOOP_LEFT
                       { UNPAIR ;
                         UNPAIR ;
                         IF_CONS
                           { DIG 2 ;
                             IF_CONS
                               { PUSH bool True ;
                                 PUSH bool True ;
                                 COMPARE ;
                                 EQ ;
                                 IF { DIG 2 ; ADD } { DIG 2 ; SUB ; ABS } ;
                                 DIG 3 ;
                                 SWAP ;
                                 CONS ;
                                 SWAP ;
                                 DIG 2 ;
                                 PAIR ;
                                 PAIR ;
                                 LEFT (list nat) }
                               { DROP 3 ; PUSH string "size don't match" ; FAILWITH } }
                           { IF_CONS
                               { DROP 3 ; PUSH string "size don't match" ; FAILWITH }
                               { RIGHT (pair (pair (list nat) (list nat)) (list nat)) } } } ;
                     PAIR ;
                     LEFT (list nat) ;
                     LOOP_LEFT
                       { UNPAIR ;
                         IF_CONS
                           { DIG 2 ; SWAP ; CONS ; SWAP ; PAIR ; LEFT (list nat) }
                           { RIGHT (pair (list nat) (list nat)) } } } ;
                 PUSH nat 0 ;
                 DUP 7 ;
                 SIZE ;
                 COMPARE ;
                 EQ ;
                 IF { SWAP ; DIG 5 ; DROP 2 ; DUP }
                    { NIL nat ;
                      NIL nat ;
                      DIG 3 ;
                      DIG 7 ;
                      PAIR ;
                      PAIR ;
                      LEFT (list nat) ;
                      LOOP_LEFT
                        { UNPAIR ;
                          UNPAIR ;
                          IF_CONS
                            { DIG 2 ;
                              IF_CONS
                                { PUSH bool True ;
                                  PUSH bool True ;
                                  COMPARE ;
                                  EQ ;
                                  IF { DIG 2 ; ADD } { DIG 2 ; SUB ; ABS } ;
                                  DIG 3 ;
                                  SWAP ;
                                  CONS ;
                                  SWAP ;
                                  DIG 2 ;
                                  PAIR ;
                                  PAIR ;
                                  LEFT (list nat) }
                                { DROP 3 ; PUSH string "size don't match" ; FAILWITH } }
                            { IF_CONS
                                { DROP 3 ; PUSH string "size don't match" ; FAILWITH }
                                { RIGHT (pair (pair (list nat) (list nat)) (list nat)) } } } ;
                      PAIR ;
                      LEFT (list nat) ;
                      LOOP_LEFT
                        { UNPAIR ;
                          IF_CONS
                            { DIG 2 ; SWAP ; CONS ; SWAP ; PAIR ; LEFT (list nat) }
                            { RIGHT (pair (list nat) (list nat)) } } } ;
                 DIG 2 ;
                 DUP 7 ;
                 CDR ;
                 CDR ;
                 CAR ;
                 PAIR ;
                 DUP 7 ;
                 CDR ;
                 CAR ;
                 PAIR ;
                 DIG 6 ;
                 CAR ;
                 PAIR ;
                 DUP ;
                 CDR ;
                 CDR ;
                 CDR ;
                 DIG 5 ;
                 DIG 4 ;
                 SOME ;
                 DIG 6 ;
                 UPDATE ;
                 PAIR ;
                 SWAP ;
                 DUP ;
                 DUG 2 ;
                 CDR ;
                 CAR ;
                 PAIR ;
                 SWAP ;
                 CAR ;
                 PAIR ;
                 DUP ;
                 CDR ;
                 SWAP ;
                 DUP ;
                 DUG 2 ;
                 CAR ;
                 CDR ;
                 DUP 3 ;
                 CAR ;
                 CAR ;
                 CDR ;
                 CDR ;
                 DIG 4 ;
                 PAIR ;
                 DIG 3 ;
                 CAR ;
                 CAR ;
                 CAR ;
                 PAIR ;
                 PAIR ;
                 PAIR ;
                 NIL operation ;
                 DIG 2 ;
                 CONS ;
                 PAIR }
               { NOW ;
                 DUP 3 ;
                 CAR ;
                 CAR ;
                 CAR ;
                 CDR ;
                 NOW ;
                 SUB ;
                 ABS ;
                 PUSH nat 1 ;
                 PUSH nat 604800 ;
                 DIG 2 ;
                 EDIV ;
                 IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                 CAR ;
                 ADD ;
                 DUP 4 ;
                 CDR ;
                 CDR ;
                 CAR ;
                 PUSH string "You must not send Tezos to the smart contract" ;
                 PUSH mutez 0 ;
                 AMOUNT ;
                 COMPARE ;
                 EQ ;
                 IF { DROP } { FAILWITH } ;
                 SENDER ;
                 PUSH nat 604800 ;
                 DUP 4 ;
                 MUL ;
                 INT ;
                 DUP 7 ;
                 CAR ;
                 CAR ;
                 CAR ;
                 CDR ;
                 ADD ;
                 DUP 7 ;
                 CDR ;
                 CDR ;
                 CDR ;
                 DUP 3 ;
                 GET ;
                 IF_NONE { PUSH string "You did not stake any token yet" ; FAILWITH } {} ;
                 PUSH string "You cannot unstake more than your staking" ;
                 DUP 8 ;
                 DUP 3 ;
                 COMPARE ;
                 GE ;
                 IF { DROP } { FAILWITH } ;
                 DUP 8 ;
                 CDR ;
                 CDR ;
                 CDR ;
                 DUP 8 ;
                 DIG 2 ;
                 SUB ;
                 ABS ;
                 SOME ;
                 DUP 4 ;
                 UPDATE ;
                 DUP 8 ;
                 CAR ;
                 CAR ;
                 CDR ;
                 CDR ;
                 CONTRACT
                   (or (or (or (pair %approve (address %spender) (nat %value))
                               (pair %getAllowance
                                  (pair %request (address %owner) (address %spender))
                                  (contract %callback nat)))
                           (or (pair %getBalance (address %owner) (contract %callback nat))
                               (pair %getTotalSupply (unit %request) (contract %callback nat))))
                       (or (pair %mintOrBurn (int %quantity) (address %target))
                           (pair %transfer (address %from) (pair (address %to) (nat %value))))) ;
                 IF_NONE
                   { PUSH string "This farm works with a different LP token" ; FAILWITH }
                   {} ;
                 SELF_ADDRESS ;
                 DUP 5 ;
                 DUP 10 ;
                 SWAP ;
                 PAIR ;
                 SWAP ;
                 PAIR ;
                 SWAP ;
                 PUSH mutez 0 ;
                 DIG 2 ;
                 RIGHT (pair int address) ;
                 RIGHT
                   (or (or (pair address nat) (pair (pair address address) (contract nat)))
                       (or (pair address (contract nat)) (pair unit (contract nat)))) ;
                 TRANSFER_TOKENS ;
                 NIL operation ;
                 SWAP ;
                 CONS ;
                 DUP 3 ;
                 DUP 8 ;
                 COMPARE ;
                 LT ;
                 IF { DIG 2 ;
                      DIG 6 ;
                      SUB ;
                      ABS ;
                      DUP 7 ;
                      SWAP ;
                      MUL ;
                      DIG 6 ;
                      PUSH nat 604800 ;
                      MUL ;
                      NIL nat ;
                      DUP 9 ;
                      CDR ;
                      CAR ;
                      CDR ;
                      PAIR ;
                      LEFT (list nat) ;
                      LOOP_LEFT
                        { UNPAIR ;
                          PUSH nat 0 ;
                          SWAP ;
                          DUP ;
                          DUG 2 ;
                          COMPARE ;
                          EQ ;
                          IF { DROP ; RIGHT (pair nat (list nat)) }
                             { SWAP ;
                               DUP 9 ;
                               DUP 3 ;
                               COMPARE ;
                               LT ;
                               IF { PUSH nat 0 }
                                  { DUP 9 ; DUP 3 ; COMPARE ; EQ ; IF { DUP 4 } { DUP 3 } } ;
                               CONS ;
                               PUSH nat 1 ;
                               DIG 2 ;
                               SUB ;
                               ABS ;
                               PAIR ;
                               LEFT (list nat) } } ;
                      SWAP ;
                      DIG 2 ;
                      DIG 7 ;
                      DROP 3 ;
                      DUP 4 ;
                      DUP 6 ;
                      SWAP ;
                      GET ;
                      IF_NONE
                        { PUSH string "Some points should exist" ; FAILWITH }
                        { NIL nat ;
                          NIL nat ;
                          DUP 4 ;
                          DIG 3 ;
                          PAIR ;
                          PAIR ;
                          LEFT (list nat) ;
                          LOOP_LEFT
                            { UNPAIR ;
                              UNPAIR ;
                              IF_CONS
                                { DIG 2 ;
                                  IF_CONS
                                    { PUSH bool True ;
                                      PUSH bool False ;
                                      COMPARE ;
                                      EQ ;
                                      IF { DIG 2 ; ADD } { DIG 2 ; SUB ; ABS } ;
                                      DIG 3 ;
                                      SWAP ;
                                      CONS ;
                                      SWAP ;
                                      DIG 2 ;
                                      PAIR ;
                                      PAIR ;
                                      LEFT (list nat) }
                                    { DROP 3 ; PUSH string "size don't match" ; FAILWITH } }
                                { IF_CONS
                                    { DROP 3 ; PUSH string "size don't match" ; FAILWITH }
                                    { RIGHT (pair (pair (list nat) (list nat)) (list nat)) } } } ;
                          PAIR ;
                          LEFT (list nat) ;
                          LOOP_LEFT
                            { UNPAIR ;
                              IF_CONS
                                { DIG 2 ; SWAP ; CONS ; SWAP ; PAIR ; LEFT (list nat) }
                                { RIGHT (pair (list nat) (list nat)) } } } ;
                      NIL nat ;
                      NIL nat ;
                      DIG 3 ;
                      DUP 9 ;
                      CAR ;
                      CAR ;
                      CDR ;
                      CAR ;
                      PAIR ;
                      PAIR ;
                      LEFT (list nat) ;
                      LOOP_LEFT
                        { UNPAIR ;
                          UNPAIR ;
                          IF_CONS
                            { DIG 2 ;
                              IF_CONS
                                { PUSH bool True ;
                                  PUSH bool False ;
                                  COMPARE ;
                                  EQ ;
                                  IF { DIG 2 ; ADD } { DIG 2 ; SUB ; ABS } ;
                                  DIG 3 ;
                                  SWAP ;
                                  CONS ;
                                  SWAP ;
                                  DIG 2 ;
                                  PAIR ;
                                  PAIR ;
                                  LEFT (list nat) }
                                { DROP 3 ; PUSH string "size don't match" ; FAILWITH } }
                            { IF_CONS
                                { DROP 3 ; PUSH string "size don't match" ; FAILWITH }
                                { RIGHT (pair (pair (list nat) (list nat)) (list nat)) } } } ;
                      PAIR ;
                      LEFT (list nat) ;
                      LOOP_LEFT
                        { UNPAIR ;
                          IF_CONS
                            { DIG 2 ; SWAP ; CONS ; SWAP ; PAIR ; LEFT (list nat) }
                            { RIGHT (pair (list nat) (list nat)) } } ;
                      DIG 3 ;
                      DUP 7 ;
                      CDR ;
                      CDR ;
                      CAR ;
                      PAIR ;
                      DUP 7 ;
                      CDR ;
                      CAR ;
                      PAIR ;
                      DIG 6 ;
                      CAR ;
                      PAIR ;
                      DUP ;
                      CDR ;
                      CDR ;
                      CDR ;
                      DIG 6 ;
                      DIG 4 ;
                      SOME ;
                      DIG 6 ;
                      UPDATE ;
                      PAIR ;
                      SWAP ;
                      DUP ;
                      DUG 2 ;
                      CDR ;
                      CAR ;
                      PAIR ;
                      SWAP ;
                      CAR ;
                      PAIR ;
                      DUP ;
                      CDR ;
                      SWAP ;
                      DUP ;
                      DUG 2 ;
                      CAR ;
                      CDR ;
                      DUP 3 ;
                      CAR ;
                      CAR ;
                      CDR ;
                      CDR ;
                      DIG 4 ;
                      PAIR ;
                      DIG 3 ;
                      CAR ;
                      CAR ;
                      CAR ;
                      PAIR ;
                      PAIR ;
                      PAIR ;
                      SWAP ;
                      PAIR }
                    { DIG 2 ;
                      DIG 3 ;
                      DIG 4 ;
                      DIG 5 ;
                      DIG 6 ;
                      DIG 7 ;
                      DROP 6 ;
                      SWAP ;
                      DUP 3 ;
                      CDR ;
                      CDR ;
                      CAR ;
                      PAIR ;
                      DUP 3 ;
                      CDR ;
                      CAR ;
                      PAIR ;
                      DIG 2 ;
                      CAR ;
                      PAIR ;
                      SWAP ;
                      PAIR } } } } }
