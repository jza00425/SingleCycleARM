library verilog;
use verilog.vl_types.all;
entity arm_alu is
    port(
        alu_out         : out    vl_logic_vector(31 downto 0);
        alu_cout        : out    vl_logic;
        alu_op1         : in     vl_logic_vector(31 downto 0);
        alu_op2         : in     vl_logic_vector(31 downto 0);
        alu_sel         : in     vl_logic_vector(3 downto 0);
        alu_cin         : in     vl_logic
    );
end arm_alu;
