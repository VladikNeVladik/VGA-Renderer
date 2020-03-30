# No Copyright. Vladislav Aleinik, 2020
# Render Classical VGA Stripes Into Video Memory
.text
.globl _start
.globl _hex_counter
.globl _finish

_start:
# {
	li s0, 0xEEEE0000 # addr = 0xEEEE0000 
	# sll t0, t0, 20

	li s1, 0 # y = 0
	_render_line:
	# {
		li s2, 0 # x = 0
		_render_pixel:
		# {
			mv t0, s2     
			srl t0, t0, 3 # rgb = x >> 3;

			sw t0, 0(s0) # *addr = rgb;

			addi s0, s0, 1 # addr += 1;
			addi s2, s2, 1 # x += 1;

			li a2, 160
			blt s2, a2, _render_pixel # if (x < 160) goto _render_pixel;
		# }

		addi s1, s1, 1 # y += 1
		
		li a1, 120
		blt s1, a1, _render_line # if (y < 120) goto _render_line;
	# }

	j _hex_counter
# }

_hex_counter:
# {
	li a0, 0
	_render_val_cycle:
	# {
		call _render_short
		addi a0, a0, 1

		li t2, 0xFFFF
		bne a0, t2, _render_val_cycle
	# }
	j _hex_counter
# }

_render_short:
# {
	li t0, 0x0
	sh a0, 0x100(t0)

	li t0, 0x0
	__render_short_wait:
	# {
		addi t0, t0, 0x400
		bnez t0, __render_short_wait
	# }

	ret
# }

_finish:
# {
	j _finish
# }

