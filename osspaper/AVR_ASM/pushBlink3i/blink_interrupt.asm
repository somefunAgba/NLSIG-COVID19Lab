; Copyright 2015 Marius Ghita
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

.device ATmega328P
.equ SREG = 0x3f
.equ RAMEND = 0x08ff
.equ SPL = 0x3d
.equ SPH = 0x3e
.equ EICRA = 0x69
.equ EIMSK = 0x1d
.equ DDRB  = 0x04
.equ DDRD  = 0x0a
.equ PORTB = 0x05
.equ PORTD = 0x0b

.org 0x0000
    jmp reset
    
; memory location for interrupt 0 (PIN 2)
.org 0x0002
    jmp pushed_button

; The code here is mostly similar to the one written in the previous example
; The only major difference is that the jumps back to the main loop have been
; replaced with reti calls, since this is a interrupt handler
pushed_button:
    tst r20
    brne off_pins
    sbis PORTB, 4
    rjmp set_pin_12
    sbis PORTB, 2
    rjmp set_pin_10
    sbis PORTD, 5
    rjmp set_pin_5
    all_on:
        ldi r20, 1
        reti
    off_pins:
        sbic PORTD, 5
        rjmp off_pin_5
        sbic PORTB, 2
        rjmp off_pin_10
        sbic PORTB, 4
        rjmp off_pin_12
    all_off:
        ldi r20, 0
        reti
    set_pin_12:
        sbi PORTB, 4
        reti
    off_pin_12:
        cbi PORTB, 4
        rjmp all_off

    set_pin_10:
        sbi PORTB, 2
        reti
    off_pin_10:
        cbi PORTB, 2
        reti

    set_pin_5:
        sbi PORTD, 5
        rjmp all_on
    off_pin_5:
        cbi PORTD, 5
        reti

reset:
    sbi DDRB, 2
    sbi DDRB, 4
    sbi DDRD, 5

    ; The stack is used by the MCU to store the return address from the interrupt handler 
    ; and we have to manually initialize the stack; by writting
    ; the SPL (stack pointer low) and SPH (stack pointer high) memory
    ; locations with the RAMEND information we know for our device
    ldi r16, LOW(RAMEND)
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16

    ; load in register r17 EICRA (External Interrupt Control Register) and
    ; set the bit 1, which means our interrupt handler is called when there's
    ; a low to high voltage change on our PIN2
    lds r17, EICRA
    ori r17, 0b00000010
    sts EICRA, r17

    ; we enable our INT0 (PIN2) by setting bit 0 on EIMSK (bit 1 would be used
    ; if we wanted to use INT1 (PIN3) instead
    in r18, EIMSK
    ori r18, 0b00000001
    out EIMSK, r18

    sei ; enable interrupt handler

; since programs can't terminate, and our logic is done in the interrupt handler
; we do an infinite loop. Alternatively you can research the sleep instruction
; and use that here as well, that way power usage will be small and the MCU will
; awake itself when the interrupt is triggered
main: rjmp main