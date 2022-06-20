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

	// First byte before ptxt_char
	reg [7:0] start = 8'b11111111;

	// Last byte after ptxt_char
	reg [7:0] finish = 8'b00000000;

	// reg to make the circular left shift
	reg [7:0] shifter;

    reg next_byte = 1'b0;

	// Counter of iteration done on the current char (byte)
	reg [32:0] count;

	// indicate if the byte is valid and then start to iterate
	reg hash_enable = 1'b0;

	int row, column, index;

	string string_out;



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

	// compute digest
function unpacked_arr update_digest(input [7:0] digest[0:7]);
    for (int j = 0; j < 8; j++) begin
        update_digest[j] = (digest[(j + 2) % 8] ^ ptxt_char);
		shifter = update_digest[j];
		update_digest[j] = shift_digest(shifter, j);
        // 4 MSb and the 4 LSb of input byte as row and column of sbox lut to substitute it
        row = update_digest[j][7:4];
        column = update_digest[j][3:0];
        index = (row * 16) + column;
        update_digest[j] = aes128_sbox(index);
	end
endfunction

	/*always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin
	  err_invalid_ptxt_char     <= 1'b0;
	end else begin
	  err_invalid_ptxt_char     <= err_invalid_ptxt_char_wire;
  end*/


	//  Hashing function
	always @ (*) begin
		//check plaintext validity
		if(ptxt_valid) begin
			// restore counter
			count <= (ptxt_char == start || ptxt_char == finish) ? 0 : 1;
			// at next clock cycle, start to iterate over byte
			hash_enable <= 1'b1;
		end
		else if (hash_enable) begin
			if (count == 0) begin
				next_byte <= 1'b1;
			end
			if (count <= 32) begin
				case(ptxt_char)
					start : begin
						digest_char <= `NULL_CHAR;
						digest_tmp <= restore_digest();
						next_byte <= 1'b0;
					end
					finish : begin
						digest_ready <= 1'b1;
						digest_char <= get_digest(digest_tmp);
						//string_out = $sformatf("%0h", digest_char);
						//$display("Final digest: %s", string_out);
						next_byte <= 1'b0;
					end
					default : begin
						digest_tmp <= update_digest(digest_tmp);
						//print_digest(digest_tmp);
						count <= count + 1;
					end
				endcase
			end
			else begin
				// put to 0 and then to 1 in next iteration to wake up the tb
				next_byte <= 1'b0;
				count <= 32'd0;
				hash_enable <= 1'b0;
			end
		end
		else
			next_byte <= 1'b1;
	end

	// Output char (64-bit digest)
	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			digest_char <= `NULL_CHAR;
			digest_tmp <= restore_digest();
			next_byte <= 1'b0;
		end
		else if(err_invalid_ptxt_char_wire) begin
		  digest_char <= `NULL_CHAR;
		end
	end

endmodule
