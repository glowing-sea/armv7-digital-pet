.syntax unified
.global display, twinkling, modulus, fifty_fifty, one_tenth


@======================== DISPLAY FUNCTIONS ========================@

@ Dramatically modifited and improved from assignment 1
@
@ Added sound feature, can display image while playing sound.
@ Fix DIR and OUT mixing issues. Before I used DIR register to control LEDs instead of OUT
@ Before I open and stop both DIR and OUT register in each row display. Now after initialising DIR register, it will remain unchanged.
@ Before I always push r0-r11 in each function without following the convention. The execution time dramatically incrase aftering
@ carefully select the registers to push.
@ Before to check if the last bit is 1, I shift 31 bit right and 31 bit right and use com. Now I use tst directly.


@ Take a 32-bit image encoding from r0 and display it
@ return the same image encoding in r0
@ although only r4-r7 need to be saved, for being eaily used in main, I also store r0
display:
  push {r0, r4-r7, lr}
  
  and r5, r0, 0b111 @ extract the time bits to r5
  lsl r5, #6
  lsr r0, r0, #3 @ delete the time bits from r0

  and r6, r0, 0b111 @ extract the sound bits to r6
  lsr r0, r0, #3 @ delete the sound bits from r0

  mov r4, 1
  tst r0, 1  @ check brightness bit
  beq decrease_brightness
  b brightness_setting_finished

  decrease_brightness:
    mov r4, 0
    lsl r5, #7

  brightness_setting_finished:
  lsr r0, r0, #1 @ delete brightness bit


  @ r7 is used for saving the sound wave progress

  begin_display_image_loop:
    cmp r5, 0
    beq end_display_image_loop
    push {r0}
    @ display rows one by one
    mov r3, 19 @ row 5
    bl display_row @ row 5
    mov r3, 24 @ row 4
    bl display_row @ row 4
    mov r3, 15 @ row 3
    bl display_row @ row 3
    mov r3, 22 @ row 2
    bl display_row @ row 3
    mov r3, 21 @ row 1
    bl display_row @ row 1
    sub r5, 1
    pop {r0} @ restore r0 after each display loop
    b begin_display_image_loop

  end_display_image_loop:


  @ avoid using while loop because faster. using while loop need to use and push r8 and r9
  @ close the speaker by sending constant samples.
  mov r0, 1
  bl audio_play_sample
  mov r0, 1
  bl audio_play_sample
  mov r0, 1
  bl audio_play_sample
  mov r0, 1
  bl audio_play_sample
  mov r0, 1
  bl audio_play_sample
  mov r0, 1
  bl audio_play_sample
  mov r0, 1
  bl audio_play_sample
  mov r0, 1
  bl audio_play_sample


  pop {r0, r4-r7, lr}
  bx lr




@ Read the last 5 bits of r0 and display it on a row. After that, right-shift r0 5 digits.
@ input:
@ r0: image encoding
@ r3: bit index of the rows
@ r4: brightness
@ output:
@ r0: image encoding with 5 less LED information
display_row:
  push {r3, lr}
  mov r2, r3 
  bl row_positive 
  ldr r1, =ADR_P0
  mov r2, 30 @ col 5
  bl col_negative @ col 5
  ldr r1, =ADR_P1
  mov r2, 5 @ col 4
  bl col_negative @ col 4
  ldr r1, =ADR_P0
  mov r2, 31 @ col 3
  bl col_negative @ col 3
  ldr r1, =ADR_P0
  mov r2, 11 @ col 2
  bl col_negative @ col 2
  ldr r1, =ADR_P0
  mov r2, 28 @ col 1
  bl col_negative @ col 1
  push {r0}
  bl delay_between_rows @ play sounds while creating delay between on and off of LED

  pop {r0, r3}
  mov r2, r3
  bl row_negative @ reset the row to negative
  bl all_col_positive @ reset all column to positive

  pop {lr}
  bx lr


@ Create time delay
@ Input 
@ r4: time delay
@ r6: sound
@ Output
@ r5: the current progress of the sound
delay_between_rows:
  push {r4, lr}
  
  @ no delay
  cmp r4, 0
  beq delay_between_rows_end

  @ delay without souond
  cmp r6, 0
  beq delay_without_sound_start

  b delay_with_sound_start


  delay_without_sound_start:
    mov r0, 0x1100
    delay_without_sound:
      cmp r0, 0
      beq delay_between_rows_end
      sub r0, r0, 1
      b delay_without_sound

  delay_with_sound_start:
    ldr r4, =0x15
    delay_with_sound:
      cmp r4, 0
      beq delay_between_rows_end
      add r7, r6 @ increment
      mov r0, r7
      bl audio_play_sample
      sub r4, 1
      b delay_with_sound

  delay_between_rows_end:
  pop {r4, lr}
  bx lr


