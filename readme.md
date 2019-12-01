YAZSOF

Yet Another Z80 SoC On FPGA

This has been developed on an ULX3S (45K ECP5)

I took the Z80 soft core from the Galaksija project (https://github.com/emard/galaksija.git) and added my own peripherals, which are all accessed by a number of memory mapped locations

* Uart tx and rx (16 byte hardware buffer)

* DVI output (20x15 chars) each character is 8x8 each pixel is rendered as 4x4 pixel blocks on a 640x480 resolution. (I was using an 800x480 resolution but decided something more standard would be better)

* ability to get the state of the boards buttons


The initial state of the RAM contains a small "boot rom" (see asm/mon.asm). This allows you to upload an Intel Hex file (should start at address 0x0400) once the hex file is loaded this code is executed.  To send a hex file to the Z80 use

    ./serial-send.py asm/test2.hex

However there is currently a bug with this, when you reset the Z80 (PWR button) it should execute the hex loader, however this doesn't seem to happen, I suspect that the boot code is being overwritten, but I haven't worked out whats wrong yet...


