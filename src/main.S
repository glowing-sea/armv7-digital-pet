.syntax unified
.global main
.global SysTick_Handler, end_of_GPIOTE


.type main, %function
main:

  bl my_startup

  @ uncomment this to test the program
  @ bl tests

  openning:

  ldr r0, =0b00000000000000000000000001001010
  bl display
  ldr r0, =0b10010000000000000000000001000010
  bl display
  ldr r0, =0b10010100100000000000000001010010
  bl display
  ldr r0, =0b11111100101001000000000001000010
  bl display
  ldr r0, =0b00010111111001010010000001011010
  bl display
  ldr r0, =0b00000000101111110010100101000010
  bl display
  ldr r0, =0b00000000101111110010100101100010
  bl display
  ldr r0, =0b00000000101111110010100101000010
  bl display

  main_loop:

    @ Check the dog's state constantly
    bl get_state
    mov r4, r0
    case_expression:
      tbb [pc, r4]
    branchtable:
      .byte (case0 - branchtable) /2
      .byte (case1 - branchtable) /2
      .byte (case2 - branchtable) /2
      .byte (case3 - branchtable) /2
      .byte (case4 - branchtable) /2
      .byte (case5 - branchtable) /2
      .align
    case0:
      bl idle
      b exit_case
    case1:
      bl playing_pending_state
      b exit_case
    case2:
      bl playing_state
      b exit_case
    case3:
      @nop
    case4:
      bl eating_state
      b exit_case
    case5:
      b reset

    exit_case:

  b main_loop

.size main, .-main



reset:
  mov r0, 2
  bl set_friendship
  mov r0, 5
  bl set_hunger
  mov r0, 0
  bl set_state
  mov r0, 0
  bl reset_success_times
  bl reset_success_times
  b openning


@ ======================================== TIME HANDELERS ============================================== @


@ A handler that is called every millisecond
.type SysTick_Handler, %function
SysTick_Handler:
  push {lr}
  ldr r1, =milliseconds_count
  ldr r0, [r1]
  add r0, 1
  str r0, [r1]
  cmp r0, 1000
  IT EQ
  bleq every_second_checkpoint
  pop {lr}
  bx lr
.size SysTick_Handler, .-SysTick_Handler


@ A handler that is called every second
.type every_second_checkpoint, %function 
every_second_checkpoint:
  push {lr}

  ldr r1, =milliseconds_count
  mov r0, 0
  str r0, [r1] @ reset milliseconds counter
  ldr r1, =seconds_count @ add 1 second
  ldr r0, [r1]
  add r0, 1
  str r0, [r1]
  ldr r1, =seconds_count_reset @ add 1 second
  ldr r0, [r1]
  add r0, 1
  str r0, [r1]
  cmp r0, 10
  IT EQ
  bleq ten_seconds_checkpoint

  @ Chek if the game has finished or failed every second.
  @ Either friendship or hunger become 0 will lead to a failed state.

  bl get_hunger
  cmp r0, 0
  beq to_failed_state @ will back to second_check_end

  bl get_friendship
  cmp r0, 0
  beq to_failed_state @ will back to second_check_end

  @ When friendship reaches 5, the game finished. Can only finished once
  bl get_friendship
  cmp r0, 5
  beq to_finished_state @ will back to second_check_end

  second_check_end:
  pop {lr}
  bx lr
.size every_second_checkpoint, . - every_second_checkpoint


to_finished_state:
  bl get_succeed
  cmp r0, 1
  beq second_check_end @ already succeed once.
  ldr r0, =0b01010101011000101010001001001010
  bl display
  ldr r0, =0b01010101011000101010001000000010
  bl display
  ldr r0, =0b01010101011000101010001001010010
  bl display
  ldr r0, =0b01010101011000101010001000000010
  bl display
  ldr r0, =0b01010101011000101010001001011010
  bl display
  ldr r0, =0b01010101011000101010001000000010
  bl display
  ldr r0, =0b01010101011000101010001001100010
  bl display
  ldr r0, =0b01010101011000101010001000000010
  bl display
  mov r0, 1
  bl set_succeed
  b second_check_end


to_failed_state:
  ldr r0, =0b10001010100010001010100011001100
  bl display
  ldr r0, =0b10001010100010001010100010111100
  bl display
  ldr r0, =0b10001010100010001010100010101100
  bl display
  ldr r0, =0b10001010100010001010100010011100
  bl display
  @ Reset hunger and friendship
  mov r0, 2
  bl set_friendship
  mov r0, 5
  bl set_hunger
  mov r0, 5
  bl set_state
  b second_check_end


@ A handler that is called every 10 seconds
.type ten_seconds_checkpoint, %function 
ten_seconds_checkpoint:
  push {lr}
  ldr r1, =seconds_count_reset
  mov r0, 0
  str r0, [r1] @ reset seconds counter

  @ Every 10 seconds, if the dog is in idle state, there is 50% change to event
  @ the dog will be in playing pending state for 10s, if 10s pass, friendship level decrease by 1.
  @ if either A or B button is pressedm, the dog will move to playing state.
  bl get_state
  cmp r0, 0
  beq set_state_to_playing_pending @ this branch will back to end_of_ten_second_checkpoint


  end_of_ten_second_checkpoint:

  ldr r1, =ten_seconds_count
  ldr r0, [r1]
  add r0, 1
  str r0, [r1]

  @ every 20s, hunger - 1, i.e. every 10 seconds with odd numbers.
  mov r1, 2
  bl modulus
  cmp r0, 1
  beq not_decrease_hunger
    bl dec_hunger
  not_decrease_hunger:

  pop {lr}
  bx lr
.size ten_seconds_checkpoint, . - ten_seconds_checkpoint


@ 50% change to change state from 1 to 2
set_state_to_playing_pending:
  bl fifty_fifty
  cmp r0, 1
  IT EQ
  bleq set_state
  b end_of_ten_second_checkpoint


@ ======================================== BUTTONS HANDELERS ============================================== @

.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  push {lr}
  @ setup a breakpoint here to check when the interrupt occurs.
  @ interrupt code goes here
  @ clear event
  

  @ whenever ring 2 is touched, show the current status of the dog. do not change state
  ldr r0, =GPIOTE_EVENTS_IN2
  ldr r1, [r0]
  cmp r1, 1
  beq show_status @ after show_status it will jump to end_of_GPIOTE

  @ check if in playing pending state, change to playing state
  bl get_state
  cmp r0, 1
  beq set_state_to_playing @ after show_status it will jump to end_of_GPIOTE


  @ check if in idle state
  bl get_state
  cmp r0, 0
  beq idle_button_press_reaction @ after show_status it will jump to end_of_GPIOTE

  @ check if in playing with button enable
  bl get_state
  cmp r0, 3
  beq playing_button_press_reaction @ after show_status it will jump to end_of_GPIOTE


  end_of_GPIOTE:

  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, =0
  str r1, [r0]
  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r1, =0
  str r1, [r0]
  ldr r0, =GPIOTE_EVENTS_IN2
  ldr r1, =0
  str r1, [r0]
  ldr r0, =GPIOTE_EVENTS_IN3
  ldr r1, =0
  str r1, [r0]
  nop
  pop {lr}
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler




@ A sub buttons Handler when the dog is in playing pending state (1)
@ set to playing state.
set_state_to_playing:
  mov r0, 2
  bl set_state
  b end_of_GPIOTE


@ A sub buttons Handler when the dog is in idle state (0)
idle_button_press_reaction:

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

@ A sub buttons handler when the dog in playing state with button enable (3)
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


@ A sub buttons handler when ring 2 is pressed no matter what state the dog is in
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