/*
 *
 * Redistributions of any form whatsoever must retain and/or include the
 * following acknowledgment, notices and disclaimer:
 *
 * This product includes software developed by Carnegie Mellon University.
 *
 * Copyright (c) 2004 by Babak Falsafi and James Hoe,
 * Computer Architecture Lab at Carnegie Mellon (CALCM),
 * Carnegie Mellon University.
 *
 * This source file was modified by Xiao Bo Zhao for the class 18-447 in
 * order to meet the requirements of an ARM processor.
 *
 * You may not use the name "Carnegie Mellon University" or derivations
 * thereof to endorse or promote products derived from this software.
 *
 * If you modify the software you must place a notice on or within any
 * modified version provided or made available to any third party stating
 * that you have modified the software.  The notice shall include at least
 * your name, address, phone number, email address and the date and purpose
 * of the modification.
 *
 * THE SOFTWARE IS PROVIDED "AS-IS" WITHOUT ANY WARRANTY OF ANY KIND, EITHER
 * EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO ANYWARRANTY
 * THAT THE SOFTWARE WILL CONFORM TO SPECIFICATIONS OR BE ERROR-FREE AND ANY
 * IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE, OR NON-INFRINGEMENT.  IN NO EVENT SHALL CARNEGIE MELLON UNIVERSITY
 * BE LIABLE FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO DIRECT, INDIRECT,
 * SPECIAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF, RESULTING FROM, OR IN
 * ANY WAY CONNECTED WITH THIS SOFTWARE (WHETHER OR NOT BASED UPON WARRANTY,
 * CONTRACT, TORT OR OTHERWISE).
 *
 */

//////
////// ARM 447: A single-cycle ARM ISA simulator
//////

// Include the ARM constants
`include "arm_defines.vh"
`include "internal_defines.vh"

////
//// The ARM standalone processor module
////
////   clk          (input)  - The clock
////   inst_addr    (output) - Address of instruction to load
////   inst         (input)  - Instruction from memory
////   mem_addr     (output) - Address of data to load
////   mem_data_in  (output) - Data for memory store
////   mem_data_out (input)  - Data from memory load
////   mem_write_en (output) - Memory write mask
////   halted       (output) - Processor halted
////   rst_b        (input)  - Reset the processor
////

module arm_core (
  // Outputs
  inst_addr, mem_addr, mem_data_in, mem_write_en, halted,
  // Inputs
  clk, rst_b, inst, mem_data_out
);

  // Core Interface
  input         clk, rst_b;
  output [29:0] inst_addr;
  output [29:0] mem_addr;
  input  [31:0] inst, mem_data_out;
  output [31:0] mem_data_in;
  output [3:0]  mem_write_en;
  output        halted;

  wire rd_we, pc_we, cpsr_we, rn_sel, reg_we, dcd_swi;
  wire is_imm, is_alu_for_mem_addr, ld_byte_or_word, alu_or_mac, up_down, mac_sel, is_for_store;
  wire [1:0] rd_sel, rd_data_sel, pc_in_sel;

  wire [3:0] rn_num, rm_num, rs_num, rd_num;
  logic [31:0] rd_data;
  logic [31:0] cpsr_in;		//need more work
  wire [31:0] alu_out;
  wire [31:0] mac_out;
  wire [31:0] pc_out;
  wire [31:0] pc_in;
  wire [31:0] branch_addr;
  wire [31:0] data_result;
  wire [31:0] rn_data, rm_data, rs_data, cpsr_out, operand2;
  wire potential_cout;
  wire [4:0] word_offset;
  wire [31:0] modified_mem_data_out;
  wire [63:0] for_modified_mem_data_out; 
  wire [3:0] alu_cpsr;
  wire [3:0] alu_sel;
  wire [3:0] mac_cpsr;
  wire [3:0] alu_cpsr_mask;
  wire [3:0] tmp_cpsr;
  wire [3:0] final_cpsr_mask;

  wire [3:0]    dcd_rn, dcd_rd, dcd_rm;
  wire [3:0]    dcd_mul_rn, dcd_mul_rd, dcd_mul_rs;

  wire [7:0]    dcd_dp_imm;
  wire [3:0]    dcd_dp_rotate;

  wire          dcd_shift_fmt;
  wire [1:0]    dcd_shift_type;
  wire [4:0]    dcd_shift_amt;
  wire [3:0]    dcd_shift_rs;
  wire [11:0]   dcd_sdt_offset;
  wire [23:0]   dcd_br_offset;
  wire [23:0]   dcd_swi_offset;

