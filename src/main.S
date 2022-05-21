.syntax unified
.global main
.global every_second_checkpoint, end_of_GPIOTE


.type main, %function
main:

  bl my_startup


  @ mov r0, 1
  @ bl set_state
  @ bl playing_pending

  @ bl playing


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


  @ bl tests

  main_loop:

    @ Check the dog state at the beginning
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
      bl idel
      b exit_case
    case1:
      bl playing_pending
      b exit_case
    case2:
      bl playing
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




.type every_second_checkpoint, %function 
every_second_checkpoint:
  push {lr}
  ldr r1, =milliseconds_count
  mov r0, 0
  str r0, [r1] @ reset milliseconds counter

  @ ldr r0, =0b00000000101111110010100101010010
  @ bl display

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

  @ Either friendship or hunger become 0 will lead to a failed state.

  bl get_hunger
  cmp r0, 0
  beq to_failed_state @ will back to second_check_end

  bl get_friendship
  cmp r0, 0
  beq to_failed_state @ will back to second_check_end





  @ When friendship is 5 succeed state. can only go to succeed once
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
  beq second_check_end



.type ten_seconds_checkpoint, %function 
ten_seconds_checkpoint:
  push {lr}
  ldr r1, =seconds_count_reset
  mov r0, 0
  str r0, [r1] @ reset seconds counter

  @ ldr r0, =0b10111101011010110101101111010010
  @ bl display

  @ Every 10 seconds, if the dog is in idel state, there is 50% change to event
  @ the dog will be in playing pending state for 10s, if 10s pass, friendship level decrease by 1.
  @ if either A or B button is pressedm, the dog will move to playing state.
  bl get_state
  cmp r0, 0
  beq set_state_to_playing_pending


  end_of_ten_second_checkpoint:

  
  ldr r1, =ten_seconds_count
  ldr r0, [r1]
  add r0, 1
  str r0, [r1]

  @ every 20s, hunger - 1, i.e. every 10 seconds with odd numbers.
  mov r1, 2
  bl modulus
  cmp r0, 1
  bne not_decrease_hunger

  @ ldr r1, dog_record
  @ ldr r0, [r1, 4]
  @ sub r0, 1
  @ cmp

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

@ set to playing state.
set_state_to_playing:
  mov r0, 2
  bl set_state
  b end_of_GPIOTE


.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  push {lr}
  @ setup a breakpoint here to check when the interrupt occurs.
  @ interrupt code goes here
  @ clear event
  

  @ whenever ring 2 is touched, show the current status of the dog.
  ldr r0, =GPIOTE_EVENTS_IN2
  ldr r1, [r0]
  cmp r1, 1
  beq show_status @ after show_status it will jump to end_of_GPIOTE

  @ check if in playing pending state, change to playing state
  bl get_state
  cmp r0, 1
  beq set_state_to_playing @ after show_status it will jump to end_of_GPIOTE


  @ check if in idel state
  bl get_state
  cmp r0, 0
  beq idel_button_press_reaction @ after show_status it will jump to end_of_GPIOTE

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