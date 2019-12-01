# set these as per your layout
# top module must be called the same as the folder
# this makefile is in (this is the project "name")

# ------------------------
WD:=`pwd`

BASEPATH:=..
YOSYSPATH:=$(BASEPATH)/yosys
NEXTPNR:=$(BASEPATH)/nextpnr
TRELLISPATH:=$(BASEPATH)/prjtrellis/

# ------------------------


#PRJNAME:=$(shell basename `pwd`)
PRJNAME:=Z80

.PHONY: all test

all: $(PRJNAME).bit

test: $(PRJNAME)_tb.vcd

.PHONY: clean
clean:
	rm -rf $(PRJNAME).json
	rm -rf $(PRJNAME)_out.config
	rm -rf $(PRJNAME).bit
	rm -rf $(PRJNAME).svf
	rm -rf $(PRJNAME)_tb.vcd
	rm -rf $(PRJNAME)_tb.vpp

asm/mon.z80: asm/mon.asm
	../../z80-asm-2.4.1/z80-asm -l -w asm/mon.asm asm/mon.z80

asm/mon.bin: asm/mon.z80
	dd if=asm/mon.z80 of=asm/mon.bin ibs=10 skip=1


ram.mem: asm/mon.bin
	./asm/bin2mem asm/mon.bin ram.mem


$(PRJNAME).bit: $(PRJNAME)_out.config
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(TRELLISPATH)/libtrellis \
		$(TRELLISPATH)/libtrellis/ecppack $(PRJNAME)_out.config $(PRJNAME).bit \
		--db $(TRELLISPATH)/database \
		--compress

$(PRJNAME)_out.config: $(PRJNAME).json
	$(NEXTPNR)/nextpnr-ecp5 --45k --json $(PRJNAME).json \
		--lpf ulx3s_v20.lpf \
		--textcfg $(WD)/$(PRJNAME)_out.config \
		--package CABGA381 \
		--freq 25

$(PRJNAME).json: *.v video/*.v ram.mem
	$(YOSYSPATH)/yosys $(PRJNAME).ys



