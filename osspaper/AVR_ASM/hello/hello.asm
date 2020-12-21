; useful links: http://academy.cba.mit.edu/classes/embedded_programming/index.html
;http://www.avr-asm-tutorial.net/avr_en/beginner/execution/execution.html
;http://www.avr-asm-tutorial.net/avr_en/micro_beginner/index.html
; http://www.avr-asm-tutorial.net/avr_en/starter/starter.html
; https://www.instructables.com/id/Command-Line-AVR-Tutorials/


; hello.asm
; EXPERIMENT: turn on a LED connected to PORTB5 (PIN 13) on ATMEGA328P
; ATMEGA-AVR is a relatively simple 8-bit Reduced Instruction Set Computer, or RISC, microcontroller with a Harvard architecture.
; easier to use and configure than the STM-ARM FAMILY

; % stands for filename.
; avra %.asm
; avrdude -D -p m328p -c arduino -P COM5 -U flash:w:%.hex:i


;; What we will learn
;; mnemonics
; ldi hregister, number
;; load an 8-bit number (0-255) into a upper half register(16-31)
; out ioregister, register
;; copy a number from a working register into an input-output I/O register 
; rjmp label
;; relative jump to a line (not more thn 204 instructions(lines) away) in the source code, indicated by label.
; semi-colon indicates a comment line.
; case-insensitive, so be careful

; definition file for the ATMEGA328P; makes life easier
; if we did not include this, we would have to manually add the required definitions in the file in this source code
.include "m328Pdef.inc"

	.cseg ; code segment for flash memory
	.org 0x00 ; origin of code segment : here it is the beginning of the flash memory: 0x00
	
main:
	; load immediate number into register
	; a register here is a set of 8bits, meaning 8 locations that can either be 0 or 1
	; a register here is used as a variable name to store a number
	; load 0x20 in general purpose working register, r16
	; we cannot load constants as an operand into i/o registers but can use 
	; general purpose registers 16 to 31
	; these registers are specially connected to the ALU. 
	; so anytime we need the CPU to operate on a value
	; it should first be placed in one of those
    ldi r16, 0b00100000; 0x20 (hex) or 32 (decimal)
	
	; DDRB: Data Direction Register B
	; copy the contents of r16 into DDRB
	; ths sets up the bit locations in PORTB:PB0-PB7: 
	; with 0 as input directed locations 
	; and those with 1 as output directed
	; accept i/o mapped register as operand
    out DDRB, r16
	
	; copy r16 to PORTB register
	; 0 now means 0volts and 1 means Vcc=5volts: in this case we only have PB5=1
    out PORTB, r16
	
; a line label called loop
loop:
	; rjmp = relative jump to a label
	; here this causes an infinite loop
	; since the jumping continues forever
	; allowing PB5 to remain set at 1,
	; hence the LED stays on.
    rjmp loop    
	; removing this infinite-loop may cause a sort of undefined behaviour, but it is optional.
	
;; Conclusion (rephrase)
; We have seen how to use assembler directives like .include, .cseg and .org. 
; We also saw how to load constants to general purpose working registers using 
; the instruction ldi and write values to I/O registers using the instruction out. 
; Finally, we saw how to define labels and control program flow with the instruction rjmp.	
