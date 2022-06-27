`include"aes_sbox.sv"
`include"LH_functions.sv"

`define NULL_CHAR 8'h00

module light_hash (
	// aggiungere head e tail, perchè altrimenti escludiamo dei valori possibili
	input              clk			    //clock
	,input             rst_n			//reset
	,input		[7:0]  message_byte	    //8-bit input
	,input			   message_valid	//define the validity of the input 8-bit message
	,input 		[1:0]  state			//state = 2'b00 => head of the messagge, 2'b01 => tail, 2'b10 message e default 2'b11
	,output reg [63:0] digest	        //64-bit digest output --> composition of 8 blocks H[i] of 8-bit
	,output reg		   digest_ready	    //hash function of the input message is completed
	);


// ---------------------------------------------------------------------------
// VARIABLES
// ---------------------------------------------------------------------------


//init digest
localparam reg [7:0] restore_digest [0:7] = '{8'h34, 8'h55, 8'h0F, 8'h14, 8'hDA, 8'hC0, 8'h2B, 8'hEE};


//64-bit temporary digest
reg [7:0] digest_tmp[0:7];
//left shift suport register
reg [7:0] shifter;
//enable/disable next message_byte as input
reg next_byte = 1'b0;
//iteration counter on the message_byte
reg [32:0] itr_counter = 32'b0;
//enable/disable the iteration counter
reg itr_enable = 1'b0;
//int to perform the aes_sbox function
int row, column, index;


// ---------------------------------------------------------------------------
// LOGIC DESIGN
// ---------------------------------------------------------------------------


// compute digest
function unpacked_arr update_digest(input [7:0] digest[0:7]);
  for (int j = 0; j < 8; j++) begin
      update_digest[j] = (digest[(j + 2) % 8] ^ message_byte);
	shifter = update_digest[j];
	update_digest[j] = shift_digest(shifter, j);
      // 4 MSb and the 4 LSb of input byte as row and column of sbox lut to substitute it
      row = update_digest[j][7:4];
      column = update_digest[j][3:0];
      index = (row * 16) + column;
      update_digest[j] = aes128_sbox(index);
end
endfunction


//  Hashing function
always @ (*) begin // combinatorio => utilizza gli "uguale"
	  			   // sequqnziale utilizza i "minore-uguale"
	digest_ready <= 1'b0; // <-- default assignment
	digest <= `NULL_CHAR;
	//serve solamente nei circuiti sequanziali
	/*if(!rst_n) begin
		digest = `NULL_CHAR;
		digest_tmp = restore_digest;
		next_byte = 1'b0;
		itr_counter = 32'd0;
		digest_ready = 1'b0;
		itr_enable = 1'b0;
		$display("Sono entrato nel reset");
	end*/
	//check plaintext validity
	if(message_valid) begin
		// restore counter
		//itr_counter = '{default:'0}; // <-- default assignment
		//digest_ready = '{default:'0}; // <-- default assignment
		if ((state == head || state == tail))
			itr_counter <= 0;
		else
			itr_counter <= 1;
		//itr_counter <= (state == head || state == tail) ? 0 : 1;
		// at next clock cycle, head to iterate over byte
		itr_enable <= 1'b1;
	end
	else if (itr_enable) begin
		if (itr_counter <= 32) begin
			if (itr_counter == 0) begin
				next_byte <= 1'b1;
			end
			case(state)
				head : begin
					digest <= `NULL_CHAR;
					digest_tmp <= restore_digest;
					next_byte <= 1'b0;
					itr_counter <= 0;
				end
				tail : begin
					digest_ready <= 1'b1;
					digest <= get_digest(digest_tmp);
					next_byte <= 1'b0;
					itr_counter <= 0;
				end
				message : begin
					digest_tmp <= update_digest(digest_tmp);
					//print_digest(digest_tmp);
					itr_counter <= itr_counter + 1;
				end
				default : begin
					$display("Error, case 11");
					digest_tmp <= update_digest(digest_tmp);
					//print_digest(digest_tmp);
					itr_counter <= itr_counter + 1;
				end
			endcase
			itr_enable <= 1'b1;
		end
		else begin
			// put to 0 and then to 1 in next iteration to wake up the tb
			next_byte <= 1'b0;
			digest_ready <= 1'b0;
			itr_counter <= 32'd0;
			itr_enable <= 1'b0;
		end
	end
	else begin
		next_byte <= 1'b1;
		itr_counter <= 32'd0;
    	itr_enable <= 1'b0;
	end

end


endmodule
