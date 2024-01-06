import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_mux_transaction_v2.svh"
`include "dutMUX_params.svh"
import ahb_pkg::*;

class trialSequence extends uvm_sequence #(ahb_mux_transaction_v2);
  `uvm_object_utils(trialSequence)

  function new(input string name = "");
    super.new(name);
  endfunction : new

  task body();
    ahb_mux_transaction_v2 req_item;
    req_item = ahb_mux_transaction_v2::type_id::create("req_item");
    start_item(req_item);
    `uvm_info(this.get_name(), "I am running the trial sequence", UVM_NONE);
    req_item.reset_unit = 0;
    req_item.num_active_managers = 0;
    req_item.idle = 1;
    finish_item(req_item);    
  endtask : body
endclass : trialSequence


class resetSequence extends uvm_sequence #(ahb_mux_transaction_v2);
  `uvm_object_utils(resetSequence)
  function new(input string name = "");
    super.new(name);
  endfunction : new

  task body();
    ahb_mux_transaction_v2 req_item;
    req_item = ahb_mux_transaction_v2::type_id::create("req_item");
    start_item(req_item);
    `uvm_info(this.get_name(), "I am running the reset sequence", UVM_NONE);
    req_item.reset_unit = 1;
    finish_item(req_item);    
  endtask : body
endclass : resetSequence


class writeNONSEQM1 extends uvm_sequence #(ahb_mux_transaction_v2);
  `uvm_object_utils(writeNONSEQM1)
  HTRANS_t my_seq;
  int i;
  
  function new(input string name = "");
    super.new(name);
    my_seq = NONSEQ;
  endfunction : new

  virtual task body();
    ahb_mux_transaction_v2 dummy_item;
    dummy_item = ahb_mux_transaction_v2::type_id::create("dummy_item");
    for(i= 0; i<`AHB_MUX_NMANAGERS; i++) begin
      ahb_mux_transaction_v2 req_item;
      req_item = ahb_mux_transaction_v2::type_id::create("req_item");
      start_item(req_item);
      req_item.randomize();
      req_item.reset_unit = 0;
      req_item.num_active_managers = 1;
      req_item.index_active_managers = '0;
      req_item.index_active_managers[i] = 1;
      req_item.htrans = my_seq;
      req_item.rw = `WRITE;
      req_item.hsize = 2'h2;
      req_item.burstSize = '0;
      req_item.burstType = 3;
      req_item.hwstrb[i] = 4'hF;
      req_item.idle = '0;
      `uvm_info(this.get_name(), $sformatf("1 mamager request a non seq write Manager_Index=%0b",req_item.index_active_managers), UVM_NONE);
      finish_item(req_item);
    end
    
    start_item(dummy_item);
    dummy_item.reset_unit = 0;
    dummy_item.num_active_managers = 1;
    dummy_item.index_active_managers = '0;
    dummy_item.index_active_managers[0] = 1;
    // dummy_item.rw = `WRITE;
    // dummy_item.hsize = 2'h2;
    // dummy_item.burstSize = '0;
    // dummy_item.burstType = '0;
    // dummy_item.hwstrb[0] = 4'hF;
    dummy_item.idle = 1;
    `uvm_info(this.get_name(), "NON SEQ sequence finished; sending an idle sequence", UVM_NONE);
    finish_item(dummy_item);
  endtask : body
endclass : writeNONSEQM1


class writeNONSEQM3 extends uvm_sequence #(ahb_mux_transaction_v2);
  `uvm_object_utils(writeNONSEQM3)
  HTRANS_t my_seq;
  int i;
  
  function new(input string name = "");
    super.new(name);
    my_seq = NONSEQ;
  endfunction : new

  virtual task body();
    ahb_mux_transaction_v2 dummy_item;
    ahb_mux_transaction_v2 req_item;
    dummy_item = ahb_mux_transaction_v2::type_id::create("dummy_item");
    req_item = ahb_mux_transaction_v2::type_id::create("req_item");
    
    start_item(req_item);
    req_item.randomize();
    req_item.reset_unit = 0;
    req_item.num_active_managers = 3;
    req_item.index_active_managers = 3'b111;
    req_item.htrans = my_seq;
    req_item.rw = `WRITE;
    req_item.hsize = 2'h2;
    req_item.burstSize = '0;
    req_item.burstType = 3;
    req_item.hwstrb[0] = 4'hF;
    req_item.hwstrb[1] = 4'hF;
    req_item.hwstrb[2] = 4'hF;
    req_item.idle = '0;
    `uvm_info(this.get_name(), $sformatf("Manager requests a non seq write Manager_Index=%0b",req_item.index_active_managers), UVM_NONE);
    `uvm_info(this.get_name(), $sformatf("Req item manager 0=%0h",req_item.haddr[0]), UVM_NONE);
    finish_item(req_item);
    
    start_item(dummy_item);
    dummy_item.haddr[0] = req_item.haddr[0];
    `uvm_info(this.get_name(), $sformatf("Copied Dummy Item Manager 0=%0h",dummy_item.haddr[0]), UVM_NONE);
    dummy_item.reset_unit = 0;
    dummy_item.num_active_managers = 1;
    dummy_item.index_active_managers = '0;
    dummy_item.index_active_managers[0] = 1;
    dummy_item.rw = `WRITE;
    dummy_item.hsize = 2'h2;
    dummy_item.burstSize = '0;
    dummy_item.burstType = 3;
    dummy_item.hwstrb[0] = 4'hF;
    dummy_item.idle = 1;
    dummy_item.htrans = IDLE;
    `uvm_info(this.get_name(), "NON SEQ sequence finished; sending an idle sequence", UVM_NONE);
    finish_item(dummy_item);
  endtask : body
endclass : writeNONSEQM3


class sequencer extends uvm_sequencer #(ahb_mux_transaction_v2);
  `uvm_component_utils(sequencer)

  function new(input string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : sequencer