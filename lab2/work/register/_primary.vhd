library verilog;
use verilog.vl_types.all;
entity \register\ is
    generic(
        width           : integer := 32;
        reset_value     : integer := 0
    );
    port(
        q               : out    vl_logic_vector;
        d               : in     vl_logic_vector;
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        rst_b           : in     vl_logic
    );
end \register\;
