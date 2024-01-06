`ifndef AHB_MUX_DRIVER_SVH
`define AHB_MUX_DRIVER_SVH

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "dutMUX_params.svh"
`include "mux_if.sv"

class ahb_mux_driver extends uvm_driver #(ahb_mux_transaction_v2);
  `uvm_component_utils(ahb_mux_driver)

  virtual mux_if vif;
  int timeoutCount;
  logic dPhaseRdy, aPhaseRdy;
  int i;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get interface from database
    if (!uvm_config_db#(virtual mux_if)::get(this, "", "mux_vif", vif)) begin
      // if the interface was not correctly set, raise a fatal message
      `uvm_fatal("Driver", "No virtual interface specified for this test instance");
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    ahb_mux_transaction_v2 currTransaction;
    ahb_mux_transaction_v2 prevTransaction;
    logic firstFlag;
    int burstCount;
    int prevTransIndex;
    int currTransIndex;
    int i;
    firstFlag = 1;
    prevTransaction = ahb_mux_transaction_v2::type_id::create("prevTransaction");

    forever begin  
      @(posedge vif.HCLK); 
      if (firstFlag) begin  
        seq_item_port.get_next_item(currTransaction);
        // `uvm_info(this.get_name(), $sformatf("Received new sequence item:\n%s",
                                            //  currTransaction.sprint()), UVM_LOW);
        prevTransaction.idle = 1;
        for(i=0; i<`AHB_MUX_NMANAGERS; i++) begin
          clear_request(i);
        end
      end else begin
          //       zero_sigs();
         prevTransaction.copy(currTransaction);
         
         seq_item_port.item_done();
        `uvm_info(this.get_name(), "single transfer complete", UVM_LOW);

        seq_item_port.get_next_item(currTransaction);

        prevTransIndex = currTransIndex;
        // `uvm_info(this.get_name(), $sformatf("Received new sequence item:\n%s",
                                            //  currTransaction.sprint()), UVM_NONE);
      end
      currTransIndex = 0;
      firstFlag = 0;
      if(currTransaction.reset_unit) begin  // reset sequence
        DUT_reset();
         `uvm_info(this.get_name(), "Resetting the DUT", UVM_LOW);
        prevTransaction.idle = 1;
        for(i=0; i<`AHB_MUX_NMANAGERS; i++) begin
          clear_request(i);
        end
      end         
      else begin
        
        // drive_address(currTransaction);
        // drive_data(prevTransaction);
        // `uvm_info(this.get_name(), $sformatf("Prev Tx: Num Active Managers=%0d",prevTransaction.num_active_managers), UVM_NONE);
        // if(currTransaction.num_active_managers>1) begin
        //   `uvm_info(this.get_name(), $sformatf("Current Tx: Num Active Managers=%0d",currTransaction.num_active_managers), UVM_NONE);
        //   for(i=`AHB_MUX_NMANAGERS-1; i>=0; i--) begin
        //     if(currTransaction.index_active_managers[i]) begin
        //       @(posedge vif.HCLK);
        //       drive_data_specific_manager(i, currTransaction);
        //     end
        //   end
        // end

        drive_address(currTransaction); // address phase drive

        // data phase drive
        if(prevTransaction.num_active_managers==1) begin
          drive_data(prevTransaction);
        end
        
        if(prevTransaction.num_active_managers>1) begin
          `uvm_info(this.get_name(), $sformatf("Prev Tx: Num Active Managers=%0d",prevTransaction.num_active_managers), UVM_NONE);
          for(i=`AHB_MUX_NMANAGERS-1; i>=0; i--) begin
            if(prevTransaction.index_active_managers[i]) begin
              `uvm_info(this.get_name(), $sformatf("Loop %0d",i), UVM_NONE);
              drive_data_specific_manager(i, prevTransaction);
              @(posedge vif.HCLK) ; //#1;
              // clear_request(i);
            end
          end
        end
        
        // `uvm_info(this.get_name(), $sformatf("Past sequence item:\n%s",
                                            //  prevTransaction.sprint()), UVM_LOW);
        // `uvm_info(this.get_name(), $sformatf("Current Tx: HTRANS=%0d",currTransaction.htrans), UVM_NONE);
      end

    end
  endtask

  task DUT_reset();
    // `uvm_info(this.get_name(), "Resetting DUT", UVM_LOW);
    // vif.HRESETn = '1;
    // @(posedge vif.HCLK);
    // vif.HRESETn = '0;
    // @(posedge vif.HCLK);
    // vif.HRESETn = '1;
    // @(posedge vif.HCLK);
    // @(posedge vif.HCLK);

    @(negedge vif.HCLK);
    vif.HRESETn = '0;
    repeat(2) @(posedge vif.HCLK);
    @(negedge vif.HCLK);
    vif.HRESETn = '1;
  endtask

  task clear_request(input int n);
    `uvm_info(this.get_name(), $sformatf("Clearing request: Manager %0d",n), UVM_NONE);
    vif.managers[n].HADDR = '0;
    vif.managers[n].HSIZE = '0;
    vif.managers[n].HTRANS = '0; // IDLE
    vif.managers[n].HWRITE = '0;
    vif.managers[n].HBURST = '0;
    // vif.managers[n].HWDATA = '0;
    vif.managers[n].HMASTLOCK = '0;
    vif.mux_out.HREADYOUT = '1;
    // vif.mux_out.HREADY = '1;
    vif.mux_out.HSEL = '1;
  endtask

  task  drive_data(input ahb_mux_transaction_v2 tx);
    if (!tx.idle) begin
    if(tx.index_active_managers>0) begin
          casez(tx.index_active_managers) 
          (3'bzz1): begin
          vif.managers[0].HWDATA = tx.hwdata[0];
          vif.managers[0].HWSTRB = tx.hwstrb[0];
          // vif.managers[0].HREADYOUT = '1;
          clear_request(0);
          `uvm_info(this.get_name(), $sformatf("Past Tx: Manager=%0d Data=%0h",0,vif.managers[0].HWDATA ), UVM_NONE);
          end
          (3'bz1z): begin
            vif.managers[1].HWDATA = tx.hwdata[1];
            vif.managers[1].HWSTRB = tx.hwstrb[1];
            // vif.managers[1].HREADYOUT = '1;
            clear_request(1);
            `uvm_info(this.get_name(), $sformatf("Past Tx: Manager=%0d Data=%0h",1,vif.managers[1].HWDATA ), UVM_NONE);
          end
          (3'b1zz): begin
            vif.managers[2].HWDATA = tx.hwdata[2];
            vif.managers[2].HWSTRB = tx.hwstrb[2];
            // vif.managers[2].HREADYOUT = '1;
            clear_request(2);
            `uvm_info(this.get_name(), $sformatf("Past Tx: Manager=%0d Data=%0h",2,vif.managers[2].HWDATA ), UVM_NONE);
          end
          endcase
      end
    end
  endtask

  task  drive_data_specific_manager(input int n, input ahb_mux_transaction_v2 tx);
    vif.managers[n].HWDATA = tx.hwdata[n];
    vif.managers[n].HWSTRB = tx.hwstrb[n];
    // vif.managers[n].HREADYOUT = '1;
    `uvm_info(this.get_name(), $sformatf("Drive Data Specific: Clear address of Manager %0d",n), UVM_LOW);
    clear_request(n);
  endtask

  task drive_address(input ahb_mux_transaction_v2 tx);
  if(tx.num_active_managers>0) begin
          `uvm_info(this.get_name(), $sformatf("address phase Index Manager:%0b",tx.index_active_managers), UVM_LOW);
          for(i=0; i<`AHB_MUX_NMANAGERS; i++) begin
            if(tx.index_active_managers[i]) generate_request(i,tx);
          end
      end
  endtask

  task generate_request(input int n, 
                      input ahb_mux_transaction_v2 tx);
      
      vif.managers[n].HADDR = tx.haddr[n];
      vif.managers[n].HSIZE = tx.hsize;
      vif.managers[n].HTRANS = tx.idle ? '0 : tx.htrans;
      vif.managers[n].HWRITE = tx.rw; 
      vif.managers[n].HBURST = tx.burstType;
      vif.managers[n].HMASTLOCK = '0;
      // vif.managers[n].HREADYOUT = '0;
      `uvm_info(this.get_name(), $sformatf("Current Tx: Manager=%0d Data=%0h",n,tx.hwdata[n]), UVM_NONE);
  endtask

endclass : ahb_mux_driver

`endif
