`ifndef AHB_MUX_PREDICTOR
`define AHB_MUX_PREDICTOR

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_mux_transaction_v2.svh"
// `include "peripheral_model.svh"
`include "dutMUX_params.svh"

localparam TOP_ADDR = `AHB_BASE_ADDR + `AHB_NWORDS * (`AHB_ADDR_WIDTH / 8);

class ahb_mux_predictor extends uvm_subscriber #(ahb_mux_transaction_v2);
  `uvm_component_utils(ahb_mux_predictor)

  // peripheral_model periph = new;

  uvm_analysis_port #(ahb_mux_transaction_v2) pred_ap;
  ahb_mux_transaction_v2 expected_output_tx;
  integer last_expected_master;
  integer current_expected_master;
  int i, j, k;
  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    last_expected_master = -1;
    current_expected_master = -1;
  endfunction : new

  function void build_phase(uvm_phase phase);
    pred_ap = new("pred_ap", this);
  endfunction


  function void write(ahb_mux_transaction_v2 t);
    // t is the transaction sent from monitor
    expected_output_tx = ahb_mux_transaction_v2::type_id::create("output_tx", this);
    expected_output_tx.copy(t);
    // `uvm_info(this.get_name(), $sformatf("expected_output_tx.reset_unit=%0d; t.reset_unit=%0d\n",expected_output_tx.reset_unit, t.reset_unit), UVM_NONE);
    // `uvm_info(this.get_name(), $sformatf("expected_output_tx.num_active_managers=%d; expected_output_tx.index_active_managers=%0b\n",expected_output_tx.num_active_managers, expected_output_tx.index_active_managers), UVM_NONE);
    if(expected_output_tx.reset_unit==1) begin
      expected_output_tx.haddr_mout = '0;
      expected_output_tx.hwdata_mout = '0;
      expected_output_tx.hwstrb_mout = '0;
      current_expected_master = 0;
      `uvm_info(this.get_name(), $sformatf("Last Master:%d\n Current Master:%d\n",last_expected_master, current_expected_master), UVM_NONE);
    end
    else begin
      // for(i=0; i< expected_output_tx.num_active_managers; i++) begin 
      //   for(k=)
      // end
      `uvm_info(this.get_name(), $sformatf("Before Change= Last Master:%d",last_expected_master), UVM_NONE);
      if(expected_output_tx.num_active_managers>0) begin
        if(expected_output_tx.index_active_managers==0) begin
          current_expected_master = 0;
          last_expected_master = -1;
        end
        else begin
          for(i=(`AHB_MUX_NMANAGERS-1); i>=0; i--) begin
            `uvm_info(this.get_name(), $sformatf("For loop: expected_output_tx.index_active_managers[%0d]=%0b\n",i,expected_output_tx.index_active_managers[i]), UVM_NONE);
            if(expected_output_tx.index_active_managers[i]) begin
              if(last_expected_master != i) begin // for NONSEQ with delay cycles, can we use tx.muxout.HREADYOUT as another condition
                current_expected_master = i;
                break;
              end
            end
          end
        end
      end
      else current_expected_master = 0; //-1
      `uvm_info(this.get_name(), $sformatf("After Change Last Master:%0d Current Master:%0d",last_expected_master, current_expected_master), UVM_NONE);
      // fork
      // expected_request(current_expected_master,last_expected_master,t,expected_output_tx);
      // join_none
      if (last_expected_master>=0) begin 
        expected_output_tx.hwdata_mout = t.hwdata[last_expected_master];
        expected_output_tx.hwstrb_mout = t.hwstrb[last_expected_master];
      end
      else begin 
        expected_output_tx.hwdata_mout = '0;
        expected_output_tx.hwstrb_mout = '0;
      end
      if (current_expected_master>=0) begin
        expected_output_tx.haddr_mout = t.haddr[current_expected_master];
      end
      else begin
        expected_output_tx.haddr_mout = '0;
      end
    end
    // `uvm_info(this.get_name(), $sformatf("MOUT: ADDR:%0h STRB:%0h DATA:%0h \n CURR INPUT: ADDR:%0h STRB:%0h DATA:%0h \n",
    //                                       expected_output_tx.haddr_mout, 
    //                                       expected_output_tx.hwstrb_mout, 
    //                                       expected_output_tx.hwdata_mout,
    //                                       t.haddr[current_expected_master],
    //                                       t.hwstrb[last_expected_master],
    //                                       t.hwdata[last_expected_master]), 
    //                                       UVM_NONE);
    last_expected_master = current_expected_master;
    // `uvm_info(this.get_name(), $sformatf("ADDR:%h\n STRB:%d \n DATA:%d\n",
    //                                       expected_output_tx.haddr_mout, 
    //                                       expected_output_tx.hwstrb_mout, 
    //                                       expected_output_tx.hwdata_mout), 
    //                                       UVM_NONE);
    pred_ap.write(expected_output_tx);
  endfunction : write
  
  task expected_request(input int n, input int m, 
                        input ahb_mux_transaction_v2 incoming_tx,
                        output ahb_mux_transaction_v2 expected_tx
                        // ,input int phase 
                        );
      if (m>=0) expected_tx.hwdata_mout = incoming_tx.hwdata[m];
      else expected_tx.hwdata_mout = '0;
      if (n>=0) begin
        expected_tx.hwstrb_mout = incoming_tx.hwstrb[n];
        expected_tx.haddr_mout = incoming_tx.haddr[n];
      end
      else begin
        expected_tx.hwstrb_mout = '0;
        expected_tx.haddr_mout = '0;
      end
      
  endtask
endclass : ahb_mux_predictor

`endif
