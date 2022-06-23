// -----------------------------------------------------------------------------
// ---- Testbench of light hash module for debug and corner cases check
// -----------------------------------------------------------------------------
module light_hash_tb_checks;

	reg clk = 1'b0;				// set the clock to 0
	always #10 clk = !clk; 		// set the clock time

	reg message_valid = 1'b0;   // set the register message_valid to 0

	reg rst_n = 1'b0;			// set the reset register to 0

	reg  [7:0] message_byte;    // register for the current ASCII of the message (composed of 8 bit)
	int not_valid = 0;

	wire digest_ready;			// register to specifies if the digest is ready to be read (1) or not (0)
	wire [63:0] digest;			// register where the final digest is stored (composed of 64 bit)

	light_hash lh (
	 .clk                       (clk)
	,.rst_n                     (rst_n)
	,.message_byte              (message_byte)
	,.message_valid				(message_valid)
	,.digest               		(digest)
	,.digest_ready              (digest_ready)
	,.err_invalid_message_byte  (err_invalid_message_byte)
	);


	initial begin
		@(posedge clk) rst_n = 1'b1;
	end

	//string rapresentation of the final digest and the error string
	string digest_str, err_str;

	//simulation
	initial begin
		// ----- battery test ----- //
		string m0 = "abcdefghijklmnopqrstuvwxyz";
		string d0_expected = "dcdfac61d4981831";
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b11111111;
		join
		@(posedge clk) message_valid = 1'b0;

		//FIRST STRING
		foreach(m0[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = m0[j];
			join
			if (err_invalid_message_byte) begin
				$display("Invalid input, the calculation of the digest is interrupt");
				not_valid = 1;
				break;
			end
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b00000000;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		if (!not_valid) begin
			digest_str = $sformatf("%0h", digest);
			$display("Digest string 0: %s", digest_str);
			if(digest_str == d0_expected)
				$display("Test ok, the digest is equal to the pre-calculate.");
			else
				$display("Test failed, the digest is different from to the pre-calculate: ", d0_expected);
		end
		// ----------------- BATTERY TEST 1 -----------------

		/*string m0 = "H4rdw4r3_Tr0j4n";

		string m1 = "AlessandroAndGiacomo";

		string m2 = "Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura, ché la diritta via era smarrita. Ahi quanto a dir qual era è cosa dura esta selva selvaggia e aspra e forte che nel pensier rinova la paura! Tant' è amara che poco è più morte; ma per trattar del ben ch'i' vi trovai, dirò de l'altre cose ch'i' v'ho scorte.";

		string m3 = "3.141592653589793238";

		string d0_expected = "5aecbf4f5fe467bc";
		string d1_expected = "e19e79abcdf021f1";
		string d2_expected = "4562953f89b4d2f5";
		string d3_expected = "f9e317d512022e21";
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b11111111;
		join
		@(posedge clk) message_valid = 1'b0;

		//FIRST STRING
		foreach(m0[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = m0[j];
			join
			if (err_invalid_message_byte) begin
				$display("Invalid input, the calculation of the digest is interrupt");
				not_valid = 1;
				break;
			end
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b00000000;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		if (!not_valid) begin
			digest_str = $sformatf("%0h", digest);
			$display("Digest string 0: %s", digest_str);
			if(digest_str == d0_expected)
				$display("Test ok, the digest is equal to the pre-calculate.");
			else
				$display("Test failed, the digest is different from to the pre-calculate: ", d0_expected);
		end



		//SECOND STRING
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b11111111;
		join
		@(posedge clk) message_valid = 1'b0;

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
		$display("Test ok, the digest is equal to the pre-calculate.");
	else
		$display("Test failed, the digest is different from to the pre-calculate: ", d1_expected);


		//THIRD STRING
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b11111111;
		join
		@(posedge clk) message_valid = 1'b0;

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
		$display("Test ok, the digest is equal to the pre-calculate.");
	else
		$display("Test failed, the digest is different from to the pre-calculate: ", d2_expected);


		//FOURTH STRING
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b11111111;
		join
		@(posedge clk) message_valid = 1'b0;

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
		$display("Test ok, the digest is equal to the pre-calculate.");
	else
		$display("Test failed, the digest is different from to the pre-calculate: ", d3_expected);

		*/
		@(posedge clk) $stop;
	end

endmodule
// -----------------------------------------------------------------------------
