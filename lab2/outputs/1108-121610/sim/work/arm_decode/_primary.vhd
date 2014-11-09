library verilog;
use verilog.vl_types.all;
entity arm_decode is
    port(
        reg_we          : out    vl_logic;
        cpsr_mask       : out    vl_logic_vector(3 downto 0);
        alu_sel         : out    vl_logic_vector(3 downto 0);
        swi             : out    vl_logic;
        inst            : in     vl_logic_vector(31 downto 0)
    );
end arm_decode;
