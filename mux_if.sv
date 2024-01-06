`ifndef MUX_IF_SV
`define MUX_IF_SV
`include "ahb_if.sv"

interface mux_if #(
     parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int NMANAGERS = 3
) ();

    logic HCLK;
    logic HRESETn;

    virtual ahb_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) managers[NMANAGERS];

    ahb_if #( .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) mux_out();

endinterface
`endif