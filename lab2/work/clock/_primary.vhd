library verilog;
use verilog.vl_types.all;
entity clock is
    generic(
        start           : integer := 0;
        halfPeriod      : integer := 50
    );
    port(
        clockSignal     : out    vl_logic
    );
end clock;
