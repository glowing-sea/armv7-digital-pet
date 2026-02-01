.syntax unified
.global idle, playing_pending_state, playing_state, eating_state

.global SMILE_FACE
.set SMILE_FACE, 0b00000010100000010001011101000111

@ ========================== idle STATE ACTIONS =========================== @

.type idle, %function
idle:
  push {r4, lr}

  bl get_friendship
  cmp r0, 2
  blt angry

  smile:
    bl one_tenth
    cmp r0, 0
    beq start_blinking_eyes
    ldr r0, =0b00000010100000010001011101000111
    bl display
    b end_of_idle

    start_blinking_eyes:
    ldr r1, =0b00000000000000010001011101000001
    ldr r2, =0b00000010100000010001011101000001
    mov r3, 2
    bl twinkling
    b end_of_idle

  angry:
    bl one_tenth
    cmp r0, 0
    beq start_blinking_eyes_2
    ldr r0, =0b00000010100000001110100011000111
    bl display
    b end_of_idle

    start_blinking_eyes_2:
    ldr r1, =0b00000000000000001110100011000001
    ldr r2, =0b00000010100000001110100011000001
    mov r3, 2
    bl twinkling

  end_of_idle:
  pop {r4, lr}
  bx lr
.size idle, . - idle


@ ========================== PLAYING PENDING STATE ACTIONS =========================== @

.type playing_pending_state, %function
playing_pending_state:
  push {r4, lr}

  mov r4, 10
  while_playing_pending:
    cmp r4, 0
    beq end_of_playing_pending_loop
    ldr r0, =0b00010111111001010010000001100010
    bl display
    ldr r0, =0b00000000101111110010100101000010
    bl display
    @ check if the state has changed, i.e the user has confirmed a play
    bl get_state
    cmp r0, 2
    beq end_of_playing_pending
    sub r4, 1
    b while_playing_pending
  end_of_playing_pending_loop:


  @ sad face
  ldr r0, =0b00000010100000001110100011100010
  bl display
  ldr r0, =0b00000010100000001110100011011010
  bl display
  ldr r0, =0b00000010100000001110100011010010
  bl display
  ldr r0, =0b00000010100000001110100010000111
  bl display

  bl dec_friendship
  mov r0, 0
  bl set_state

  end_of_playing_pending:

  pop {r4, lr}
  bx lr
.size playing_pending_state, . - playing_pending_state


@ ========================== PLAYING STATE ACTIONS =========================== @

