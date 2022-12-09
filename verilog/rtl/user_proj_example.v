// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
 wire [1:0] change,in;
 wire out,clock,reset;
  
 assign clock=wb_clk_i;
 assign reset = wb_rst_i;
 assign in=io_in[`MPRJ_IO_PADS-1:`MPRJ_IO_PADS-2];
 assign io_out[`MPRJ_IO_PADS-1:35]={change,out}
 
 // IRQ
    assign irq = 3'b000;	// Unused
    
 iiitb_vm instance(change,out,in,clock,reset);
 
endmodule

module iiitb_vm(output reg [1:0] change,output reg out,input [1:0] in, input clock,input reset);
reg [2:0] c_state,n_state;

always@(posedge clock)
begin
	if(~reset)
		c_state<=3'b000;
	else
	    c_state<=n_state;
end

always@(*)
begin
case(c_state)
3'b000:begin 
		if(in==2'b00)
			n_state=3'b000;
		else if(in==2'b01)
			n_state=3'b001;
		else if(in==2'b10)
			n_state=3'b011;
		else
			n_state=3'b000;
	  end
3'b001:begin 
		if(in==2'b00)
			n_state=3'b010;
		else if(in==2'b01)
			n_state=3'b011;
		else if(in==2'b10)
			n_state=3'b100;
		else
			n_state=3'b000;
	  end
3'b010:begin 
		if(in==2'b00)
			n_state=3'b000;
		else if(in==2'b01)
			n_state=3'b001;
		else if(in==2'b10)
			n_state=3'b011;
		else
			n_state=3'b000;
	  end
3'b011:begin 
		if(in==2'b00)
			n_state=3'b101;
		else if(in==2'b01)
			n_state=3'b100;
		else if(in==2'b10)
			n_state=3'b110;
		else
			n_state=3'b000;
	  end
3'b100:begin 
		if(in==2'b00)
			n_state=3'b000;
		else if(in==2'b01)
			n_state=3'b001;
		else if(in==2'b10)
			n_state=3'b011;
		else
			n_state=3'b000;
	  end
3'b011:begin 
		if(in==2'b00)
			n_state=3'b000;
		else if(in==2'b01)
			n_state=3'b001;
		else if(in==2'b10)
			n_state=3'b011;
		else
			n_state=3'b000;
	  end
3'b110:begin 
		if(in==2'b00)
			n_state=3'b000;
		else if(in==2'b01)
			n_state=3'b001;
		else if(in==2'b10)
			n_state=3'b011;
		else
			n_state=3'b000;
	  end
default: n_state=3'b000;
endcase
end

always@(*)
begin
case(c_state)
3'b000: begin
		change=2'b00;
		out=0;
		end
3'b001: begin
		change=2'b00;
		out=0;
		end		
3'b010: begin
		change=2'b01;
		out=0;
		end
3'b011: begin
		change=2'b00;
		out=0;
		end
3'b100: begin
		change=2'b00;
		out=1;
		end
3'b101: begin
		change=2'b10;
		out=0;
		end
3'b110: begin
		change=2'b01;
		out=1;
		end
default:begin out=0; change=2'b00; end
endcase
end

endmodule

`default_nettype wire
