CC      = riscv64-linux-gnu-gcc
AS      = riscv64-linux-gnu-as
LD      = riscv64-linux-gnu-ld
OBJCOPY = riscv64-linux-gnu-objcopy
OBJDUMP = riscv64-linux-gnu-objdump

SRCS=$(wildcard *.asm)
TXTS=$(SRCS:%.s=%.mem)

all : ${TXTS}

%.hex: %.bin
	hexdump -v -e '"%08x\n"' $^ > $@

%.bin: %.out
	$(OBJCOPY) -O binary $^ $@

%.out: %.o
	$(LD) -melf32lriscv --section-start=.text=0x2000 $^ -o $@ && $(OBJDUMP) -d $@

%.o: %.asm
	$(AS) -c -fPIC -march=rv32i -mabi=ilp32 -c $^ -o $@

%.asm: %.c
	${CC} -c -fPIC -Ttext=0x2000 -fno-plt -march=rv32i -mabi=ilp32 -O1 -S $^ -o $@
	printf "\t.text\n_start:\n\tcall main\n\n"|cat - $@ > /tmp/out && mv /tmp/out $@ 

.PHONY: all clean

.PRECIOUS: %.o %.out %.bin

clean:
	rm -f *.o *.out *.bin *.mem
