// -----------------------------------------------------------------------------
// ---- Testbench of light hash module for debug and corner cases check
// -----------------------------------------------------------------------------
module light_hash_tb_checks;

	reg clk = 1'b0;
	always #10 clk = !clk;

	reg ptxt_valid = 1'b0;

	reg rst_n = 1'b0;
	//event reset_deassertion; // event(s), when asserted, can be used as time trigger(s) to synchronize with: e.g. refer to lines and 14 and 81
/*
	initial begin
	#12.8 rst_n = 1'b1;
	-> reset_deassertion; // trigger event named 'reset_deassertion'
	end
*/
	reg  [7:0] ptxt_char;
	
	wire digest_ready;
	wire [63:0] digest_char;

	light_hash lh (
	 .clk                       (clk)
	,.rst_n                     (rst_n)
	,.ptxt_char                 (ptxt_char)
	,.ptxt_valid				(ptxt_valid)
	,.digest_char               (digest_char)
	,.digest_ready              (digest_ready)
	,.err_invalid_ptxt_char     (/* Unconnected */)
	);

	//reg [7:0] EXPECTED_GEN;
	//reg [7:0] EXPECTED_CHECK;
	//reg [7:0] EXPECTED_QUEUE [$]; // Usage of $ to indicate unpacked dimension makes the array dynamic (similar to a C language dynamic array), that is called queue in SystemVerilog

	localparam NUL_CHAR = 8'h00;

	localparam UPPERCASE_A_CHAR = 8'h41;
	localparam UPPERCASE_Z_CHAR = 8'h5A;
	localparam LOWERCASE_A_CHAR = 8'h61;
	localparam LOWERCASE_Z_CHAR = 8'h7A;
	localparam LOWERBOUND_0_CHAR = 8'h30;
	localparam UPPERBOUND_9_CHAR = 8'h39;

	reg [7:0] digest_tmp = '{8'h34, 8'h55, 8'h0F, 8'h14, 8'hDA, 8'hC0, 8'h2B, 8'hEE};

	wire ptxt_char_is_uppercase_letter  = (ptxt_char >= UPPERCASE_A_CHAR)  && (ptxt_char <= UPPERCASE_Z_CHAR);
	wire ptxt_char_is_lowercase_letter  = (ptxt_char >= LOWERCASE_A_CHAR)  && (ptxt_char <= LOWERCASE_Z_CHAR);
	wire ptxt_char_is_letter            = ptxt_char_is_uppercase_letter    || ptxt_char_is_lowercase_letter;
	wire ptxt_char_is_number            = (ptxt_char >= LOWERBOUND_0_CHAR) && (ptxt_char <= UPPERBOUND_9_CHAR);
	wire err_invalid_ptxt_char_wire     = (!ptxt_char_is_letter)           && (!ptxt_char_is_number);

	// Tasks are similar to C/C++ functions: they can or cannot return values/objects and can or cannot have inputs;
	// in addition they can include time-based statements (e.g.: wait, posedge, negedge, ...)
	task expected_calc ( // Mi serve?
	 output [7:0] exp_char
	);

	if(err_invalid_ptxt_char_wire)
	  exp_char = NUL_CHAR;

	endtask

	initial begin 
		@(posedge clk) rst_n = 1'b1;
	end
	
	
	string string_out;


	initial begin   
		// ----------------- TEST VECTOR 1 -----------------
		// Message starts

	// ------ VARIABLE TO TEST HASH PROPERTIES ------
		string s0 = "abcdefghijklmnopqrstuvwxyz";
		//string s1 = "Hello";
		//string s2 = "World123456789";
		//string s3 = "World123456780";
		//for (int i = 0; i < 4; i++) begin
			fork
				@(posedge clk) ptxt_valid = 1'b1;
				@(posedge clk) ptxt_char = 8'b11111111;
			join
			@(posedge clk) ptxt_valid = 1'b0;
			case (0)//substitute i to zero when uncomment the for iterator
				0 : foreach(s0[j]) begin
						fork
							@(posedge clk) ptxt_valid = 1'b1;
							@(posedge clk) ptxt_char = s0[j];
						join
						@(posedge clk) ptxt_valid = 1'b0;
						wait(!lh.next_byte) @(posedge clk);
					end
				/*1 : foreach(s1[j]) begin
						fork
							@(posedge clk) ptxt_valid = 1'b1;
							@(posedge clk) ptxt_char = s1[j];
						join
						@(posedge clk) ptxt_valid = 1'b0;
						wait(!lh.next_byte) @(posedge clk);
					end
				2 : foreach(s2[j]) begin
						fork
							@(posedge clk) ptxt_valid = 1'b1;
							@(posedge clk) ptxt_char = s2[j];
						join
						@(posedge clk) ptxt_valid = 1'b0;
						wait(!lh.next_byte) @(posedge clk);
					end
				3 : foreach(s3[j]) begin
						fork
							@(posedge clk) ptxt_valid = 1'b1;
							@(posedge clk) ptxt_char = s3[j];
						join
						@(posedge clk) ptxt_valid = 1'b0;
						wait(!lh.next_byte) @(posedge clk);
					end*/		
			endcase
			string_out = $sformatf("%0h", digest_char);
			$display("%s", string_out);
			fork
				@(posedge clk) ptxt_valid = 1'b1;
				@(posedge clk) ptxt_char = 8'b00000000;
			join
			@(posedge clk) ptxt_valid = 1'b0;
			string_out = $sformatf("%0h", digest_char);
			$display("%s", string_out);

		//end
		@(posedge clk);
		@(posedge clk) $stop;	
	end

endmodule
// -----------------------------------------------------------------------------