/***** not sure if branch_addr should pc + 8 or pc + 4*****/
  assign branch_addr = pc_out + 8 + ((inst[21] == 1) ? {8'hff, inst[21:0], 2'b00} : {8'h00, inst[21:0], 2'b00});

  assign inst_addr = pc_out[31:2];

  assign rn_num = (rn_sel) ? dcd_rn : dcd_mul_rn;
  assign rm_num = inst[3:0];
  assign rs_num = (is_for_store) ? inst[15:12] : inst[11:8];
  assign mem_data_in = rs_data; 	//only happens STR instruction, we borrow rs to represent source register
  assign rd_num = (rd_sel == 2) ? `R_LR : ((rd_sel == 1) ? dcd_rd : dcd_mul_rd);
  assign pc_in = (pc_in_sel == 2) ? pc_out : ((pc_in_sel == 1) ? (pc_out + 4) : branch_addr);
  assign data_result = (alu_or_mac) ? alu_out : mac_out;
  assign mem_addr = alu_out >> 2;
  assign word_offset = {3'b0, alu_out[1:0]} << 3; 
  assign for_modified_mem_data_out = {2{mem_data_out}};
  assign modified_mem_data_out = for_modified_mem_data_out[word_offset + 31 -: 32];
  assign final_cpsr_mask = (alu_or_mac) ? alu_cpsr_mask : 4'b1100;
  assign tmp_cpsr = (alu_or_mac) ? alu_cpsr : mac_cpsr; 
  assign cpsr_in = ({~final_cpsr_mask, 28'hfffffff} & cpsr_out) | {(final_cpsr_mask & tmp_cpsr), 28'h0};

  always_comb begin
	  if(rd_data_sel == 2) begin
		  rd_data = (ld_byte_or_word) ? {24'b0, modified_mem_data_out[7:0]} : modified_mem_data_out;
	  end else begin
		  rd_data = (rd_data_sel == 1) ? data_result : (pc_out + 4);
	  end
  end

  arm_alu my_alu(
	  .alu_out(alu_out), 
	  .alu_cpsr(alu_cpsr), 
	  .alu_op1(rn_data), 
	  .alu_op2(operand2), 
	  .alu_sel(alu_sel),
	  .alu_cin(cpsr_out[29]),
	  .is_alu_for_mem_addr(is_alu_for_mem_addr), 
	  .up_down(up_down),
	  .potential_cout(potential_cout)
  );

  arm_decode decoder(
	  .reg_we(reg_we),
	  .cpsr_mask(alu_cpsr_mask),
	  .alu_sel(alu_sel),
	  .swi(dcd_swi),
	  .inst(inst)
  );


  arm_control ctrl(
	  .inst(inst),
	  .reg_we(reg_we),
	  .cpsr_out(cpsr_out),
	  .rd_we(rd_we),
	  .pc_we(pc_we),
	  .cpsr_we(cpsr_we),
	  .rn_sel(rn_sel),
	  .rd_sel(rd_sel),
	  .rd_data_sel(rd_data_sel),
	  .pc_in_sel(pc_in_sel),
	  .halted(halted),
	  .is_imm(is_imm),
	  .mem_write_en(mem_write_en),
	  .ld_byte_or_word(ld_byte_or_word),
	  .alu_or_mac(alu_or_mac),
	  .up_down(up_down),
	  .mac_sel(mac_sel),
	  .is_for_store(is_for_store),
	  .is_alu_for_mem_addr(is_alu_for_mem_addr)
  );

  arm_mac my_mac(
	  .mac_out(mac_out), 
	  .mac_cpsr(mac_cpsr),
	  .mac_op1(rm_data), 
	  .mac_op2(rs_data), 
	  .mac_acc(rn_data), 
	  .mac_sel(mac_sel)
  );

  regfile register(
	  .rn_data(rn_data),
	  .rm_data(rm_data),
	  .rs_data(rs_data),
	  .pc_out(pc_out),
	  .cpsr_out(cpsr_out),
	  .rn_num(rn_num),
	  .rm_num(rm_num),
	  .rs_num(rs_num),
	  .rd_num(rd_num),
	  .rd_data(rd_data),
	  .rd_we(rd_we),
	  .pc_in(pc_in),
	  .pc_we(pc_we),
	  .cpsr_in(cpsr_in),
	  .cpsr_we(cpsr_we),
	  .clk(clk),
	  .rst_b(rst_b),
	  .halted(halted)
  );

  arm_barrel_shift shifter(
	  .inst(inst),
	  .rm_data_in(rm_data),
	  .rs_data_in(rs_data),
	  .cpsr(cpsr_out),
	  .is_imm(is_imm),
	  .operand2(operand2),
	  .potential_cout(potential_cout)
  );
  

  assign        dcd_rn = inst[19:16];
  assign        dcd_rd = inst[15:12];

  // Multiply reverses rd/rn
  assign        dcd_mul_rd = inst[19:16];
  assign        dcd_mul_rn = inst[15:12];
  assign        dcd_mul_rs = inst[11:8];

  assign        dcd_dp_imm = inst[7:0];
  assign        dcd_dp_rotate = inst[11:8];

  assign        dcd_shift_fmt = inst[4];
  assign        dcd_shift_type = inst[6:5];
  assign        dcd_shift_amt = inst[11:7];
  assign        dcd_shift_rs = inst[11:8];
  assign        dcd_sdt_offset = inst[11:0];
  assign        dcd_br_offset = inst[23:0];
  assign        dcd_swi_offset = inst[23:0];


  // synthesis translate_off
  //synopsys translate_off
  always_ff @(posedge clk) begin
    // useful for debugging, you will want to comment this out for long programs
    if (rst_b) begin
      $display ( "=== Simulation Cycle %d ===", $time );
      $display ( "[pc=%x, inst=%x] [reset=%d, halted=%d]",
                   pc_out, inst, ~rst_b, halted);
    end
  end
  //synopsys translate_on
  // synthesis translate_on

  // // synthesis translate_off
  // //synopsys translate_off
  // initial begin
  //   // Delete this block when you are ready to try for real
  //   $display("");
  //   $display("");
  //   $display("");
  //   $display("");
  //   $display(">>>>> This works much better after you have hooked up the reg file. <<<<<");
  //   $display("");
  //   $display("");
  //   $display("");
  //   $display("");
  //   $finish;
  // end
  // //synopsys translate_on
  // // synthesis translate_on


  wire          syscall_halt, internal_halt;

  assign        syscall_halt = dcd_swi && (dcd_swi_offset == `SWI_EXIT);

  assign        internal_halt = syscall_halt;

  register #(1, 0) Halt(halted, internal_halt, clk, 1'b1, rst_b);

