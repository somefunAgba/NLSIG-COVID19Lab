;----------------------------------------------------
; Author: oasomefun@futa.edu.ng
; Course: CPEXXX
; Date: 2020.08
; Version: 1.0
; AVR: ATMEGA328P
;--- Program Description -----------------------------
; EXPERIMENT: Use a Push button connected to
; PD4 to turn on  PB4. A LED is connected to PB4
; CIRCUIT: 
; PD4 --> PushButton --> GND (0V) 
; : =====set to be initially HIGH (HAS AN INTERNAL PULL UP RESISTOR), when pressed changes to 0V (think voltage division)
; VCC (5V) --> R(Ohm) --> LED --> PB4 
; IF PB4 is HIGH (5V), no potential difference between PB4 and VCC, LED becomes LOW,
; ELSE if PB4 is LOW (0V), there is a potential difference, hence current flows and the LED is HIGH
;----------------------------------------------------

.nolist
.include "m328Pdef.inc"
.list

;--- Definitions ---

; define general purpose register 16 as temporary state
.def VAL = r16

;--- Main Program ---
.cseg

main: rjmp setup

setup: 
	;-- set up data direction registers
	
	; set all bits in VAL TO 1
	; put VAL in DDRB to make all I/O pins
	; in PORTB to be output directed
	; note: setting a bit to 0 will make it input directed.
	ser VAL
	out DDRB, VAL
	
	; set 0b1110-1111 = 0xEF as desired
	; data direction state for PORTD
	; this makes PD4 input, and the rest as outputs
	ldi VAL, 0xEF
	out DDRD, VAL
	
	; -- initialize I/O registers
	; clear bits in VAL equals to set all bits to 0
	clr VAL
	; initialize the state of all bits in PORTB to be 0V
	out PORTB, VAL
	
	; initialize PD4 only as HIGH (ACTIVATES THE PULL-UP RESISTOR)
	; 0b0001-0000 = 0x10 to set only PD4 as 5V input
	ldi VAL, 0x10
	out PORTD, VAL
	; not recommended : if set to be LOW (NO PULL-UP), TO EFFECT CHANGES WIRE UP: PD4-->BUTTON --> VCC
	; has the same effect as commenting out the above two lines
	; ldi VAL, 0x00 
	; out PORTD, VAL
	
loop: 
	; some notes:
	; PIND is PORT D Input Pins
	; PORTD is PORT D Data Register
	; DDRD is PORT D Data Direction Register
	; since PD4 was set to receive input
	; we need to read the state of the input 0 or 1
	
	; for PORT D our port of interest, PIND holds this state
	; based on the setup, we initialized this to 
	; at no push -- reads 1 (HIGH) sets the PULL-UP resistor.
	; when pushed -- toggles to read 0 (LOW)
	; This means PD4 will send a 1 to PortD4 unless the button is pressed. 
	; So since the button terminal is also connected to GND, and PD4 is pulled to HIGH
	; initially that pin will be at a potential diff. of 5V, but when pressed it toggles to 0V.
	
	; copy (read) the state of PIND into VAL
	in VAL, PIND
	; pass VAL into PORTB
	; this makes PORT B imitate PORT D's input state
	out PORTB, VAL
	
	; enter an infinite loop
	; jump back to start of line labelled loop
	rjmp loop
	
	
; Conclusion: we learned how to control a LED with a pushbutton. In particular we learned the following commands:
; ser register: sets all of the bits of a register to 1's
; clr register: sets all of the bits of a register to 0's
; in register, i/o register : copies the number from an i/o register to a working register
; learned how to create structured labels


