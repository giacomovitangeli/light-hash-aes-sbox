`include"aes_sbox.sv"

`define NULL_CHAR 8'h00

module light_hash (
	input            clk
	,input            rst_n
	,input			ptxt_char
	,input			ptxt_valid
	,output reg [7:0] digest_char
	,output reg		digest_ready
	,output reg     err_invalid_ptxt_char //zero as out means error
	);

	// ---------------------------------------------------------------------------
	// Variables
	// ---------------------------------------------------------------------------

	digest_char = NULL_CHAR;	//TODO verify this assignment
	
	reg  [7:0] digest_tmp;
	
	digest_tmp[0] = 8'h34;	
	digest_tmp[1] = 8'h55;
	digest_tmp[2] = 8'h0F;
	digest_tmp[3] = 8'h14;
	digest_tmp[4] = 8'hDA;
	digest_tmp[5] = 8'hC0;
	digest_tmp[6] = 8'h2B;
	digest_tmp[7] = 8'hEE;
	

	// ---------------------------------------------------------------------------
	// Logic Design
	// ---------------------------------------------------------------------------

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
	  ctxt_char <= `NULL_CHAR;
	else if(err_invalid_ptxt_char_wire)
	  ctxt_char <= `NULL_CHAR;
	else
	  ctxt_char <= sub_letter;


endmodule
