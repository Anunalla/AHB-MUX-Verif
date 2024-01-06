import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_mux_environment.svh"
`include "mux_if.sv"

class testAll_mux extends uvm_test;
  `uvm_component_utils(testAll_mux)

  ahb_mux_environment env;
  virtual mux_if mux_if;
  trialSequence trialSeq;
  resetSequence resetSeq;
  writeNONSEQM1 writeNonSeqM1;
  writeNONSEQM3 writeNonSeqM3;

  function new(string name = "test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ahb_mux_environment::type_id::create("env", this);
    trialSeq = trialSequence::type_id::create("trialSeq");
    resetSeq = resetSequence::type_id::create("resetSeq");
    writeNonSeqM1 = writeNONSEQM1::type_id::create("writeNonSeqM1");
    writeNonSeqM3 = writeNONSEQM3::type_id::create("writeNonSeqM3");
    // send the interface down
    if (!uvm_config_db#(virtual mux_if)::get(this, "", "mux_vif", mux_if)) begin
      // check if interface is correctly set in testbench top level
      `uvm_fatal("TEST", "No virtual interface specified for this test instance")
    end

    uvm_config_db#(virtual mux_if)::set(this, "env.agt*", "mux_vif", mux_if);

  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "Starting basic non seq sequence in main phase");
    
    `uvm_info(this.get_name(), "Starting DUT Reset sequence....", UVM_LOW);
    resetSeq.start(env.ahb_agent.sqr);
    `uvm_info(this.get_name(), "Finished DUT Reset sequence", UVM_LOW);
    // #5ns;

    `uvm_info(this.get_name(), "Starting NONSEQ Write sequence - 1 managers at a time....", UVM_LOW);
    writeNonSeqM1.start(env.ahb_agent.sqr);
    `uvm_info(this.get_name(), "Finished NONSEQ Write sequence - 1 manager at a time", UVM_LOW);
    // #5ns;

    `uvm_info(this.get_name(), "Starting NONSEQ Write sequence - 3 managers at a time....", UVM_LOW);
    writeNonSeqM3.start(env.ahb_agent.sqr);
    `uvm_info(this.get_name(), "Finished NONSEQ Write sequence - 3 manager at a time", UVM_LOW);
    // #5ns;

    phase.drop_objection(this, "Finished basic non seq sequence in main phase");
  endtask

endclass : testAll_mux
