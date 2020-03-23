PROCESSOR = proc/top.v proc/instr_decoder.v proc/registers.v proc/memory_access_control.v proc/flow_control.v proc/arithmetic_logic_unit.v
DEVICES   = devices/hex_display.v devices/rom_controller.v devices/uart_controller.v devices/vga_controller.v
UTILITY   = utility/window_size_managers.v
TOP       = top.v memory_controller.v

test : simulation.out
	./simulation.out 
	gtkwave dump.vcd 

simulation.out : testbench.v ${PROCESSOR} ${DEVICES} ${UTILITY} ${TOP}
	iverilog $^ -o $@

clean:
	rm -f simulation.out dump.vcd 

samples:
	$(MAKE) -C samples/

.PHONY: clean samples test