endmodule // arm_core


////
//// arm_alu: Performs all arithmetic and logical operations
////
//// alu_out  (output) - Final result
//// alu_cout (output) - Carry out
//// alu_op1  (input)  - Operand modified by the operation
//// alu_op2  (input)  - Operand used (in arithmetic ops) to modify op1
//// alu_sel  (input)  - Selects which operation is to be performed
//// alu_cin  (input)  - Carry in
////
module arm_alu(alu_out, alu_cpsr, alu_op1, alu_op2, alu_sel, alu_cin, is_alu_for_mem_addr, up_down, potential_cout);

  output      [31:0]  alu_out;
  output      [3:0]  alu_cpsr;
  // input  signed     [31:0]  alu_op1, alu_op2;
  input  [31:0]  alu_op1, alu_op2;
  input       [3:0]   alu_sel;
  input               alu_cin;
  input		      is_alu_for_mem_addr;
  input 	      up_down;
  input 	      potential_cout;

  // logic signed [31:0] result;
  logic [31:0] result;
  logic cout;
  logic n_flag, z_flag, c_flag, v_flag;

  assign carry_in = {31'd0, alu_cin};
  assign alu_out = result;
  assign alu_cpsr = {n_flag, z_flag, c_flag, v_flag};

  always_comb begin
	  if (is_alu_for_mem_addr == 1) begin
		  result = (up_down) ? (unsigned'(alu_op1) + unsigned'(alu_op2)) : (unsigned'(alu_op1) - unsigned'(alu_op2));
		  n_flag = 1'bx; z_flag = 1'bx; c_flag = 1'bx; v_flag = 1'bx;
	  end else begin
		  case(alu_sel)
			  `OPD_AND: {cout, result} = alu_op1 & alu_op2;
			  `OPD_EOR: {cout, result} = alu_op1 ^ alu_op2;
			  `OPD_SUB: {cout, result} = alu_op1 - alu_op2;
			  // `OPD_SUB: signed'({cout, result}) = signed'(alu_op1) - signed'(alu_op2);
			  `OPD_RSB: {cout, result} = alu_op2 - alu_op1;
			  `OPD_ADD: {cout, result} = alu_op1 + alu_op2;
			  `OPD_ADC: {cout, result} = alu_op1 + alu_op2 + carry_in;
			  `OPD_SBC: {cout, result} = alu_op1 - alu_op2 + carry_in - 1;
			  `OPD_RSC: {cout, result} = alu_op2 - alu_op1 + carry_in - 1;
			  `OPD_TST: {cout, result} = alu_op1 & alu_op2;
			  `OPD_TEQ: {cout, result} = alu_op1 ^ alu_op2;
			  `OPD_CMP: {cout, result} = alu_op1 - alu_op2;
			  `OPD_CMN: {cout, result} = alu_op1 + alu_op2;
			  `OPD_ORR: {cout, result} = alu_op1 | alu_op2;
			  `OPD_MOV: {cout, result} = alu_op2;
			  `OPD_BIC: {cout, result} = alu_op1 & ~alu_op2;
			  `OPD_MVN: {cout, result} = ~alu_op2;
		  endcase

		  case(alu_sel)
			  `OPD_AND, `OPD_EOR, `OPD_TST, `OPD_TEQ, `OPD_ORR, `OPD_MOV, `OPD_BIC, `OPD_MVN: begin
				  n_flag = (result[31] == 1) ? 1 : 0;
				  z_flag = (result == 32'b0) ? 1 : 0;
				  c_flag = potential_cout;
				  v_flag = 1'bx;
			  end
			  `OPD_SUB, `OPD_SBC, `OPD_CMP: begin
				  n_flag = (result[31] == 1) ? 1 : 0;
				  z_flag = (result == 32'b0) ? 1 : 0;
				  c_flag = cout;
				  if (((alu_op1[31] == 1) && (alu_op2[31] == 0) && (result[31] == 0)) ||
				      ((alu_op1[31] == 0) && (alu_op2[31] == 1) && (result[31] == 1)))
				  	  v_flag = 1;
				  else  
					  v_flag = 0;
			  end
			  `OPD_RSB, `OPD_RSC: begin
				  n_flag = (result[31] == 1) ? 1 : 0;
				  z_flag = (result == 32'b0) ? 1 : 0;
				  c_flag = cout;
				  if (((alu_op1[31] == 1) && (alu_op2[31] == 0) && (result[31] == 1)) ||
				      ((alu_op1[31] == 0) && (alu_op2[31] == 1) && (result[31] == 0)))
				  	  v_flag = 1;
				  else  
					  v_flag = 0;
			  end
			  // `OPD_ADD, `OPD_ADC, `OPD_CMN: begin
			  default: begin
				  n_flag = (result[31] == 1) ? 1 : 0;
				  z_flag = (result == 32'b0) ? 1 : 0;
				  c_flag = cout;
				  if (((alu_op1[31] == 0) && (alu_op2[31] == 0) && (result[31] == 1)) ||
				      ((alu_op1[31] == 1) && (alu_op2[31] == 1) && (result[31] == 0)))
				  	  v_flag = 1;
				  else  
					  v_flag = 0;
			  end
		  endcase
	  end
  end

endmodule

////
//// arm_mac: Performs multiply accumulate operations
////
//// mac_out  (output) - Final result
//// mac_op1  (input)  - Operand modified by the operation
//// mac_op2  (input)  - Operand used to multiply op1
//// mac_acc  (input)  - Accumulator
//// mac_sel  (input)  - Selects whether to accumulate
////
module arm_mac(mac_out, mac_cpsr, mac_op1, mac_op2, mac_acc, mac_sel);

  output reg  [31:0]  mac_out;
  output      [3:0]   mac_cpsr;
  input       [31:0]  mac_op1, mac_op2, mac_acc;
  input               mac_sel;

  logic	      [31:0]  result;
  logic	      [31:0]  high32;
  logic		      n_flag, z_flag, v_flag, c_flag;

  assign mac_out = result;
  assign mac_cpsr = {n_flag, z_flag, v_flag, c_flag};
  always_comb begin
	  if (mac_sel == 1'b1) begin
		  {high32, result} = mac_op1 * mac_op2  + mac_acc;
	  end else begin
		  {high32, result} = mac_op1 * mac_op2;
	  end
	  n_flag = (result[31] == 1) ? 1 : 0;
	  z_flag = (result == 0) ? 1 : 0;
	  c_flag = 1'bx;
	  v_flag = 1'bx;
  end

endmodule


//// register: A register which may be reset to an arbirary value
////
//// q      (output) - Current value of register
//// d      (input)  - Next value of register
//// clk    (input)  - Clock (positive edge-sensitive)
//// enable (input)  - Load new value?
//// reset  (input)  - System reset
////
module register(q, d, clk, enable, rst_b);

   parameter
            width = 32,
            reset_value = 0;

   output [(width-1):0] q;
   reg [(width-1):0]    q;
   input [(width-1):0]  d;
   input                 clk, enable, rst_b;

   always_ff @(posedge clk or negedge rst_b)
     if (~rst_b)
       q <= reset_value;
     else if (enable)
       q <= d;

endmodule // register
