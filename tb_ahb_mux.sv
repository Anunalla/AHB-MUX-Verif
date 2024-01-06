`include "ahb_mux.sv"
// interface file
`include "ahb_if.sv"
`include "mux_if.sv"

// UVM test file
`include "testAll_mux.svh"

// Include params
`include "dutMUX_params.svh"

`timescale 1ns / 1ns
// import uvm packages
import uvm_pkg::*;

module tb_ahb_mux();
    logic clk;
    logic resetn;

    // generate clock
    initial begin
        clk = 0;
        forever #10 clk = !clk;
    end

    // instantiate the interface
    mux_if # (.ADDR_WIDTH(`AHB_ADDR_WIDTH),
        .DATA_WIDTH(`AHB_DATA_WIDTH),
        .NMANAGERS(`AHB_MUX_NMANAGERS)) my_muxif();
    
    // physical manager interfaces
    ahb_if # (.ADDR_WIDTH(`AHB_ADDR_WIDTH),
        .DATA_WIDTH(`AHB_DATA_WIDTH)) managers_in[`AHB_MUX_NMANAGERS-1:0] ();
    
    assign my_muxif.HCLK = clk;
    
    ahb_mux #(
        .ARBITRATION(`AHB_MUX_ARBITRATION),
        .NMANAGERS(`AHB_MUX_NMANAGERS)
    ) dut_mux( my_muxif.HCLK, my_muxif.HRESETn, managers_in, my_muxif.mux_out
        ); //clk,resetn,ahbif_subordinate, ahbif_manager

    genvar i;
    generate 
        for(i=0; i<`AHB_MUX_NMANAGERS; i++) begin
            assign managers_in[i].HCLK = my_muxif.HCLK;
            assign managers_in[i].HRESETn = my_muxif.HRESETn;
            assign my_muxif.managers[i] = managers_in[i];
        end
        assign my_muxif.mux_out.HCLK = my_muxif.HCLK;;
        assign my_muxif.mux_out.HRESETn = my_muxif.HRESETn;
    endgenerate
    initial begin
        
        uvm_config_db#(virtual mux_if)::set(null, "", "mux_vif",
                                            my_muxif); // configure the interface into the database, so that it can be accessed throughout the hierachy
        run_test("testAll_mux");
    end
endmodule