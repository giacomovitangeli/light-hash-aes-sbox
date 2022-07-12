module light_hash_tb_checks;
	reg clk = 1'b0;				// set the clock to 0
	reg message_valid = 1'b0;   // validity is 0 by default
	reg [1:0] state = 2'b11;    // state = 2'b00 => HEAD of the messagge, 2'b01 => TAIL, 2'b10 MESSAGE e default 2'b11
	reg rst_n = 1'b0;			// set the reset register to 0
	reg  [7:0] message_byte;    // current ASCII char of the input MESSAGE (8 bit)

	wire digest_ready;			// enable the read of the final digest with 1, otherwise disable with 0
	wire [63:0] digest;			// final output digest of 64 bit


	light_hash lh (
	 .clk                       (clk)
	,.rst_n                     (rst_n)
	,.message_byte              (message_byte)
	,.message_valid				(message_valid)
	,.state                     (state)
	,.digest               		(digest)
	,.digest_ready              (digest_ready)
	);

	//values of the state register
	localparam  HEAD = 2'b00;
	localparam  MESSAGE = 2'b10;
	localparam  TAIL = 2'b01;

	always #10 clk = !clk; 		// set the clock time

	initial begin
		@(posedge clk) rst_n = 1'b1;
	end

	//strings to display the final digest
	string digest_str, digest_str2;

	//simulation begin
	initial begin

		// BATTERY TEST
		//input messages to test
		string m0 = "H4rdw4r3_Tr0j4n";
		string m1 = "Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura, ché la diritta via era smarrita. Ahi quanto a dir qual era è cosa dura esta selva selvaggia e aspra e forte che nel pensier rinova la paura! Tant' è amara che poco è più morte; ma per trattar del ben ch'i' vi trovai, dirò de l'altre cose ch'i' v'ho scorte.";
		string m2 = "3.141592653589793238";

		//expected output digests
		string d0_expected = "5aecbf4f5fe467bc";
		string d1_expected = "4562953f89b4d2f5";
		string d2_expected = "f9e317d512022e21";

		//input messages to check hash property
		string hp1 = "AlessandroAndGiacomo";
		string hp2 = "AlessandroandGiacomo";

		//expected output digest to check hash property
		string hp1_expected = "e19e79abcdf021f1";
		string hp2_expected = "48f63b14b5c40a5a";


		//set the state of the machine to HEAD value
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = HEAD;
		join
		@(posedge clk) message_valid = 1'b0;


		// FIRST STRING
		foreach(m0[j]) begin
			//set the state of the machine to MESSAGE value
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) state = MESSAGE;
				@(posedge clk) message_byte = m0[j];
			join
			@(posedge clk) message_valid = 1'b0;
			// wait until the signal next_byte is set to 1
			wait(!lh.next_byte) @(posedge clk);
		end

		//set the state of the machine to TAIL value
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = TAIL;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);

		//convert bin final digest into a string to display its value
		digest_str = $sformatf("%0h", digest);
		$display("Digest string 0: %s", digest_str);
		if(digest_str == d0_expected)
			$display("Test ok, the digest is equal to the pre-calculated.");
		else
			$display("Test failed, the digest is different from pre-calculated: %s", d0_expected);


		// SECOND STRING
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = HEAD;
		join
		@(posedge clk) message_valid = 1'b0;

		foreach(m1[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) state = MESSAGE;
				@(posedge clk) message_byte = m1[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end

		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = TAIL;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str = $sformatf("%0h", digest);
		$display("Digest string 1: %s", digest_str);
		if(digest_str == d1_expected)
			$display("Test ok, the digest is equal to the pre-calculated.");
		else
			$display("Test failed, the digest is different from pre-calculated: %s", d1_expected);


		// THIRD STRING
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = HEAD;
		join
		@(posedge clk) message_valid = 1'b0;

		foreach(m2[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) state = MESSAGE;
				@(posedge clk) message_byte = m2[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end

		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = TAIL;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str = $sformatf("%0h", digest);
		$display("Digest string 2: %s", digest_str);
		if(digest_str == d2_expected)
			$display("Test ok, the digest is equal to the pre-calculated.");
	    else
			$display("Test failed, the digest is different from pre-calculated: %s", d2_expected);


		// HASH PROPERTIES: Check that two identical strings, except for one character,
		//									produce completely different digest values.
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = HEAD;
		join
		@(posedge clk) message_valid = 1'b0;

		foreach(hp1[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) state = MESSAGE;
				@(posedge clk) message_byte = hp1[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end

		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = TAIL;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str = $sformatf("%0h", digest);
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = HEAD;
		join
		@(posedge clk) message_valid = 1'b0;

		foreach(hp2[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) state = MESSAGE;
				@(posedge clk) message_byte = hp2[j];
			join
			@(posedge clk) message_valid = 1'b0;
			wait(!lh.next_byte) @(posedge clk);
		end
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) state = TAIL;
		join
		@(posedge clk) message_valid = 1'b0;
		@(posedge clk);
		digest_str2 = $sformatf("%0h", digest);
		$display("\n\nString hp1: %s, vs string hp2: %s", hp1, hp2);
		$display("Digest hp1: %s, vs digest hp2: %s", digest_str, digest_str2);
		if((digest_str == hp1_expected) && (digest_str2 == hp2_expected))
			$display("Test ok, the digest is equal to the pre-calculated.\n\n");
		else
			$display("Test failed, the digest is different from pre-calculated: %s\n\n", d1_expected);

		@(posedge clk) $stop;
	end

endmodule
