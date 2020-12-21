# Usage: 
# make all COMPT=COM5
# make boot COMPT=COM5
# make asm
# make clean

#com_port := COM5
SRCS := $(wildcard *.asm)
BINS := $(SRCS:%.asm=%.hex)
	
all: asm boot

asm: ${SRCS}
	@echo assembling ...
	avra -fI $<
	@echo Done.
	
boot: ${BINS}
	@echo uploading hex ...
	avrdude -D -p m328p -c arduino -b 115200 -P ${COMPT} -U flash:w:$<:i
	@echo Done.
	
clean:
	@echo cleaning ...
	rm -f *.obj *.cof *.lst *.map
	@echo Done.

.PHONY: all asm boot clean