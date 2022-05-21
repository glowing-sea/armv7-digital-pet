.syntax unified
.global milliseconds_count, seconds_count, seconds_count_reset, ten_seconds_count, dog_record
.global get_friendship, inc_friendship, dec_friendship, set_friendship
.global get_hunger, inc_hunger, dec_hunger, set_hunger
.global get_state, set_state
.global get_turns, inc_turns, reset_turns
.global get_success_times, inc_success_times, reset_success_times
.global set_succeed, get_succeed

.data
@ reset every second
milliseconds_count:
.word 0

@ reset every 10 seconds
seconds_count:
.word 0

seconds_count_reset:
.word 0

ten_seconds_count:
.word 0

dog_record:
.word 2 @ friendship level
.word 5 @ hunger level
.word 0 @ current state
.word 0 @ whether has succeed once

game:
.word 0 @ turn
.word 0 @ success_times

@ State
@ 0 idel
@ 1 playing pending
@ 2 playing
@ 3 playing button enable
@ 4 eating
@ 5 failed state


@ ================================= GETTER AND SETTER FUNCTIONS =============================== 


@ return friendship in r0
@ .type get_friendship, %function
@ get_friendship:
@   ldr r1, =dog_record
@   ldr r0, [r1]
@   bx lr
@ .size get_friendship, . - get_friendship


.type get_friendship, %function
get_friendship:
  ldr r1, =dog_record
  ldr r0, [r1]
  bx lr
.size get_friendship, . - get_friendship


@ increase friendship by 1
.type inc_friendship, %function
inc_friendship:
  ldr r1, =dog_record
  ldr r0, [r1]
  cmp r0, 5
  beq not_inc_friendship
  add r0, 1
  not_inc_friendship:
  str r0, [r1]
  bx lr
.size inc_friendship, . - inc_friendship

@ decrease friendship by 1
.type dec_friendship, %function
dec_friendship:
  ldr r1, =dog_record
  ldr r0, [r1] 
  cmp r0, 0
  beq not_dec_friendship
  sub r0, 1
  not_dec_friendship:
  str r0, [r1]
  bx lr
.size dec_friendship, . - dec_friendship


@ set friendship by reading the value in r0
.type set_friendship, %function
set_friendship:
  ldr r1, =dog_record
  str r0, [r1]
  bx lr
.size set_friendship, . - set_friendship




@ return hunger level in r0
.type get_hunger, %function
get_hunger:
  ldr r1, =dog_record
  ldr r0, [r1, 4]
  bx lr
.size get_hunger, . - get_hunger

@ increase hunger level by 1
.type inc_hunger, %function
inc_hunger:
  ldr r1, =dog_record
  ldr r0, [r1, 4]
  cmp r0, 5
  beq not_inc_hunder
  add r0, 1
  not_inc_hunder:
  str r0, [r1, 4]
  bx lr
.size inc_hunger, . - inc_hunger



@ decrease hunger level by 1
.type dec_hunger, %function
dec_hunger:
  ldr r1, =dog_record
  ldr r0, [r1, 4]
  cmp r0, 0
  beq not_dec_hunder
  sub r0, 1
  not_dec_hunder:
  str r0, [r1, 4]
  bx lr
.size dec_hunger, . - dec_hunger


@ set friendship by reading the value in r0
.type set_hunger, %function
set_hunger:
  ldr r1, =dog_record
  str r0, [r1, 4]
  bx lr
.size set_hunger, . - set_hunger


.type get_state, %function
get_state:
  ldr r1, =dog_record
  ldr r0, [r1, 8]
  bx lr
.size get_state, . - get_state


.type set_state, %function
set_state:
  ldr r1, =dog_record
  str r0, [r1, 8]
  bx lr
.size set_state, . - set_state



@ return turn times in r0
.type get_turns, %function
get_turns:
  ldr r1, =game
  ldr r0, [r1]
  bx lr
.size get_turns, . - get_turns


@ increase playing success times by 1
.type inc_turns, %function
inc_turns:
  ldr r1, =game
  ldr r0, [r1]
  add r0, 1
  str r0, [r1]
  bx lr
.size inc_turns, . - inc_turns



@ reset playing success times to 0
.type reset_turns, %function
reset_turns:
  ldr r1, =game
  mov r0, 0
  str r0, [r1]
  bx lr
.size reset_turns, . - reset_turns


@ return playing success times in r0
.type get_success_times, %function
get_success_times:
  ldr r1, =game
  ldr r0, [r1, 4]
  bx lr
.size get_success_times, . - get_success_times


@ increase playing success times by 1
.type inc_success_times, %function
inc_success_times:
  ldr r1, =game
  ldr r0, [r1, 4]
  add r0, 1
  str r0, [r1, 4]
  bx lr
.size inc_success_times, . - inc_success_times


@ reset playing success times to 0
.type reset_success_times, %function
reset_success_times:
  ldr r1, =game
  mov r0, 0
  str r0, [r1, 4]
  bx lr
.size reset_success_times, . - reset_success_times



.type set_succeed, %function
set_succeed:
  ldr r1, =dog_record
  mov r0, 1
  str r0, [r1, 12]
  bx lr
.size set_succeed, . - set_succeed


.type get_succeed, %function
get_succeed:
  ldr r1, =dog_record
  ldr r0, [r1, 12]
  bx lr
.size get_succeed, . - get_succeed
