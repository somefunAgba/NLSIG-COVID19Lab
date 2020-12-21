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


; Everything after a semicolon is a comment

; We specify the Atmel microprocessor. The Uno uses ATmega328P,
; older versions might use ATmega328 
.device ATmega328P

; These are all constant definitions taken from m328Pdef.inc
; and we will go in more detail of what they are, when they
; are used
.equ PORTB = 0x05
.equ PORTD = 0x0b
.equ PIND  = 0x09
.equ DDRB  = 0x04
.equ DDRD  = 0x0a

; At ORiGin 0x0000 we "hook" in our call to our programm main
; we do not write our program here, as of why, we will go over
; that later
.org 0x0000
    jmp main

; DDR* are used just for specifing what will be an input
; pin, and what will be an output pin.
main:
    ; DDRB maps over pins 8-13.
    ; We set[1] pin 10 and 12 (starting DDRB pin is 8):
    ;  - 8 + 2 = 10
    ;  - 8 + 4 = 12
    ; [1] Set means we assign the bit value to 1 = output
    sbi DDRB, 2
    sbi DDRB, 4
    ; DDRD maps over pins 0-7
    ; We set pin 5: 0 + 5 = 5
    sbi DDRD, 5
    
    ; DDRD maps over pins 0-7
    ; We clear the 2nd bit: 0 + 2 = 2
    ; Clear means we assign the bit value to 0 = input
    cbi DDRD, 2
    ; just set register r20 to 0
    clr r20

; tight loops polling pin information to see when either
; there's voltage (bit set - check_press_loop) on pin 2,
; or not (bit clear - check_release_loop)
check_press_loop:
    ; if input on pin 2, skip next instruction
    sbis PIND, 2
    rjmp check_press_loop  ; this is the one we will skip
    rjmp toggle_leds
check_release_loop:
    ; if input on pin 2, loop once more
    ; if clear pin 2, switch to button press check loop
    sbic PIND, 2
    rjmp check_release_loop
    rjmp check_press_loop

toggle_leds:
    tst r20
    brne off_pins
    sbis PORTB, 4
    rjmp set_pin_12 ; if pin 12 is not on, set it
    sbis PORTB, 2
    rjmp set_pin_10 ; if pin 10 is not on, set it
    sbis PORTD, 5
    rjmp set_pin_5 ; if pin 5 is not on, set it
all_on:
    ; once it falls through and we set 1 to r20 the first check
    ; in toggle_leads should make sense
    ldi r20, 1
    rjmp check_release_loop
off_pins:
    sbic PORTD, 5
    rjmp off_pin_5
    sbic PORTB, 2
    rjmp off_pin_10
    sbic PORTB, 4
    rjmp off_pin_12
all_off:
    ; now we go back to our initial state and the whole program loops
    ldi r20, 0
    rjmp check_release_loop

; We use PORT* to write to a pin configured as output (in our main)
; As with DDR*:
;   - PORTB maps over pins 8-13 (just like DDRB)
;   - PORTD maps over pins 0-7 (just like DDRD)
set_pin_12:
    sbi PORTB, 4
    rjmp check_release_loop
off_pin_12:
    cbi PORTB, 4
    rjmp all_off

set_pin_10:
    sbi PORTB, 2
    rjmp check_release_loop
off_pin_10:
    cbi PORTB, 2
    rjmp check_release_loop

set_pin_5:
    sbi PORTD, 5
    rjmp all_on
off_pin_5:
    cbi PORTD, 5
    rjmp check_release_loop

; NOTE a program must never terminate. If you're not processing something
; in a loop like this program did, you can just add an infinite loop at 
; the end, like
;
; loop:
;      rjmp loop