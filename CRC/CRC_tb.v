`timescale 1ns/1ps 
module CRC_TB;

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter LFSR_WIDTH = 8;
parameter CLK_PERIOD = 100;
parameter TEST = 10;


/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg clk , rst , active ;
reg data;
wire crc ;
wire valid;





/////////////////////////////////////////////////////////
///////////////// Loops Variables ///////////////////////
/////////////////////////////////////////////////////////

integer i,j;

/////////////////////////////////////////////////////////
/////////////////////// Memories ////////////////////////
/////////////////////////////////////////////////////////

reg[LFSR_WIDTH-1:0] data_in [0:TEST-1];
reg[LFSR_WIDTH-1:0] expected_out [0:TEST-1];

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////




initial begin
	$readmemh("DATA_h.txt",data_in);
	$readmemh("Expec_Out_h.txt",expected_out);
	$dumpfile("CRC.vcd");
	$dumpvars;
	init();
	reset();
	active = 1;
	for(j=0;j<TEST;j=j+1) begin
		reset;
		do_oper(data_in[j]);
		//#(CLK_PERIOD);
		checker(expected_out[j]);
	end
	active = 0;
	#50;
	$stop();
end


////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////
task init;
begin 
active = 1'b0;
rst    = 1'b1;
data   = 1'b0;
end 
endtask

task reset;
begin 
#(CLK_PERIOD / 5);
rst = 0;
#(CLK_PERIOD / 5);
rst = 1;
end
endtask


task do_oper(input[LFSR_WIDTH-1:0] Data);
begin
	active = 1;
	for(i = 0;i<LFSR_WIDTH;i=i+1) begin
		data = Data[i];
		@(posedge clk);
	end
	active = 0;
end
endtask 

task checker(input[LFSR_WIDTH-1:0] expect);
reg[LFSR_WIDTH-1:0] data_crc;
begin 
	for(i=0;i<=LFSR_WIDTH;i=i+1) begin
	#(CLK_PERIOD);
	data_crc[LFSR_WIDTH-i] = crc;	
	end
	if(expect == data_crc)
		$display("Test succeeded :)");
	else 
		$display("Test Failed :(");
end 
endtask
////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
////////////////////////////////////////////////////////

initial begin
	clk = 0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

////////////////////////////////////////////////////////
/////////////////// DUT Instantation ///////////////////
////////////////////////////////////////////////////////


CRC DUT(
		.CLK(clk),
		.RST(rst),
		.Data(data),
		.ACTIVE(active),
		.CRC(crc),
		.valid(valid)
		);

endmodule