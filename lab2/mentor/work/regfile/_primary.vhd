library verilog;
use verilog.vl_types.all;
entity regfile is
    generic(
        text_start      : integer := 4194304
    );
    port(
        rn_data         : out    vl_logic_vector(31 downto 0);
        rm_data         : out    vl_logic_vector(31 downto 0);
        rs_data         : out    vl_logic_vector(31 downto 0);
        pc_out          : out    vl_logic_vector(31 downto 0);
        cpsr_out        : out    vl_logic_vector(31 downto 0);
        rn_num          : in     vl_logic_vector(3 downto 0);
        rm_num          : in     vl_logic_vector(3 downto 0);
        rs_num          : in     vl_logic_vector(3 downto 0);
        rd_num          : in     vl_logic_vector(3 downto 0);
        rd_data         : in     vl_logic_vector(31 downto 0);
        rd_we           : in     vl_logic;
        pc_in           : in     vl_logic_vector(31 downto 0);
        pc_we           : in     vl_logic;
        cpsr_in         : in     vl_logic_vector(31 downto 0);
        cpsr_we         : in     vl_logic;
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        halted          : in     vl_logic
    );
end regfile;
