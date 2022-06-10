`include"aes_sbox.sv"

`define NULL_CHAR 8'h00

module light_hash (
	input            clk
	,input            rst_n
	,input			ptxt_char
	,input			ptxt_valid
	,output reg [63:0] digest_char	//64-bit digest --> composition of 8 blocks H[i] of 8-bit
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
	

	reg [7:0] digest_tmp = '{8'h34, 8'h55, 8'h0F, 8'h14, 8'hDA, 8'hC0, 8'h2B, 8'hEE};	//8-bit block
	

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
		for(int r = 0; r < 32; r++) begin
			for(int i = 0; i < 8; i++) begin
				digest_tmp[i] = aes128_sbox((digest_tmp[(i+2) % 8] ^ ptxt_char) << i);
			end
		end
	end
	end

	// Output char (ciphertext)
	always @ (posedge clk or negedge rst_n)
	if(!rst_n)
	  digest_char <= `NULL_CHAR;
	else if(err_invalid_ptxt_char_wire)
	  digest_char <= `NULL_CHAR;
	else
	  digest_char <= digest_tmp;


endmodule
