


`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_barrel_shift(
	input [31:0] inst,
	input [31:0] rm_data_in,
	input [31:0] rs_data_in,
	input [31:0] cpsr,
	input is_imm,
	output logic [31:0] operand2,
	output logic potential_cout
);

wire [7:0] dp_imm;
wire [3:0] dp_rotate;
wire [63:0] pre_rotate_imm;
wire [31:0] rotate_imm;
wire [1:0] shift_type;
wire [63:0] double_rm_data_in;
wire [7:0] rs_byte;
wire [4:0] shift_amount;

assign dp_imm = inst[7:0];
assign dp_rotate = inst[11:8];
assign pre_rotate_imm = {2{24'b0, dp_imm}};
assign rotate_imm = pre_rotate_imm[dp_rotate + dp_rotate + 31 -: 32];

assign shift_type = inst[6:5];
assign shift_fmt = inst[4];
assign shift_amount = inst[11:7];

assign double_rm_data_in = {2{rm_data_in}};

assign rs_byte = rs_data_in[7:0];
assign rs_by_32 = rs_byte % 32;

always_comb begin
	if (is_imm) begin
		operand2 = rotate_imm;
		potential_cout = rotate_imm[31];	//not sure about this
	end else begin
		if (shift_fmt == 1'b0) begin	//instruction specified shift amount 
			case (shift_type)
				`OPS_SLL: begin
					 // Corner case: LSL #0
					potential_cout = (shift_amount == 0) ? cpsr[29] : rm_data_in[31 - (shift_amount - 1)];
					operand2 = rm_data_in << shift_amount;
				end
				`OPS_SLR: begin
					// Corner case: LSR #0 => LSR #32
					potential_cout = (shift_amount == 0) ? rm_data_in[31] : rm_data_in[shift_amount - 1];
					operand2 = rm_data_in >> shift_amount;
				end
				`OPS_SAR: begin
					// Corner case: ASR #0 => ASR #32
					potential_cout = (shift_amount == 0) ? rm_data_in[31] : rm_data_in[shift_amount - 1];
					operand2 = (shift_amount == 0) ? {32{rm_data_in[31]}} : signed'(signed'(rm_data_in) >>> shift_amount);
				end
				default: begin	//`OPS_ROR
					// Corner case ROR #0 => RRX
					potential_cout = (shift_amount == 0) ? rm_data_in[0] : rm_data_in[shift_amount - 1];
					operand2 = (shift_amount == 0) ? {cpsr[29], rm_data_in[30:0]} : double_rm_data_in[31 + shift_amount -: 32]; 
				end
			endcase
		end else begin		// register specified shift amount
			if (rs_byte == 8'b0) begin
				potential_cout = cpsr[29];
				operand2 = rm_data_in;
			end else if (rs_byte == 32) begin
				case(shift_type)
					`OPS_SLL: begin
						potential_cout = rm_data_in[0];
						operand2 = 0;
					end
					`OPS_SLR: begin
						potential_cout = rm_data_in[31];
						operand2 = 0;
					end
					`OPS_SAR: begin
						potential_cout = rm_data_in[31];
						operand2 = {32{rm_data_in[31]}};
					end
					default: begin	//`OPS_ROR
						potential_cout = rm_data_in[31];
						operand2 = rm_data_in;
					end
				endcase
			end else if (rs_byte > 32) begin
				case (shift_type)
					`OPS_SLL: begin
						potential_cout = 0;
						operand2 = 0;
					end
					`OPS_SLR: begin
						potential_cout = 0;
						operand2 = 0;
					end
					`OPS_SAR: begin
						potential_cout = rm_data_in[31];
						operand2 = {32{rm_data_in[31]}};
					end
					`OPS_ROR: begin
						potential_cout = rm_data_in[rs_by_32 - 1];
						operand2 = double_rm_data_in[31 + rs_by_32 -: 32];
					end
				endcase
			end else begin
				case (shift_type)
					`OPS_SLL: begin
						potential_cout = rm_data_in[31 - (rs_byte - 1)];
						operand2 = rm_data_in << shift_amount;
					end
					`OPS_SLR: begin
						potential_cout = rm_data_in[rs_byte - 1];
						operand2 = rm_data_in >> shift_amount;
					end
					`OPS_SAR: begin
						potential_cout = rm_data_in[rs_byte - 1];
						operand2 = rm_data_in >>> shift_amount;
					end
					default: begin	//`OPS_ROR
						potential_cout = rm_data_in[rs_byte - 1];
						operand2 = double_rm_data_in[31 + rs_byte -: 32]; 
					end
				endcase
			end
		end
	end
end
endmodule
