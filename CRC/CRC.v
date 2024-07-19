module CRC(
			input wire Data,
			input wire ACTIVE,
			input wire CLK,
			input wire RST,
			output reg CRC,
			output reg valid
			);


reg[7:0] LFSR;
reg[3:0] cnt;
parameter [7:0] Taps = 8'b0100_0100;
wire feedback;
integer i;

always @(posedge CLK or negedge RST) begin
	if(!RST) begin
		LFSR <= 8'hD8;// 1101_1000
		//CRC  <=8'b0;
		valid<= 1'b0;
		cnt <= 4'b0000;
	end
	else if(ACTIVE) begin
		LFSR[7] <= feedback;
		for(i = 0;i<7;i=i+1) begin
			if(Taps[i] == 1) begin
				LFSR[i] <= LFSR[i+1]^feedback;
			end
			else begin
				LFSR[i] <= LFSR[i+1];
			end
		end

	end
	else begin
		cnt <= cnt+1;
		{CRC,LFSR[7:1]} <= LFSR;
		valid <= 1'b1;
		if(cnt == 4'b1000) begin
			valid <= 1'b0;
		end
	end
end

assign feedback = LFSR[0]^Data;
endmodule


/*
parameter [7:0] Taps = 8'b1000_1000
always @(posedge CLK or negedge RST) begin
	if(!RST) begin
		LFSR <= 8'hD8;// 1101_1000
		//CRC  <=8'b0;
		valid<= 1'b0;
	end
	else if(ACTIVE) begin
		LFSR[0] <= feedback;
		for(i = 7;i>0;i=i-1) begin
			if(Taps[i] == 1) begin
				LFSR[i] <= LFSR[i-1]^feedback;
			end
			else begin
				LFSR[i] <= LFSR[i-1];
			end
		end

	end
	else begin
		{LFSR[6:0],CRC} <= LFSR;
		valid = 1'b1;
	end
end

assign feedback = LFSR[7]^Data;

*/