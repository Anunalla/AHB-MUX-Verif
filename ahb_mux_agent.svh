`ifndef AHB_MUX_AGENT_SVH
`define AHB_MUX_AGENT_SVH

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_mux_sequencer.svh"
`include "ahb_mux_driver.svh"
`include "ahb_mux_monitor.svh"

class ahb_mux_agent extends uvm_agent;
  `uvm_component_utils(ahb_mux_agent)
  sequencer sqr;
  ahb_mux_driver ahb_drv;
  ahb_mux_monitor ahb_mon;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    sqr = sequencer::type_id::create("sqr", this);
    ahb_drv = ahb_mux_driver::type_id::create("ahb_drv", this);
    ahb_mon = ahb_mux_monitor::type_id::create("ahb_mon", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    ahb_drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass : ahb_mux_agent

`endif
