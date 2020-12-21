;--- pushBlink3.asm ---
;--- Circuit Description ---
; Assume we have three LEDs and a push button (switch). 
; 1. On a push of the switch, the LEDs turn ON in order (from left to right)
; Assume the left is a white LED, and right is a red LED. 
; 2. Another Push, will turn OFF the LEDs in reverse order to the left.
; 3. Repeat 1, and Vice-verca on subseqent pushes.
;--- No Interrupt Implementation ---

; Definitions taken from file: m328Pdef.inc
.device ATmega328P

; for mapping Pins 8-13
.equ PORTB = 0x05
.equ DDRB = 0x04
; for mapping Pins 0-7
.equ PORTD = 0x0B
.equ DDRD = 0x0A
.equ PIND = 0x09

.cseg
.org 0x0000
	jmp main
	
main:
	jmp setup
	
setup:	
	; set bits
	; for the LEDS: setup pins 10, 12 and 5 as output (1)
	; PORT B starts from pin 8, so bit of pin 10 and 12
	; will be 2 and 4 respectively
	sbi DDRB, 2 ; set PORTB2
	cbi PORTB, 2;
	sbi DDRB, 4 ; set PORTB4
	cbi PORTB, 4;
	; PORT D starts from 0, so the bit of pin 5 will be 5
	sbi DDRD, 5; set PORTB5
	cbi PORTD, 5
	
	; clear bits
	; for the SW: setup pin 2 as input (0)
	; the bit of pin 2 in PORT D is 2
	cbi DDRD, 2; clear PORTB2
	cbi PORTD, 2;
	; we will be using general purpose working register 20, r20
	; for safety let's clear the register
	clr r20;
	
	; JUMPING LOOP FUNCTIONS
	
	; 1. CHECK IF PUSH BUTTON SW IS PRESSED 
	; 2. CHECK IF PUSH BUTTON SW IS RELEASED
	; keep polling pin information, to see if 
	; there is a voltage (input bit is set) or 
	; not (input bit is cleared).
	
is_pressed: 
	; if input is set on PORTB2, skip next instruction
	sbis PIND, 2
	rjmp is_pressed ; skipped if PORTB2 is set
	rjmp turn_all_on ; enter blink function if PORTB2 is cleared
	
isn_pressed:
	;if input is set on PORTB2, loop once more
	;if input is cleared on PORTB2, switch to is_pressed loop
	sbic PIND, 2
	rjmp isn_pressed ; skipped if PORTB2 is cleared
	rjmp is_pressed ; entered if PORTB2 is set	
	
if_all_on: ; STATE 1 
	; if all the leds are ON
	; set r20 , to show that all is on
	; resume checking if switch is pressed.
	ldi r20, 1
	rjmp isn_pressed
	
if_all_off: ; STATE 2
	; if all leds are OFF, 
	; clear r20, to show that all is off
	; resume to check if switch is pushed
	ldi r20, 0
	rjmp isn_pressed;
	
turn_all_on: ; TURN ON
	; test register.
	; if register is set, that means all is already on
	; therefore Zflag is neq 1, however if cleared that means
	; all is already off, and Zflag is set = 1
	tst r20
	; if Zflag is neq = 1, so go to turn_all_off
	; else skip branch statement
	brne turn_all_off ; try commenting out to see what happens 
	
	sbis PORTB, 4
	rjmp set_pin_12; if pin 12 is not on, set it
	sbis PORTB, 2
	rjmp set_pin_10; if pin 10 is not on, set it
	sbis PORTD, 5
	rjmp set_pin_5; if pin 5 is not on, set it

turn_all_off: ; TURN OFF
	; test register state: 
	; if register is cleared that means all is already off
	; then Zflag is then set eq to 1,
	; however, if register is set, then Zflag neq to 1
	;tst r20; 
	; if Zflag eq to 1, then (branch to) 'turn_all_on' line
	; else skip branch instruction
	;breq turn_all_on;
	
	sbic PORTD, 5
	rjmp clear_pin_5; if pin 5 is on, turn it off
	sbic PORTB, 2
	rjmp clear_pin_10; if pin 10 is on, turn it off
	sbic PORTB, 4
	rjmp clear_pin_12; if pin 12 is on, turn it off	

; SET BIT JUMP FUNCTIONS	
set_pin_12:
	sbi PORTB, 4
	rjmp isn_pressed;
	
set_pin_10:
	sbi PORTB, 2
	rjmp isn_pressed;	
	
set_pin_5:
	sbi PORTD, 5
	rjmp if_all_on; 

; CLEAR BIT JUMP FUNCTIONS	
clear_pin_5:
	cbi PORTD, 5
	rjmp isn_pressed;	
	
clear_pin_10:
	cbi PORTB, 2
	rjmp isn_pressed;

clear_pin_12:
	cbi PORTB, 4
	rjmp if_all_off;	
		
	; infinite loop 
	; for safety to ensure the program never terminates
	; it is redundant in this case
inf_loop:
	rjmp inf_loop
	
	

  
