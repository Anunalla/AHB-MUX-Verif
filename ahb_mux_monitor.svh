`ifndef AHB_mux_MONITOR_SVH
`define AHB_mux_MONITOR_SVH

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mux_if.sv"
class ahb_mux_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_mux_monitor)

  virtual mux_if vif;

  uvm_analysis_port #(ahb_mux_transaction_v2) ip2pred;
  uvm_analysis_port #(ahb_mux_transaction_v2) op2scorebd;
  int i;
  ahb_mux_transaction_v2 tx;
      
  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    ip2pred = new("ip2pred", this);
    op2scorebd  = new("op2scorebd", this);
    tx = ahb_mux_transaction_v2::type_id::create("tx");
  endfunction : new

  // Build Phase - Get handle to virtual if from config_db
  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual mux_if)::get(this, "", "mux_vif", vif)) begin
      `uvm_fatal("monitor", "No virtual interface specified for this monitor instance")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // @(posedge vif.HCLK);
    forever begin
      @(negedge vif.HCLK);
      tx.haddr_mout = vif.mux_out.HADDR;
      tx.hwdata_mout = vif.mux_out.HWDATA;
      tx.hwstrb_mout = vif.mux_out.HWSTRB;
      tx.hreadyout_mout = vif.mux_out.HREADYOUT;
      `uvm_info(this.get_name(), $sformatf("MOUT HADDR=%0h, HWDATA=%0h, HWSTRB=%0h",vif.mux_out.HADDR,vif.mux_out.HWDATA,vif.mux_out.HWSTRB), UVM_LOW);
      tx.reset_unit = (vif.HRESETn==0);
      // if(tx.reset_unit) begin
      //     @(posedge vif.HCLK);
      // end
      // else begin
        tx.num_active_managers = '0;
        tx.index_active_managers = '0;
        for (i=0; i<`AHB_MUX_NMANAGERS; i++) begin
          tx.haddr[i] = vif.managers[i].HADDR;
          tx.hwdata[i]= vif.managers[i].HWDATA;
          tx.hwstrb[i] = vif.managers[i].HWSTRB;
          `uvm_info(this.get_name(), $sformatf("HADDR[%0d]=%0h, HWDATA[%0d]=%0h, HWSTRB[%0d]=%0h",i,vif.managers[i].HADDR,i,vif.managers[i].HWDATA,i,vif.managers[i].HWSTRB), UVM_LOW);
          if (tx.haddr[i] == 0) begin
            tx.index_active_managers[i] = 0;
            
          end
          else begin
            tx.index_active_managers[i] = 1;
            tx.num_active_managers = tx.num_active_managers+1'b1;
            tx.hsize = vif.managers[i].HSIZE;
            tx.htrans = vif.managers[i].HTRANS;
            tx.idle = vif.managers[i].HTRANS=='0;
            tx.rw = vif.managers[i].HWRITE;
            tx.burstType=vif.managers[i].HBURST;
          end
          // `uvm_info(this.get_name(), $sformatf("HWSTRB[%0d]=%0h",i,vif.managers[i].HWSTRB), UVM_LOW);
        end
        
      // end
      `uvm_info(this.get_name(), "New result sent to predictor", UVM_LOW);
      ip2pred.write(tx); // write the result to the predictor!
      `uvm_info(this.get_name(), "New result sent to scoreboard", UVM_LOW);
      op2scorebd.write(tx);     // now write the result to the scoreboard!
      
    end
  endtask : run_phase

endclass : ahb_mux_monitor

`endif
