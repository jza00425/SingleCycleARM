
module tb;

logic clk;
logic rst_b;
logic [31:0] inst, mem_data_out;

wire [29:0] inst_addr, mem_addr;
wire [31:0] mem_data_in;
wire [3:0] mem_write_en;
wire halted;

always #5 clk = ~clk;

initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, tb);
	clk = 0;
	rst_b = 0;
	inst = 0;
	mem_data_out = 0;
	#7 rst_b = 1;
end

endmodule