.type playing_stste, %function
playing_state:
  push {r4, lr}

  ldr r1, =0b00000000101111110010100100000010
  ldr r2, =0b00000000101111110010100101001010
  mov r3, 3
  bl twinkling

  ldr r0, =0b00000000101111110010100100000010
  bl display
  ldr r0, =0b00000000101111110010100101100010
  bl display
  ldr r0, =0b00000000101111110010100100000010
  bl display



  new_game_turn_start:

  bl get_turns
  mov r4, r0 @ make a copy of turn number in r4
  cmp r0, 5
  beq game_end


  ldr r0, =0b00000000000000000000000001010001
  bl display
  ldr r0, =0b00000000000000000000000001000001
  bl display
  ldr r0, =0b00000000001000000000000001010001
  bl display
  ldr r0, =0b00000000001000000000000001000001
  bl display
  ldr r0, =0b00000100001100010000100001010001
  bl display
  ldr r0, =0b00000100001100010000100001000001
  bl display
  ldr r0, =0b00000010001110001000010001010001
  bl display
  ldr r0, =0b00000010001110001000010001000001
  bl display
  ldr r0, =0b00000001001111000100001001010001
  bl display
  ldr r0, =0b00000001001111000100001001000001
  bl display

  @ enable button
  mov r0, 3
  bl set_state

  ldr r0, =0b00000000101111110010100101010001
  bl display
  ldr r0, =0b00000000101111110010100101000001
  bl display

  @ diable button
  mov r0, 2
  bl set_state

  @ check if this turn has succeed, If so next turn
  bl get_turns
  cmp r0, r4
  bgt new_game_turn_start


  ldr r0, =0b00000000010111101001010011010001
  bl display
  ldr r0, =0b00000000010111101001010011000001
  bl display
  ldr r0, =0b00000000000011100100001001010001
  bl display
  ldr r0, =0b00000000000011100100001001000001
  bl display
  ldr r0, =0b00000000000001100010000101010001
  bl display
  ldr r0, =0b00000000000001100010000101000001
  bl display
  ldr r0, =0b00000000000000100001000011010001
  bl display
  ldr r0, =0b00000000000000100001000011000001
  bl display
  ldr r0, =0b00000000000000000000000001010001
  bl display
  ldr r0, =0b00000000000000000000000001000001
  bl display

  @ sad face
  ldr r0, =0b00000010100000001110100011001100
  bl display
  ldr r0, =0b00000010100000001110100010000100
  bl display

  bl inc_turns
  b new_game_turn_start

  game_end:

  @ calculate score
  bl get_success_times
  cmp r0, 3
  bge success_animation

  @ Fail animation
    ldr r0, =0b00000010100000001110100011100010
    bl display
    ldr r0, =0b00000010100000001110100011011010
    bl display
    ldr r0, =0b00000010100000001110100011010010
    bl display
    ldr r0, =0b00000010100000001110100010000111
    bl display
    bl dec_friendship

  b animation_end

  success_animation:

    ldr r0, =0b00000010100000010001011101010010
    bl display
    ldr r0, =0b00000010100000010001011101011010
    bl display
    ldr r0, =0b00000010100000010001011101100010
    bl display
    ldr r0, =0b00000010100000010001011101000010
    bl display
    bl inc_friendship


  animation_end:

  @ reset turns and success times for the next play
  bl reset_success_times
  bl reset_turns

  @ back to idle state
  mov r0, 0
  bl set_state

  pop {r4, lr}
  bx lr
.size playing_state, . - playing_state


@ ========================== EATING STATE ACTIONS =========================== @

@ Actions of dog when it is in eating state
.type eating_state, %function
eating_state:
  push {lr}
  ldr r0, =0b00001000000000000000000001010001
  bl display
  ldr r0, =0b00001000000000000000000001000001
  bl display
  ldr r0, =0b00000000010000000000000001010001
  bl display
  ldr r0, =0b00000000010000000000000001000001
  bl display
  ldr r0, =0b00000000000000100000000001010001
  bl display
  ldr r0, =0b00000000000000100000000001000001
  bl display
  ldr r0, =0b00000000001000100000000001010001
  bl display
  ldr r0, =0b00000000001000100000000001000001
  bl display
  ldr r0, =0b00000100001100110000100001010001
  bl display
  ldr r0, =0b00000100001100110000100001000001
  bl display
  ldr r0, =0b00000010001110101000010001010001
  bl display
  ldr r0, =0b00000010001110101000010001000001
  bl display
  ldr r0, =0b00000001001111100100001001010001
  bl display
  ldr r0, =0b00000001001111100100001001000001
  bl display
  ldr r0, =0b00000000101111110010100101010001
  bl display
  ldr r0, =0b00000000101111110010100101000001
  bl display

  bl get_hunger
  cmp r0, 5
  beq already_full

  @ Start eating
    ldr r0, =0b00000010100000010001011101010010
    bl display
    ldr r0, =0b00000010100000010001011101011010
    bl display
    ldr r0, =0b00000010100000010001011101100010
    bl display
    ldr r0, =0b00000010100000010001011101000010
    bl display
    mov r0, 5
    bl set_hunger @ set hunger level back to 5
    b end_of_eating

  @ If it is already full, decrease one friendship
  already_full:
    @ sad face
    ldr r0, =0b00000010100000001110100011100010
    bl display
    ldr r0, =0b00000010100000001110100011011010
    bl display
    ldr r0, =0b00000010100000001110100011010010
    bl display
    ldr r0, =0b00000010100000001110100010000111
    bl display
    bl dec_friendship


  end_of_eating:
  mov r0, 0
  bl set_state @ back to idle state

  pop {lr}
  bx lr
.size eating_state, . - eating_state