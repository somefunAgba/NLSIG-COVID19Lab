;--- REGISTER (memory location) COMMANDS ---
; Below are some common instructions to manipulate
; the AVR register (I/O and GP)

; JUMP TO LABEL
jmp label ; jump
rjmp label ; relative jump

; SET/CLEAR BIT IMMEDIATE
sbi register, bit/byte ; set
cbi register, bit/byte ; clear 
clr register ; clear all bits in register

; LOAD DATA IMMEDIATE
ldi register, byte ; load byte into register

; LOAD FROM DATA SPACE (GP REGISTER I/0 REGISTER, SRAM)
lds register, register;

; WRITE CONTENT OF (GP) REGISTER TO ANOTHER REGISTER (I/O)
out register, register;

; READ CONTENT OF I/O REGISTER INTO GP REGISTER
in register, register;

; STORE TO DATASPACE FROM REGISTER
sts register, register;

; TEST: SKIP THEN BRANCH IMMEDIATE IF SET/ CLEAR 
sbis register, bit/byte; if set
sbic register, bit/byte; if clear
; usually followed by a jmp statement

; TEST REGISTER: SET Z FLAG IF ZERO OR NEGATIVE NUMBER
tst register ;if true, set Z flag
; sets the bit in the Z flag to 1, if register is cleared or contains negative number
; the Z flag is an implicit location in the STATUS REGISTER SREG
; contains the status of the condition: true or false

; BITWISE OR IMMEDIATE
ori register, byte ; bitwise OR operation 

; TEST REGISTER: BRANCH TO LABEL IF ZFLAG IS EQUAL/ NOT EQUAL
breq label; if ZFLAG is equal = set (true), branch to label
brne label; if ZFLAG not equal = cleared (false), branch to label
; makes use of the Z flag

; ENABLE INTERRUPTS
sei;

; CLEAR INTERRUPTS
cli;

; RETURN FROM INTERRUPT
reti;

; RETURN FROM MACRO OR FUNCTION
ret;