
# call make with for example test1.txt to build ascii binary values of code

# ../../../z80-asm-2.4.1/z80-asm -w mon.asm mon.z80
# dd if=mon.z80 of=mon.bin ibs=10 skip=1
# srec_cat -address-length=2 -Output_Block_Size=8 mon.bin -Binary -o mon.hex -Intel
# srec_cat -address-length=2 -Output_Block_Size=8 mon.bin -Binary -o mon.mem -Lattice_Memory_Initialization_Format 8

all: mon.mem

.PRECIOUS: %.bin

%.z80: %.asm
	../../../z80-asm-2.4.1/z80-asm -l -w $< $@

FOO=$(@)
%.bin: %.z80
	@if [ "$(FOO)" = "mon.bin" ]; then \
		dd if=$< of=$@ ibs=10 skip=1 ;\
	else \
		dd if=$< of=$@ ibs=1034 skip=1 ;\
	fi



%.hex: %.bin
	srec_cat -address-length=2 -Output_Block_Size=8 $< -Binary -offset 0x0400 -o $@ -Intel

%.mem: %.bin
	srec_cat -address-length=2 -Output_Block_Size=8 $< -Binary -o $@ -Lattice_Memory_Initialization_Format 8


clean:
	rm -rf *.bin
	rm -rf *.mem
	rm -rf *.hex
	rm -rf *.z80

