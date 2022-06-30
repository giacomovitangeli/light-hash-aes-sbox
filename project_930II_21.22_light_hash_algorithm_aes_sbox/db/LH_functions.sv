// typedef for the return type of a function to have an unpacked dimension
typedef reg [7:0] unpacked_arr [0:7];
parameter unpacked_arr para_1 = '{default:0};

localparam  head = 2'b00;
localparam  tail = 2'b01;
localparam  message = 2'b10;

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

// print the digest
function [63:0] print_digest(input [7:0] digest[0:7]);
    string string_out;
    string_out = $sformatf("%0h", digest[7]);
    $display("Partial digest hex: %s", string_out);
    string_out = $sformatf("%0h", digest[6]);
    $display("Partial digest hex: %s", string_out);
    string_out = $sformatf("%0h", digest[5]);
    $display("Partial digest hex: %s", string_out);
    string_out = $sformatf("%0h", digest[4]);
    $display("Partial digest hex: %s", string_out);
    string_out = $sformatf("%0h", digest[3]);
    $display("Partial digest hex: %s", string_out);
    string_out = $sformatf("%0h", digest[2]);
    $display("Partial digest hex: %s", string_out);
    string_out = $sformatf("%0h", digest[1]);
    $display("Partial digest hex: %s", string_out);
    string_out = $sformatf("%0h", digest[0]);
    $display("Partial digest hex: %s", string_out);
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
