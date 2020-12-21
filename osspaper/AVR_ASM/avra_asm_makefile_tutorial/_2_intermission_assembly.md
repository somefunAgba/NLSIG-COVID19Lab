While mentioned in the previous document that you should download the assembly instruction set manual, for the following examples I'd like to detail the instructions I will use (so that you can follow along the code examples).

 * `jmp label` or `rjmp label` - jump to a label
 * `sbi memory_location, bit_position` - set bit immediate[1]
 * `cbi memory_location, bit_position` - clear bit immediate
 * `clr register` - clear register
 * `sbis memory_location, bit_position` - skip branch immediate (bit) set[2]
 * `sbic memory_location, bit_position` - skip branch immediate (bit) clear
 * `tst register` - test register for zero or negative number, if true, the Z flag is set[3]
 * `brne label` - branch not equal
 * `ldi register, byte_value` - load data immediate
 * `reti` - return from interrupt
 * `out memory_location, register` - write a register to a memory location
 * `lds register, data_space` - load from data space (register, I/O memory, SRAM) into register
 * `ori register, byte_value` - bitwise OR immediate
 * `sts register, data_space` - store to data space from register
 * `sei` - enable interrupts
 * `in register, memory_location` - read memory location into register

---
 1. Immediate here means that a value (bit\_position/byte\_value) can be specified directly for the operation.
 2. With skip branch instructions, when the comparison turns out to be true the followup instruction is skipped. Most of the time that followup instruction would be a jmp
 3. There are a couple of instructions that work on implicit values inside the SREG registry. For example the Z flag is bit 1 in that register. `tst` is one of the many instructions that sets that value, while the `brne`/`breq` instructions are two example instructions that make use of the Z bit value. 