`ifndef AHB_MUX_SCOREBOARD
`define AHB_MUX_SCOREBOARD

import uvm_pkg::*;
`include "uvm_macros.svh"

class ahb_mux_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ahb_mux_scoreboard)
  uvm_analysis_export #(ahb_mux_transaction_v2) expected_export;  // receive result from predictor
  uvm_analysis_export #(ahb_mux_transaction_v2) actual_export;  // receive result from DUT
  uvm_tlm_analysis_fifo #(ahb_mux_transaction_v2) expected_fifo;
  uvm_tlm_analysis_fifo #(ahb_mux_transaction_v2) actual_fifo;

  int m_matches, m_mismatches;  // records number of matches and mismatches
  int numData;  // the number of data elements we should be looping over

  function new(string name, uvm_component parent);
    super.new(name, parent);
    m_matches = 0;
    m_mismatches = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    expected_export = new("expected_export", this);
    actual_export = new("actual_export", this);
    expected_fifo = new("expected_fifo", this);
    actual_fifo = new("actual_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    expected_export.connect(expected_fifo.analysis_export);
    actual_export.connect(actual_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    ahb_mux_transaction_v2 expected_tx;  //transaction from predictor
    ahb_mux_transaction_v2 actual_tx;  //transaction from DUT
    forever begin
      expected_fifo.get(expected_tx);
      actual_fifo.get(actual_tx);

      if (expected_tx.compare(actual_tx)) begin
        m_matches++;
        //uvm_report_info("Comparator", "Data Match");
        uvm_report_info("Comparator", "Success: Data Match");
        uvm_report_info("Comparator", $psprintf(
                          "\n\n haddr: Expected=0x%0h, Actual=0x%0h\n hwdata: Expected=0x%0h, Actual=0x%0h\n, hwstrb: Expected=0x%0h, Actual=0x%0h\n\n",
                          // i,
                          expected_tx.haddr_mout,
                          actual_tx.haddr_mout,
                          expected_tx.hwdata_mout,
                          actual_tx.hwdata_mout,
                          expected_tx.hwstrb_mout,
                          actual_tx.hwstrb_mout
                          ));
      end else begin
        m_mismatches++;
        uvm_report_error("Comparator", "Error: Data Mismatch");
        uvm_report_info("Comparator", $psprintf(
                          "\n\n haddr: Expected=0x%0h, Actual=0x%0h\n hwdata: Expected=0x%0h, Actual=0x%0h\n, hwstrb: Expected=0x%0h, Actual=0x%0h\n\n",
                          // i,
                          expected_tx.haddr_mout,
                          actual_tx.haddr_mout,
                          expected_tx.hwdata_mout,
                          actual_tx.hwdata_mout,
                          expected_tx.hwstrb_mout,
                          actual_tx.hwstrb_mout
                          ));
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_info("Comparator", $sformatf("Matches:    %0d", m_matches));
    uvm_report_info("Comparator", $sformatf("Mismatches: %0d", m_mismatches));
  endfunction

endclass

`endif
