library verilog;
use verilog.vl_types.all;
entity arm_barrel_shift is
    port(
        inst            : in     vl_logic_vector(31 downto 0);
        rm_data_in      : in     vl_logic_vector(31 downto 0);
        rs_data_in      : in     vl_logic_vector(31 downto 0);
        cpsr            : in     vl_logic_vector(31 downto 0);
        is_imm          : in     vl_logic;
        operand2        : out    vl_logic_vector(31 downto 0);
        potential_cout  : out    vl_logic
    );
end arm_barrel_shift;
