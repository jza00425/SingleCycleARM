library verilog;
use verilog.vl_types.all;
entity arm_control is
    port(
        inst            : in     vl_logic_vector(31 downto 0);
        reg_we          : in     vl_logic;
        cpsr_out        : in     vl_logic_vector(31 downto 0);
        rd_we           : out    vl_logic;
        pc_we           : out    vl_logic;
        cpsr_we         : out    vl_logic;
        rn_sel          : out    vl_logic;
        rd_sel          : out    vl_logic_vector(1 downto 0);
        rd_data_sel     : out    vl_logic_vector(1 downto 0);
        pc_in_sel       : out    vl_logic_vector(1 downto 0);
        halted          : out    vl_logic;
        is_imm          : out    vl_logic;
        mem_write_en    : out    vl_logic_vector(3 downto 0);
        ld_byte_or_word : out    vl_logic;
        alu_or_mac      : out    vl_logic;
        up_down         : out    vl_logic;
        mac_sel         : out    vl_logic;
        is_for_store    : out    vl_logic;
        is_alu_for_mem_addr: out    vl_logic
    );
end arm_control;
