`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.09.2022 18:25:44
// Design Name: 
// Module Name: AHB_to_APB_Bridge
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


module AHB_to_APB_Bridge(
  
    input [31:0] Haddr,
    input [31:0] Hwdata,
    input Hwrite,
    input [2:0] Hburst,
    input [1:0] Htrans,
    input [1:0] Hsize,
    input Hclk,
    //input Hreset,
    output [31:0] Paddr,
    output Pwrite,
    output [1:0] Psel,
    output Penable,
    output [31:0] Pwdata,
    output ready,
    output [31:0] Hrdata,
    input [31:0] Prdata
   );


parameter Seq=2'b01,NonSeq=2'b00,Busy=2'b10,Idel=2'b11;
parameter SING=3'b000,INC=3'b001,INC4=3'b010,INC8=3'b011,INC16=3'b100,WRAP4=3'b101,WRAP8=3'b110,WRAP16=3'b111;
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110,idel=3'b111;

reg valid;
reg [2:0] NS;
reg [2:0] PS=3'b101;
reg [31:0]addr;
reg [31:0]addr2;
reg [31:0]addr3;
reg F;
reg [31:0]data;
reg ready1;
reg Penable1;
reg[31:0]Paddr1;
reg[1:0]Psel1;
reg Pwrite1;
reg [31:0]Pwdata1;
reg [31:0]Hrdata1;



assign ready=ready1;
assign Penable=Penable1;
assign Paddr=Paddr1;
assign Psel=Psel1;
assign Pwrite=Pwrite1;
assign Pwdata=Pwdata1;
assign Hrdata=Hrdata1;





always @(posedge Hclk)
    begin
	   if((Htrans==NonSeq)&&(ready==1))
		  #2 addr<=Haddr;
		  
		else if((Htrans==Seq)&&(ready==1))
		begin
		case(Hburst)
		SING                : #2 addr<=addr;
		INC,INC4,INC8,INC16 : begin
		                      #2 addr<=addr+Hsize;
									 end
		WRAP4                :begin
		                      if(Hsize==2'b01) // size 8bites
									 #2  addr<={Haddr[31:2],Haddr[1:0]+1'b1};
									 else if(Hsize==2'b10) // size 16bites
									  #2 addr<={Haddr[31:3],Haddr[2:1]+1'b1,Haddr[0]};
									 else if(Hsize==2'b11)  // size 32bites
									  #2 addr<={Haddr[31:4],Haddr[3:2]+1'b1,Haddr[1:0]};
									 end

		WRAP8                :begin
		                      if(Hsize==2'b01) // size 8bites
									  #2 addr<={Haddr[31:3],Haddr[2:0]+1'b1};
									 else if(Hsize==2'b10) // size 16bites
									  #2 addr<={Haddr[31:4],Haddr[3:1]+1'b1,Haddr[0]};
									 else if(Hsize==2'b11)  // size 32bites
									   #2 addr<={Haddr[31:5],Haddr[4:2]+1'b1,Haddr[1:0]};		
                            end

		WRAP16               :begin
		                      if(Hsize==2'b01) // size 8bites
									   #2 addr<={Haddr[31:4],Haddr[3:0]+1'b1};
									 else if(Hsize==2'b10) // size 16bites
									   #2 addr<={Haddr[31:5],Haddr[4:1]+1'b1,Haddr[0]};
									 else if(Hsize==2'b11)  // size 32bites
									  #2 addr<={Haddr[31:6],Haddr[5:2]+1'b1,Haddr[1:0]};
                            end 										
		default            : begin
		                     #2 addr=32'hxxxxxxxx;
									end
		endcase
		end
	end



always@(Htrans)
begin
if((Htrans==NonSeq)|(Htrans==Seq))
valid=1;
else
valid=0;
end

always @(posedge Hclk)
begin
PS=NS;
end


always @(PS)
begin
case(PS)

    idel: begin
              if(valid)
                  begin

                    if(Hwrite)
                       NS=s0;
                    else
                       NS=s3;
                  end
              else
                begin
              #2  NS=idel;
                  ready1=0;
                end
             #2   ready1=1;
             #2 addr3=addr;
                   
          end
           
     s0:  begin
             if(valid)
                  begin
                 #2 data=Hwdata;
                    Penable1=0;
                   F=Hwrite;
                   ready1=1;
                   NS=s1;
                 #2 addr2=addr3; 
                    addr3=addr;
                                   
                  end   
             else
                #2  NS=s6;
          end
     
          
     s1:  begin
              Pwdata1=data;
              Psel1=addr2[1:0];
              Penable1=0;
              Pwrite1=1;
              ready1=0;
              NS=s2;
           #2 Paddr1=addr2;
            #2  addr2=addr3;
         end
          
     s2:   begin
           #1 Penable1=1;
               if(F)
                  begin
                #2 data=Hwdata;
                  F=Hwrite;
                  ready1=1;
                  NS=s1;
                #2 addr3=addr;

                  end
               else
                 begin
               #2  ready1=0;
                 NS=s3;
                 end
           end
           
     s3:   begin
         #2  Paddr1=addr3;
           Pwrite1=0;
           Penable1=0;
           Psel1=addr3[1:0];
           ready1=0;
           NS=s4;
           end
           
     s4:  begin
            #2  Penable1=1;
              Hrdata1=Prdata;
              
              ready1=1;
                  if(~Hwrite)
                    NS=s3;
                  else
                     NS=s0;
            #2 addr3=addr;
          end
     
      s6:  begin
               if(valid)
               #2   NS=s1;
               else
               #2  NS=s6;
           end
  
  
  default:  begin
          #2  NS=idel;
            ready1=1;
            end
  
  
  
 endcase
 end
     
endmodule   
           
            
           
           
           
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                    
          
          
          
          
          
          
          
          
          
          
          
           
          
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
             
              
              
              
              
              
              
              
              
              
              
              
           
                   
                     
                     
              
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

