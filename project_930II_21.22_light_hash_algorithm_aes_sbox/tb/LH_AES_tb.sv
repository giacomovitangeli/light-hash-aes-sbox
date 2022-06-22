// -----------------------------------------------------------------------------
// ---- Testbench of light hash module for debug and corner cases check
// -----------------------------------------------------------------------------
module light_hash_tb_checks;

	reg clk = 1'b0;				// set the clock to 0
	always #10 clk = !clk; 		// set the clock time

	reg message_valid = 1'b0;   // set the register message_valid to 0

	reg rst_n = 1'b0;			// set the reset register to 0

	reg  [7:0] message_byte;    // register for the current ASCII of the message (composed of 8 bit)

	wire digest_ready;			// register to specifies if the digest is ready to be read (1) or not (0)
	wire [63:0] digest;			// register where the final digest is stored (composed of 64 bit)

	light_hash lh (
	 .clk                       (clk)
	,.rst_n                     (rst_n)
	,.message_byte              (message_byte)
	,.message_valid				(message_valid)
	,.digest               		(digest)
	,.digest_ready              (digest_ready)
	,.err_invalid_message_byte     (/* Unconnected */)
	);


	initial begin
		@(posedge clk) rst_n = 1'b1;
	end

	//string rapresentation of the final digest
	string digest_str;

	//simulation
	initial begin
		// ----------------- BATTERY TEST 1 -----------------

		string m0 = "abcdefghijklmnopqrstuvwxyz";

		string m1 = "H4rdw4r3_Tr0j4n";

		string m2 = "AlessandroAndGiacomo";

		string m3 = "3.1415926	53589793238";

		string d0_expected = "dcdfac61d4981831";
		string d1_expected = "1abaa6f939b1cb79";
		string d2_expected = "865d11a728f1e4b6";
		string d3_expected = "3b4c7321510469a1";
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b11111111;
		join
		@(posedge clk) message_valid = 1'b0;
		//case (0)//substitute i to zero when uncomment the for iterator

		//FIRST STRING
		foreach(m0[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = m0[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b00000000;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str = $sformatf("%0h", digest);
		$display("Digest string 0: %s", digest_str);
		if(digest_str == d0_expected)
			$display("Test ok, the digest is equal to the pre-calculate.", digest_str);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		//SECOND STRING
		foreach(m1[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = m1[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b00000000;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str = $sformatf("%0h", digest);
		$display("Digest string 1: %s", digest_str);
		if(digest_str == d1_expected)
			$display("Test ok, the digest is equal to the pre-calculate.", digest_str);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		//THIRD STRING
		foreach(m2[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = m2[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b00000000;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str = $sformatf("%0h", digest);
		$display("Digest string 2: %s", digest_str);
		if(digest_str == d2_expected)
			$display("Test ok, the digest is equal to the pre-calculate.", digest_str);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		//FOURTH STRING
		foreach(m3[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = m3[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b00000000;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str = $sformatf("%0h", digest);
		$display("Digest string 3: %s", digest_str);
		if(digest_str == d3_expected)
			$display("Test ok, the digest is equal to the pre-calculate.", digest_str);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		@(posedge clk) $stop;
	end

endmodule
// -----------------------------------------------------------------------------
