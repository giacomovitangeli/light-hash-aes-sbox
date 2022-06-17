
// Init digest
function reg [7:0] restore_digest(input [7:0] init [0:7]);
    init[0] = 8'h34;
	init[1] = 8'h55;
	init[2] = 8'h0F;
	init[3] = 8'h14;
	init[4] = 8'hDA;
	init[5] = 8'hC0;
	init[6] = 8'h2B;
	init[7] = 8'hEE;
endfunction

// copy the digest to the output
function [63:0] get_digest(input [7:0] digest[0:7]);
	get_digest[7:0] = digest[7];
	get_digest[15:8] = digest[6];
	get_digest[23:16] = digest[5];
	get_digest[31:24] = digest[4];
	get_digest[39:32] = digest[3];
	get_digest[47:40] = digest[2];
	get_digest[55:48] = digest[1];
	get_digest[63:56] = digest[0];
endfunction

// hard left circular shift
function reg [7:0] shift_digest(input [7:0] shifter, input [3:0] j);
	case (j)
		0 : shift_digest = shifter;
		1 : shift_digest = {shifter[6:0], shifter[7]};
		2 : shift_digest = {shifter[5:0], shifter[7:6]};
		3 : shift_digest = {shifter[4:0], shifter[7:5]};
		4 : shift_digest = {shifter[3:0], shifter[7:4]};
		5 : shift_digest = {shifter[2:0], shifter[7:3]};
		6 : shift_digest = {shifter[1:0], shifter[7:2]};
		7 : shift_digest = {shifter[0:0], shifter[7:1]};
	endcase
endfunction
