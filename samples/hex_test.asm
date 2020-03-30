# No Copyright. Vladislav Aleinik, 2020
# Hex Counter With MMIO On RISC-V Processor
.text
.globl _start
.globl _finish

_start:
	li a0, 0
	_render_val_cycle:
		call _render_short
		addi a0, a0, 1

		li t2, 0xFFFF
		bne a0, t2, _render_val_cycle
		j _start

_render_short:
	li t0, 0x0
	sh a0, 0x100(t0)

	li t0, 0x0
	__render_short_wait:
		addi t0, t0, 0x400
		bnez t0, __render_short_wait

	ret

_finish:
	nop
	nop
