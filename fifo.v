`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:55:01 06/20/2013 
// Design Name: 
// Module Name:    fifo 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module WR_Data_FIFO(clk,rst,Data_in,write_to_WD_fifo,read_from_WD_fifo,Data_out,Data_stack_full,
                    Data_stack_almost_full,Data_stack_half_full,Data_stack_almost_empty,Data_stack_empty);
  
  parameter stack_width=64;
  parameter stack_height=8;
  parameter stack_ptr_width=3;
  parameter AE_level=2;
  parameter AF_level=6;
  parameter HF_level=4;
  
  
  input                    clk,rst;
  input[stack_width-1:0]   Data_in;
  input                    write_to_WD_fifo,read_from_WD_fifo;
  
  output [stack_width-1:0] Data_out;
  output                   Data_stack_full,Data_stack_almost_full,Data_stack_half_full;
  output                   Data_stack_almost_empty,Data_stack_empty;
  
  reg[stack_ptr_width-1:0] read_ptr,write_ptr;
  
  reg[stack_ptr_width:0]   ptr_gap;
  reg[stack_width-1:0]     Data_out;
  reg[stack_width-1:0]     stack[stack_height-1:0];
  
  assign Data_stack_full=(ptr_gap==stack_height);
  assign Data_stack_almost_full=(ptr_gap==AF_level);
  assign Data_stack_half_full=(ptr_gap==HF_level);
  assign Data_stack_almost_empty=(ptr_gap==AE_level);
  assign Data_stack_empty=(ptr_gap==0);
  
  always @(posedge clk or posedge rst)
   if(rst)begin
       Data_out<=0;
       read_ptr<=0;
       write_ptr<=0;
       ptr_gap<=0;
   end
   else if(write_to_WD_fifo &&(!Data_stack_full)&&(!read_from_WD_fifo))begin
       stack[write_ptr]<=Data_in;
       write_ptr<=write_ptr+1;
       ptr_gap<=ptr_gap+1;
   end
   else if((!write_to_WD_fifo)&&(!Data_stack_empty)&&read_from_WD_fifo)begin
       Data_out<=stack[read_ptr];
       read_ptr<=read_ptr+1;
       ptr_gap<=ptr_gap-1;
   end
   else if(write_to_WD_fifo &&read_from_WD_fifo&&Data_stack_empty)begin
       stack[write_ptr]<=Data_in;
       write_ptr<=write_ptr+1;
       ptr_gap<=ptr_gap+1;
   end
   else if(write_to_WD_fifo &&read_from_WD_fifo&&Data_stack_full)begin
       Data_out<=stack[read_ptr];
       read_ptr<=read_ptr+1;
       ptr_gap<=ptr_gap-1;
   end
   else if(write_to_WD_fifo&&read_from_WD_fifo&&(!Data_stack_full)&&(!Data_stack_empty))
   begin
       Data_out<=stack[read_ptr];
       stack[write_ptr]<=Data_in;
       read_ptr<=read_ptr+1;
       write_ptr<=write_ptr+1;
   end
endmodule




