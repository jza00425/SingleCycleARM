library verilog;
use verilog.vl_types.all;
entity arm_core is
    port(
        inst_addr       : out    vl_logic_vector(29 downto 0);
        mem_addr        : out    vl_logic_vector(29 downto 0);
        mem_data_in     : out    vl_logic_vector(31 downto 0);
        mem_write_en    : out    vl_logic_vector(3 downto 0);
        halted          : out    vl_logic;
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        inst            : in     vl_logic_vector(31 downto 0);
        mem_data_out    : in     vl_logic_vector(31 downto 0)
    );
end arm_core;
