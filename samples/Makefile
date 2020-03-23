AS      = riscv64-linux-gnu-as
LD      = riscv64-linux-gnu-ld
OBJCOPY = riscv64-linux-gnu-objcopy
OBJDUMP = riscv64-linux-gnu-objdump

SRCS=$(wildcard *.s)
TXTS=$(SRCS:%.s=%.mem)

all : ${TXTS}

%.mem: %.bin
	hexdump -v -e '"%08x\n"' $^ > $@

%.bin: %.out
	$(OBJCOPY) -O binary $^ $@

%.out: %.o
	$(LD) -melf32lriscv $^ -o $@ && $(OBJDUMP) -d $@

%.o: %.s
	$(AS) -march=rv32i -mabi=ilp32 -c $^ -o $@

.PHONY: all clean

.PRECIOUS: %.o %.out %.bin

clean:
	rm -f *.o *.out *.bin *.mem
