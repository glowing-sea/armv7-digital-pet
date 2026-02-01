.syntax unified
.global tests

@ if test succeeds, return r0 = 100

.type tests, %function
tests:
    mov r0, 0 @ set friendship to 0
    bl set_friendship
    bl inc_friendship
    bl inc_friendship
    bl inc_friendship
    bl inc_friendship
    bl inc_friendship
    bl get_friendship
    @ expect 5
    cmp r0, 5
    bne test_fail

    bl inc_friendship
    bl inc_friendship
    bl get_friendship
    @ expect 5
    cmp r0, 5
    bne test_fail
    
    bl dec_friendship
    bl dec_friendship
    bl dec_friendship
    bl dec_friendship
    bl dec_friendship
    bl get_friendship

    @ expect 0
    cmp r0, 0
    bne test_fail
    bl dec_friendship
    bl dec_friendship
    bl get_friendship

    @ expect 0
    cmp r0, 0
    bne test_fail




    mov r0, 0 @ set
    bl set_hunger
    bl inc_hunger
    bl inc_hunger
    bl inc_hunger
    bl inc_hunger
    bl inc_hunger
    bl get_hunger
    @ expect 5
    cmp r0, 5
    bne test_fail

    bl inc_hunger
    bl inc_hunger
    bl get_hunger
    @ expect 5
    cmp r0, 5
    bne test_fail
    
    bl dec_hunger
    bl dec_hunger
    bl dec_hunger
    bl dec_hunger
    bl dec_hunger
    bl get_hunger

    @ expect 0
    cmp r0, 0
    bne test_fail
    bl dec_hunger
    bl dec_hunger
    bl get_hunger

    @ expect 0
    cmp r0, 0
    bne test_fail

    mov r0, 100
    bl set_state
    bl get_state
    cmp r0, 100
    bne test_fail



    mov r0, 6
    mov r1, 5
    bl modulus
    cmp r0, 1
    bne test_fail

    mov r0, 6
    mov r1, 2
    bl modulus
    cmp r0, 0
    bne test_fail



    bl inc_turns
    bl inc_turns
    bl inc_turns
    bl get_turns
    cmp r0, 3
    bne test_fail
    bl reset_turns
    bl get_turns
    cmp r0, 0
    bne test_fail


    bl inc_success_times
    bl inc_success_times
    bl inc_success_times
    bl get_success_times
    cmp r0, 3
    bne test_fail
    bl reset_success_times
    bl get_success_times
    cmp r0, 0
    bne test_fail


    bl get_succeed
    cmp r0, 0
    bne test_fail
    bl set_succeed
    bl get_succeed
    cmp r0, 1
    bne test_fail






    b test_success



    bx lr
.size tests, . - tests



test_fail:
  nop
  b test_fail


test_success:
  nop
  b test_success