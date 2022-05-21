.syntax unified

.global GPIOTE_INTENSET
.global GPIOTE_CONFIG0
.global GPIOTE_CONFIG1
.global GPIOTE_CONFIG2
.global GPIOTE_CONFIG3
.global GPIOTE_EVENTS_IN0
.global GPIOTE_EVENTS_IN1
.global GPIOTE_EVENTS_IN2
.global GPIOTE_EVENTS_IN3
.global NVIC_ISER0
.global NVIC_ICER0
.global NVIC_ICPR0

.global my_startup
.global SysTick_Handler

@ GPIOTE Constants
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set GPIOTE_CONFIG1, 0x40006514
.set GPIOTE_CONFIG2, 0x40006518
.set GPIOTE_CONFIG3, 0x4000651C

.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_EVENTS_IN1, 0x40006104
.set GPIOTE_EVENTS_IN2, 0x40006108
.set GPIOTE_EVENTS_IN3, 0x4000610C

@ NVIC Constants
.set NVIC_ISER0, 0xE000E100 @ set enterupt
.set NVIC_ICER0, 0xE000E180 @ clear enterupt
.set NVIC_ICPR0, 0xE000E280 @ clear pending

@ Startup function
.type my_startup, %function
my_startup:
  push {lr}

  @ Sound and light
  bl audio_init
  bl init_leds

  @ Set up RNG
  ldr r1, =0x4000D000
  ldr r2, [r1]
  mov r2, 1
  str r2, [r1] @ Open Random Number Generator (RNG)


  @ Set up timer
  ldr r0, =ADR_SYST_CSR
  ldr r1, =0b111
  str r1, [r0]

  ldr r0, =ADR_SYST_RVR
  ldr r1, =64000 @ 64000 cycles per millisecond
  str r1, [r0]

  @ Set priority (High)
  ldr r0, =0xE000ED20
  ldr r1, =1 << 29 @ 29-31
  str r1, [r0]


  @ 1: Configure GPIOTE_CONFIG[0]
  @ Need to setup: mode, pin, port, polarity in the configuration register for GPIOTE[0]
  @ Section 6.9.4.8 in nRF52833 reference manual
  @ mode = 1 (event), pin = 14 and port = 0 (P0.14 = Button A), polarity = 1 (LoToHi)
  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16)
  str r1, [r0]

  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(1 | 23 << 8 | 0 << 13 | 1 << 16)
  str r1, [r0]

  ldr r0, =GPIOTE_CONFIG2
  ldr r1, =(1 | 4 << 8 | 0 << 13 | 2 << 16)
  str r1, [r0]

  ldr r0, =GPIOTE_CONFIG3
  ldr r1, =(1 | 4 << 8 | 1 << 13 | 2 << 16)
  str r1, [r0]

  @ 2: Enable Interrupt for GPIOTE[0] (id = 6)
  @ S6.9.4.6 in nRF52833 reference manual
  ldr r0, =GPIOTE_INTENSET
  ldr r1, =(1 << 0 | 1 << 1 | 1 << 2 | 1<< 3)
  str r1, [r0]

  @ 3: enable GPIOTE (interrupt #6 = NVIC_GPIOTE_ID) in NVIC_ISER0
  @ NVIC_ISER0: B3.4.4 in ARMv7-M Reference Manual
  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6)
  str r1, [r0]

  @ 4: Set priority (Low)
  ldr r0, =0xE000E404
  ldr r1, =1 << 22 @ 21-23
  str r1, [r0]


  @ openning
  @ ldr r0, =0b00000000000000000000000001001010
  @ bl display
  @ ldr r0, =0b10010000000000000000000001000010
  @ bl display
  @ ldr r0, =0b10010100100000000000000001010010
  @ bl display
  @ ldr r0, =0b11111100101001000000000001000010
  @ bl display
  @ ldr r0, =0b00010111111001010010000001011010
  @ bl display
  @ ldr r0, =0b00000000101111110010100101000010
  @ bl display
  @ ldr r0, =0b00000000101111110010100101100010
  @ bl display
  @ ldr r0, =0b00000000101111110010100101000010
  @ bl display

  pop {lr}
  bx lr
.size my_startup, . - my_startup


@ Milliseconds Counter
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