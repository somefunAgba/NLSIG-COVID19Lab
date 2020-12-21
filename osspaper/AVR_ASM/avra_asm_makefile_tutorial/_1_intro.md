There are a few different sources online that describe the ways that you can program Arduino Uno/ATmega328P in assembly,
and in the last couple of days I've had to switch through most of them just to get the basic setup and initial programs working. This is an attempt to aggregate all those sources in a centralized document, with two simple example programs.

## Requirements
There are two major options for the task (of which I'm aware of), and the setup I've settled on is accidental in retrospect [1]. But you might research on your own the alternative setup based around the [AVR Libc project](http://www.nongnu.org/avr-libc/).

For the setup I use you need: [avrdude](http://www.nongnu.org/avrdude/) and [avra](http://avra.sourceforge.net/). Do note that I'm using a Linux box, and in case you're on another operating system you'll be on your own with the setup/configuration of these tools.

### Optional (but must read)
When connected via USB my Uno would have it's serial interface mapped to `/dev/ttyACM0`. Because I wanted a more intuitive device name (and the fact that it took me some time to find out what device name it had in the first name), I wrote an `udev` rule to map my Uno board to `/dev/arduino-uno`.

```shell
$ cat /etc/udev/rules.d/10-arduino.rules
KERNEL=="ttyACM0", SYMLINK+="arduino-uno", OWNER="mhitza"
```

If you do the symlink, be sure to also include the `OWNER` directive; otherwise every time you upload the new program to your Uno you will have to call `avrdude` with `sudo`.

> **NOTE** If you skipped this step, be sure to replace any occurence of `/dev/arduino-uno` with `/dev/ttyACM0`, and prefix all `avrdude` calls with `sudo` in the followup Makefile.

Also you'll see a reference to `picocom` (program used for serial communication with the board) in the Makefile I use, and it should work but I haven't tested it yet.

## A simple Makefile
> **NOTE** There is already a popular [Makefile project for Arduino](https://github.com/sudar/Arduino-Makefile), however that one relies on the AVR Libc project. And as with other "prepackaged" solutions, like [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), I prefer to start from a small base. I find it easier to understand and maintain.

The makefile is available towards the end of the page.

Given a program named blink.asm
 * `make` (or `make blink.hex`) - compile it to a hex file
 * `make program=blink upload` - upload the program to your Arduino board. If you didn't run the previous step manually it will also compile the program for you
 * `make monitor` - monitor serial data

## Where do the names come from?
When reading other example assembly code online you will find references to named constants that are not built into the assembler. Those usually come from [m328Pdef.inc](https://raw.githubusercontent.com/DarkSector/AVR/master/asm/include/m328Pdef.inc). From where you download that file doesn't really matter, since basically everyone is carrying a copy around with them; or so it seems[2].

I personally use it as a learning reference, and I would recommend you copy only the definitions you need in your program until you get familiar with the names. That's the way I approach it, as you'll see in my example programs.

## The project for the sample code
![Arduino Uno LED project on a breadboard](http://i.imgur.com/5iQc2Yc.png)
*Project rendered on [123d.circuits.io](https://123d.circuits.io/)*

Three LEDs and a simple switch. With each press on the switch the LEDs turn on (from left to right), one by one, and once the red LED is reached further presses will turn off the LEDs in reverse order until we reach the initial state. Rinse and repeat.

Two implementations will be shown, the first one is the way most people - I think - would write the implementation (in terms on reacting to button presses, not necessary how they'd toggle the LEDs) (assuming they don't know about interrupts yet), and the second version will use an interrupt instead of "polling" the pin for voltage (state) changes. 

## References

> **NOTE** the assembler manual is for `AVRASM32.exe`, not `avra`. However avra is a compatible assembler, with just a few [extra features](http://avra.sourceforge.net/README.html#_differences_between_avra_and_avrasm32)

> **NOTE** if you see online references to `avrasm2`, you have to know that piece of software is different from `AVRASM32.exe` and `avra`. And `avra` is highly unlikely to be able to compile code written for that assembler. 

You need to keep these references close by when programming AVR in assembly:

 * [Atmel AVR 8-bit Instruction Set - Atmel Corporation](http://www.atmel.com/images/atmel-0856-avr-instruction-set-manual.pdf)
 * [AVR Assembler Guide](www.atmel.com/Images/doc1022.pdf)

---
 1. Initially I started with `avr-as`, but the helpfull stackoverflow answers I've found pointed to `avra` and as soon as I was able to write a simple program I didn't look back.  
 2. Maybe it could matter where you download it from. Some dastardly individual might provide that file in an altered format where the mappings wouldn't be correct and you'd write to the wrong memory bits and spend hours/days debugging the assembly code.