@ Set a column to negative if the last bit of r0 is 1
@ r0: the image encoding
@ r1: base address
@ r2: bit index
@ output
@ r0: the image encoding with 1 less LED information
col_negative:
  push {r4, lr}
  tst r0, 1
  beq keep_col_positive @ if result in 0, i.e the last bit of r0 is 0, do not turn on the LED
    ldr r3, [r1, 0x504] @ get the value of DIR register at address [r1 + 0x514] and save it into r3.
    mov r4, 1
    lsl r4, r4, r2
    bic r3, r3, r4 @ set the corresponding pin
    str r3, [r1, 0x504] @ store the new value of DIR register back at address [r1 + 0x514].
  
  keep_col_positive:
  lsr r0, r0, #1 @ delete the right most bit of r0 by right-shifting r0 1 bit.
  pop {r4, lr}
  bx lr


@ Set all columns to positive
all_col_positive:
  push {r4, r5, lr}
  ldr r1, =ADR_P0 @ base address of P0
  ldr r2, =ADR_P1 @ base address of P1
  ldr r3, [r1, 0x504] @ get the value of DIR register at address [r0 + 0x514] and save it into r3.
  ldr r4, [r2, 0x504] @ get the value of DIR register at address [r1 + 0x514] and save it into r4.
  mov r5, 1
  orr r3, r3, r5, lsl 28 @ clear col 1
  orr r3, r3, r5, lsl 11 @ clear col 2
  orr r3, r3, r5, lsl 31 @ clear col 3
  orr r4, r4, r5, lsl 5 @ clear col 4
  orr r3, r3, r5, lsl 30 @ clear col 5
  str r3, [r1, 0x504] @ store the new value of DIR register back at address [0x50000000 + 0x514].
  str r4, [r2, 0x504] @ store the new value of DIR register back at address [0x50000300 + 0x514].
  pop {r4, r5, lr}
  bx lr



@ Set a row to positive
@ r2: bit index
row_positive:
  push {r4, lr}
  ldr r1, =0x50000000
  ldr r3, [r1, 0x504] @ get the value of DIR register at address [0x50000000 + 0x514] and save it into r3.
  mov r4, 1
  lsl r4, r4, r2
  orr r3, r3, r4 @ set the corresponding pin
  str r3, [r1, 0x504] @ store the new value of DIR register back at address [0x50000000 + 0x514].
  pop {r4, lr}
  bx lr


@ Clear a row to negative
@ r2: bit index
row_negative:
  push {r4, lr}
  ldr r1, =0x50000000
  ldr r3, [r1, 0x504] @ get the value of DIR register at address [0x50000000 + 0x514] and save it into r3.
  mov r4, 1
  lsl r4, r4, r2
  bic r3, r3, r4 @ clear the corresponding pin
  str r3, [r1, 0x504] @ store the new value of DIR register back at address [0x50000000 + 0x514].
  pop {r4, lr}
  bx lr


@======================== HELPER FUNCTIONS ========================@


@ Takes two images and altenatively shows them
@ r1: image 1
@ r2: image 2
@ r3: repeated times
twinkling:
  push {r4-r6, lr}
  mov r4, r1
  mov r5, r2
  movs r6, r3

  twinkling_loop:
    beq rest_of_program
    mov r0, r4
    bl display
    mov r0, r5
    bl display
    subs r6, 1
    b twinkling_loop
  rest_of_program:
  pop {r4-r6, lr}
  bx lr



@ r0: number
@ r1: divisor
@ r0: return value
modulus:
  udiv r2, r0, r1
  mul r3, r1, r2
  sub r0, r0, r3
  bx lr

@ 50% return 0
fifty_fifty:
  push {lr}
  ldr r0, =0x4000D000
  ldr r0, [r0, 0x508] @ get a random number
  mov r1, 2
  bl modulus
  pop {lr}
  bx lr


@ 10% change of returning 0.
one_tenth:
  push {lr}
  ldr r0, =0x4000D000
  ldr r0, [r0, 0x508] @ get a random number
  mov r1, 10
  bl modulus
  pop {lr}
  bx lr





