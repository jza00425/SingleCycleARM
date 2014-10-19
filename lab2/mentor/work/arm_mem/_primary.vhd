library verilog;
use verilog.vl_types.all;
entity arm_mem is
    generic(
        data_start      : integer := 268435456;
        data_words      : integer := 262144;
        text_start      : integer := 4194304;
        text_words      : integer := 65536;
      --stack_top       : integer type with unrepresentable value!
        stack_words     : integer := 65536;
      --kdata_start     : integer type with unrepresentable value!
        kdata_words     : integer := 262144;
      --ktext_start     : integer type with unrepresentable value!
        ktext_words     : integer := 16384
    );
    port(
        addr1           : in     vl_logic_vector(29 downto 0);
        data_in1        : in     vl_logic_vector(31 downto 0);
        data_out1       : out    vl_logic_vector(31 downto 0);
        we1             : in     vl_logic_vector(0 to 3);
        excpt1          : out    vl_logic;
        allow_kernel1   : in     vl_logic;
        kernel1         : out    vl_logic;
        addr2           : in     vl_logic_vector(29 downto 0);
        data_in2        : in     vl_logic_vector(31 downto 0);
        data_out2       : out    vl_logic_vector(31 downto 0);
        we2             : in     vl_logic_vector(0 to 3);
        excpt2          : out    vl_logic;
        allow_kernel2   : in     vl_logic;
        kernel2         : out    vl_logic;
        rst_b           : in     vl_logic;
        clk             : in     vl_logic
    );
end arm_mem;
