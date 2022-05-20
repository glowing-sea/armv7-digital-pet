.syntax unified
.global main

.type main, %function
main:

@======================== ENCODINGS ========================@

  @ setup
  bl audio_init
  bl init_leds
  ldr r1, =0x4000D000
  ldr r2, [r1]
  mov r2, 1
  str r2, [r1] @ Open Random Number Generator (RNG)
  

  @ openning
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



  main_idel_loop:


    mov r4, 3
    keep_smiling:
      cmp r4, 0
      beq start_blinking_eyes
      ldr r0, =0b00000010100000010001011101000111
      bl display
      sub r4, 1
      b keep_smiling


    start_blinking_eyes:
      ldr r0, =0b00000000000000010001011101000001
      bl display
      ldr r0, =0b00000010100000010001011101000001
      bl display
      ldr r0, =0b00000000000000010001011101000001
      bl display
      ldr r0, =0b00000010100000010001011101000001
      bl display


  b main_idel_loop
.size main, .-main