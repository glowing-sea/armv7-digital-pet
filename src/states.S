.syntax unified
.global idel, show_status, idel_button_press_reaction, playing_pending, playing, new_game_turn_start, playing_button_press_reaction, playing, eating_state

.global SMILE_FACE
.set SMILE_FACE, 0b00000010100000010001011101000111


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
  bl set_state @ back to idel state

  pop {lr}
  bx lr
.size eating_state, . - eating_state


.type playing_pending, %function
playing_pending:
  push {r4, lr}

  mov r4, 10
  playing_pending_loop:
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
    b playing_pending_loop
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
.size playing_pending, . - playing_pending


.type playing, %function
playing:
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

  @ back to idel state
  mov r0, 0
  bl set_state

  pop {r4, lr}
  bx lr
.size playing, . - playing




.type idel, %function
idel:
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
    b end_of_idel

    start_blinking_eyes:
    ldr r1, =0b00000000000000010001011101000001
    ldr r2, =0b00000010100000010001011101000001
    mov r3, 2
    bl twinkling
    b end_of_idel

  angry:
    bl one_tenth
    cmp r0, 0
    beq start_blinking_eyes_2
    ldr r0, =0b00000010100000001110100011000111
    bl display
    b end_of_idel

    start_blinking_eyes_2:
    ldr r1, =0b00000000000000001110100011000001
    ldr r2, =0b00000010100000001110100011000001
    mov r3, 2
    bl twinkling


end_of_idel:

  pop {r4, lr}
  bx lr
.size idel, . - idel



@ Show the current status of the dog (friendship and hunger level)
show_status:
  push {r5-r8, lr}

  ldr r8, =dog_record
  ldr r5, =numbers

  ldr r6, [r8] @ friendship index
  ldr r7, [r8, 4] @ hunger index

  @ ldr r5, =numbers
  @ bl get_friendship
  @ mov r6, r0
  @ bl get_hunger
  @ mov r7, r0


  @ check if friendship and hunger is between 1 - 5
  cmp r6, 5
  bgt number_error
  cmp r6, 0
  blt number_error
  cmp r7, 5
  bgt number_error
  cmp r7, 0
  blt number_error

  lsl r6, r6, 2 @ index to offset
  lsl r7, r7, 2 @ index to offset

  ldr r6, [r5, r6] @ load number pixels
  ldr r7, [r5, r7] @ load number pixels

  b skip_number_error
  number_error:
    ldr r6, [r5, 24]
    ldr r7, [r5, 24]
  skip_number_error:

  ldr r0, =0b01110010000111001000010001001011
  bl display
  mov r0, 0x400000
  bl delay

  mov r0, r6
  bl display

  mov r0, 0x400000
  bl delay
  ldr r0, =0b01010010100111001010010101001011
  bl display

  mov r0, 0x400000
  bl delay

  mov r0, r7
  bl display

  pop {r5-r8, lr}
  b end_of_GPIOTE




playing_button_press_reaction:
  ldr r0, =0b00000010100000010001011101100011
  bl display

  mov r0, 0x400000
  bl delay

  bl inc_turns
  bl inc_success_times
  bl get_success_times
  lsl r1, r0, 2 @ index to offset
  ldr r0, =numbers
  ldr r0, [r0, r1]
  bl display

  mov r0, 0x400000
  bl delay

  b end_of_GPIOTE



idel_button_press_reaction:


  @ check if button a or b
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, [r0]
  cmp r1, 1
  beq move_eyes_to_left
  
  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r1, [r0]
  cmp r1, 1
  beq move_eyes_to_right


  ldr r0, =GPIOTE_EVENTS_IN3
  ldr r1, [r0]
  cmp r1, 1
  beq go_to_eating_state


  move_eyes_to_left:
    bl get_friendship
    cmp r0, 2
    blt angry_version_left

      ldr r0, =0b00000101000000010001011101011001
      bl display
      ldr r0, =0b00000101000000010001011101000001
      bl display
      ldr r0, =0b00000101000000010001011101011001
      bl display
      b end_of_GPIOTE

    angry_version_left:
      ldr r0, =0b00000101000000001110100011011001
      bl display
      ldr r0, =0b00000101000000001110100011000001
      bl display
      ldr r0, =0b00000101000000001110100011011001
      bl display
      b end_of_GPIOTE

  move_eyes_to_right:
    bl get_friendship
    cmp r0, 2
    blt angry_version_right
      ldr r0, =0b00000001010000010001011101011001
      bl display
      ldr r0, =0b00000001010000010001011101000001
      bl display
      ldr r0, =0b00000001010000010001011101011001
      bl display
      b end_of_GPIOTE

    angry_version_right:
      ldr r0, =0b00000001010000001110100011011001
      bl display
      ldr r0, =0b00000001010000001110100011000001
      bl display
      ldr r0, =0b00000001010000001110100011011001
      bl display
      b end_of_GPIOTE


  go_to_eating_state:
    mov r0, 4
    bl set_state
    b end_of_GPIOTE

.data
numbers:
  .word 0b01110010100101001010011101100011 @ 0
  .word 0b00100001000010000100001001100011 @ 1
  .word 0b01110000100111001000011101100011 @ 2
  .word 0b01110000100111000010011101100011 @ 3
  .word 0b01010010100111000010000101100011 @ 4
  .word 0b01110010000111000010011101100011 @ 5
  .word 0b10001010100010001010100011100011 @ number out of bound