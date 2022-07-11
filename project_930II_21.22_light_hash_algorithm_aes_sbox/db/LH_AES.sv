`include"aes_sbox.sv"
`include"LH_functions.sv"

`define NULL_CHAR 8'h00


module light_hash (
	input              clk			    // clock
	,input             rst_n			// reset
	,input		[7:0]  message_byte	    // 8 bit input
	,input			   message_valid	// define the validity of the input 8 bit message
	,input 		[1:0]  state			// state = 2'b00 => HEAD of the messagge, 2'b01 => TAIL, 2'b10 MESSAGE e default 2'b11
	,output reg [63:0] digest	        // 64 bit digest output --> composition of 8 blocks H[i] of 8 bit
	,output reg		   digest_ready	    // hash function of the input message is completed
	);


// ---------------------------------------------------------------------------
// VARIABLES
// ---------------------------------------------------------------------------


// init digest
localparam reg [7:0] restore_digest [0:7] = '{8'h34, 8'h55, 8'h0F, 8'h14, 8'hDA, 8'hC0, 8'h2B, 8'hEE};


// 64 bit temporary digest
reg [7:0] digest_tmp[0:7];
// left shift suport register
reg [7:0] shifter;
// enable/disable next message_byte as input
reg next_byte = 1'b0;
// enable output sequential always
reg tmp_digest_ready;
// int to perform the aes_sbox function
int row, column, index, r;



// ---------------------------------------------------------------------------
// LOGIC DESIGN
// ---------------------------------------------------------------------------


// function to compute the main computation
function unpacked_arr update_digest(input [7:0] digest[0:7]);
  for (int j = 0; j < 8; j++) begin
	  // take the byte from the digest register
	  // and compute the XOR with the message_byte
	  update_digest[j] = (digest[(j + 2) % 8] ^ message_byte);
	  shifter = update_digest[j];
	  // compute the left circular shift by n bits
	  update_digest[j] = shift_digest(shifter, j);
	  // calculated the row, the column and the index to perform
	  // the correct access to the S-box matrix
      row = update_digest[j][7:4];
      column = update_digest[j][3:0];
      index = (row * 16) + column;
      update_digest[j] = aes128_sbox(index);
end
endfunction

//  combinational always
always @ (*) begin
	// check if the message_valid bit is enabled
	if(message_valid) begin
		case(state)
			// inizialization stage is performed
			HEAD : begin
				tmp_digest_ready = 1'b0;
				digest_tmp = restore_digest;
				next_byte = 1'b0;
				r = 0;
			end
			// output stage is performed
			TAIL : begin
				// enable the sequential always
				tmp_digest_ready = 1'b1;
				next_byte = 1'b0;
				r = 0;
			end
			// computation stage is performed
			MESSAGE : begin
				for(r = 0; r < 32; r++) begin
					if (r == 0) begin
						// enable next message byte input from the Testbench
						next_byte = 1'b1;
					end
					// update temporary digest
					digest_tmp = update_digest(digest_tmp);
				end
				next_byte = 1'b0;
				tmp_digest_ready = 1'b0;

			end
			default : begin
				tmp_digest_ready = 1'b0;
				$display("Error default case");
				r = 0;
			end
		endcase
	end
	else begin
		tmp_digest_ready = 1'b0;
		next_byte = 1'b1;
		r = 0;
	end
end

// sequential always
always @(posedge clk or negedge rst_n) begin
	// asynchronous reset port
	if(!rst_n) begin
		digest_ready <= 1'b0;
		digest <= `NULL_CHAR;
	end
    else begin
		// correct value of the digest is ready
		if(tmp_digest_ready) begin
			digest_ready <= 1'b1;
			digest <= get_digest(digest_tmp);
		end
		else begin
			digest_ready <= 1'b0;
			digest <= `NULL_CHAR;
		end
	end
end





endmodule
