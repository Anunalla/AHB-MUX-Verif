`ifndef TRANSACTION_SVH
`define TRANSACTION_SVH

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "dutMUX_params.svh"

class ahb_mux_transaction_v2 extends uvm_sequence_item;

  // Address phase items
  rand bit [`AHB_MUX_NMANAGERS-1:0][`AHB_ADDR_WIDTH-1:0] haddr;
  rand bit [`AHB_MUX_NMANAGERS-1:0][`AHB_DATA_WIDTH-1:0] hwdata;
  rand bit [`AHB_MUX_NMANAGERS-1:0][(`AHB_DATA_WIDTH/8)-1:0] hwstrb;
  logic [1:0] htrans; // transaction type
  logic [`AHB_MUX_NMANAGERS-1:0] hwrite;
  
  logic rw;
  rand bit idle;  // 0 --> not idle transfer, 1 --> idle transfer

  rand bit [1:0] burstType; // 0 --> wrapping, 1 --> incrementing, 2 --> undefined length incrementing, 3 --> single transfer

  rand bit [6:0] burstLength; // For an undefined length incrementing burst transfer we actually define the length within the testbench

  rand bit [1:0] burstSize;  // 0 --> 4, 1 --> 8, 2 --> 16

  rand bit [1:0] hsize;  // 0 --> byte transfer, 1 --> halfword transfer, 2 --> word transfer
  bit hsel; // This indicates whether we should even select this subordinate regardless of the rest of the transfer
  

  // Data phase items
  bit [`AHB_MUX_NMANAGERS-1:0][`AHB_DATA_WIDTH-1:0] hrdata_out;
  bit [`AHB_MUX_NMANAGERS-1:0] hready_timeout;  // indicated that hready had a timeout

   
  bit reset_unit; // Indicates whether you want to reset the unit
  
  logic [$clog2(`AHB_MUX_NMANAGERS)-1:0] num_active_managers;
  logic [`AHB_MUX_NMANAGERS-1:0] index_active_managers; //one-hot encoded mask showing which managers are requesting for transfer

  bit [`AHB_ADDR_WIDTH-1:0] haddr_mout;
  bit [`AHB_DATA_WIDTH-1:0] hwdata_mout;
  bit [(`AHB_DATA_WIDTH/8)-1:0] hwstrb_mout;
  bit hreadyout_mout;

  constraint bursts {
    burstType < 4;
    burstSize < 4;
  }
  ;
  constraint sizes {hsize < 3;}
  ;
  constraint haddrs {haddr > 0;};
  // constraint hdatas {hwdata > 0;};

  //TODO: YOU MAY WANT TO RECONSIDER HOW MANY OF THESE FIELDS YOU INCLUDE FOR PRINTING
  // NOTE: EXAMPLE OF NOT PRINTING CERTAIN FIELDS BELOW
  // `uvm_field_int(haddr, UVM_NOCOMPARE | UVM_NOPRINT)

  `uvm_object_utils_begin(ahb_mux_transaction_v2)
    `uvm_field_int(haddr, UVM_NOCOMPARE)
    `uvm_field_sarray_int(hwdata, UVM_NOCOMPARE)
    `uvm_field_sarray_int(hwstrb, UVM_NOCOMPARE)
    `uvm_field_int(rw, UVM_NOCOMPARE)
    `uvm_field_int(idle, UVM_NOCOMPARE)
    `uvm_field_int(burstType, UVM_NOCOMPARE)
    `uvm_field_int(burstLength, UVM_NOCOMPARE)
    `uvm_field_int(burstSize, UVM_NOCOMPARE)
    `uvm_field_int(hsel, UVM_NOCOMPARE)
    `uvm_field_int(hsize, UVM_NOCOMPARE)
  // `uvm_field_int(hresp_out, UVM_DEFAULT)
    `uvm_field_int(hrdata_out, UVM_DEFAULT)
    `uvm_field_int(haddr_mout, UVM_DEFAULT)
    `uvm_field_int(hwdata_mout, UVM_DEFAULT)
    `uvm_field_int(hwstrb_mout, UVM_DEFAULT)
    `uvm_field_int(reset_unit, UVM_NOCOMPARE)
    `uvm_field_int(htrans, UVM_NOCOMPARE)
    `uvm_field_int(num_active_managers, UVM_NOCOMPARE)
    `uvm_field_int(index_active_managers, UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "ahb_mux_transaction_v2");
    super.new(name);
  endfunction : new

endclass : ahb_mux_transaction_v2

`endif
