%.hex: %.asm
	avra -fI $<
	rm *.eep.hex *.obj *.cof

all: $(patsubst %.asm,%.hex,$(wildcard *.asm))

upload: ${program}.hex
	avrdude -c arduino -p m328p -P /dev/arduino-uno -b 115200 -U flash:w:$<

monitor:
	picocom --send-cmd "ascii_xfr -s -v -l10" --nolock /dev/arduino-uno

.PHONY: all upload monitor