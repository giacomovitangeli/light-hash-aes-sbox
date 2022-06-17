`include"aes_sbox.sv"
`include"LH_functions.sv"

`define NULL_CHAR 8'h00

module light_hash (
	input            clk	//1-bit clock
	,input            rst_n
	,input		[7:0] ptxt_char	//8-bit input
	,input			ptxt_valid
	,output reg [63:0] digest_char	//64-bit digest output --> composition of 8 blocks H[i] of 8-bit
	,output reg		digest_ready
	,output reg     err_invalid_ptxt_char //zero as out means error
	);

	// ---------------------------------------------------------------------------
	// Variables
	// ---------------------------------------------------------------------------

	localparam UPPERCASE_A_CHAR = 8'h41;  // ASCII code for 'A'
	localparam UPPERCASE_Z_CHAR = 8'h5A;  // ASCII code for 'Z'
	localparam LOWERCASE_A_CHAR = 8'h61;  // ASCII code for 'a'
	localparam LOWERCASE_Z_CHAR = 8'h7A;  // ASCII code for 'z'
	localparam LOWERBOUND_0_CHAR = 8'h30;  // ASCII code for '0'
	localparam UPPERBOUND_9_CHAR = 8'h39;  // ASCII code for '9'

	wire       ptxt_char_is_uppercase_letter;
	wire       ptxt_char_is_lowercase_letter;
	wire	   ptxt_char_is_number;
	wire       ptxt_char_is_letter;

	//assign digest_char = `NULL_CHAR;	//TODO verify this assignment


	reg [7:0] digest_tmp[0:7];	//64-bit temporary digest
	// reg to make the circular left shift
	reg [7:0] shifter;

    reg next_byte = 1'b0;
	
	int row, column, index;
	

	// ---------------------------------------------------------------------------
	// Logic Design
	// ---------------------------------------------------------------------------

	assign ptxt_char_is_uppercase_letter = (ptxt_char >= UPPERCASE_A_CHAR) &&
                                         (ptxt_char <= UPPERCASE_Z_CHAR);

	assign ptxt_char_is_lowercase_letter = (ptxt_char >= LOWERCASE_A_CHAR) &&
                                         (ptxt_char <= LOWERCASE_Z_CHAR);

	assign ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
                               ptxt_char_is_lowercase_letter;

	assign ptxt_char_is_number = (ptxt_char >= LOWERBOUND_0_CHAR) &&
								(ptxt_char <= UPPERBOUND_9_CHAR);

	// assign err_invalid_ptxt_char = !ptxt_char_is_letter or !ptxt_char_is_number;
	wire err_invalid_ptxt_char_wire = (!ptxt_char_is_letter) &&
									(!ptxt_char_is_number);

	always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin
	  err_invalid_ptxt_char     <= 1'b0;
	end else begin
	  err_invalid_ptxt_char     <= err_invalid_ptxt_char_wire;
	end


	
	//  Hashing function
	always @ (*) begin
	//check plaintext validity
	if(ptxt_valid) begin
	next_byte <= 1'b1;
		for(int r = 0; r < 32; r++) begin
		
			for(int i = 0; i < 8; i++) begin
				digest_tmp[i] = (digest_tmp[(i+2) % 8] ^ ptxt_char);
				shifter = digest_tmp[i];
				digest_tmp[i] = shift_digest(shifter, i);
				// 4 MSb and the 4 LSb of input byte as row and column of sbox lut to substitute it
        		row = digest_tmp[i][7:4];
        		column = digest_tmp[i][3:0];
        		index = (row * 16) + column;
				//$display("%b", index);
				digest_tmp[i] = aes128_sbox(index);
				//$display("%b", digest_tmp[i]);
			end
		end
		next_byte <= 1'b0;
	end
	end

	// Output char (ciphertext)
	always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin
		digest_char <= `NULL_CHAR;
  	    restore_digest(digest_tmp);
		next_byte <= 1'b0;
	end
	else if(err_invalid_ptxt_char_wire)
	  digest_char <= `NULL_CHAR;
	else
	  digest_char <= get_digest(digest_tmp);
	  
endmodule
