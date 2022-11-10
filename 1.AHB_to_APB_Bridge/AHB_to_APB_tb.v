`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.09.2022 19:56:09
// Design Name: 
// Module Name: AHB_to_APB_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AHB_to_APB_tb;

	// Inputs
	reg [31:0] Haddr;
	wire [31:0] addr;
	wire [31:0] addr3;
	wire [31:0] addr2;	
    wire [31:0] Paddr;
    	
	reg [31:0] Hwdata;
	reg Hwrite;
	wire ready;
	wire valid;
	
	reg [2:0] Hburst;
	reg [1:0] Htrans;
	reg [1:0] Hsize;
	reg Hclk;
	reg [31:0] Prdata;
    wire [2:0] state;
	// Outputs
	
	wire Pwrite;
	wire [1:0] Psel;
	wire Penable;
	wire [31:0] Pwdata;
	
	wire [31:0] Hrdata;

	// Instantiate the Unit Under Test (UUT)
	AHB_to_APB_Bridge uut (
		.Haddr(Haddr), 
		.Hwdata(Hwdata), 
		.Hwrite(Hwrite), 
		.Hburst(Hburst), 
		.Htrans(Htrans), 
		.Hsize(Hsize), 
		.Hclk(Hclk), 
		//.Hreset(Hreset), 
		.Paddr(Paddr), 
		.Pwrite(Pwrite), 
		.Psel(Psel), 
		.Penable(Penable), 
		.Pwdata(Pwdata), 
		.ready(ready), 
		.Hrdata(Hrdata), 
		.Prdata(Prdata)
	);
    always#10 Hclk=~Hclk;
    
    assign addr=uut.addr;
    assign addr3=uut.addr3;
    assign addr2=uut.addr2;
    assign state=uut.PS;
    assign valid=uut.valid;
	
	initial begin
		// Initialize Inputs
		
		Haddr = 0;
		Hwdata = 0;
		Hwrite = 0;
		Hburst = 0;
		Htrans = 0;
		Hsize = 0;
		Hclk = 0;
		//Hreset = 0;
		Prdata = 0;
		
		@(posedge Hclk)
		begin
		Htrans=2'b00;
		Haddr=31'h20;
		Hburst=3'b001;
		Hsize=2'b01;
		Hwrite=1;
		end
		
		@(posedge Hclk)
		begin
		Htrans=2'b01;
		//Haddr=31'h20;
		Hwdata=8'haa;
		Hburst=3'b001;
		Hsize=2'b01;
		Hwrite=0;
		end
		
		@(posedge Hclk)
        begin
        Htrans=2'b01;
        Hwdata=8'hbb;
        //Haddr=31'h20;
        Hburst=3'b001;
        Hsize=2'b01;
        Hwrite=1;
        end
        
		
		
		
		
		
		

		// Wait 100 ns for global reset to finish
		#600 $finish;
        
		// Add stimulus here

	end
      
endmodule


