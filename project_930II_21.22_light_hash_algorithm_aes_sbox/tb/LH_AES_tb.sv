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
		string hp00 = "AlessandroAndGiacomo";
		string hp01 = "AlessandroandGiacomo";
		string hp10 = "Hardware_and_Embedded_Security";
		string hp11 = "Hardware_and_Embedded_Security";


		$display("\n---- BATTERY TEST ----");

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
		$display("\nInput message 0: %s", m0);
		$display("Output digest 0: %s", digest_str);
		if(digest_str == d0_expected)
			$display("Test ok, the digest is equal to precomputed one.");
		else
			$display("Test failed, the digest is different from precomputed one: %s", d0_expected);


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
		$display("\nInput message 1: %s", m1);
		$display("Output digest 1: %s", digest_str);
		if(digest_str == d1_expected)
			$display("Test ok, the digest is equal to precomputed one.");
		else
			$display("Test failed, the digest is different from precomputed one: %s", d1_expected);


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
		$display("\nInput message 2: %s", m2);
		$display("Output digest 2: %s", digest_str);
		if(digest_str == d2_expected)
			$display("Test ok, the digest is equal to precomputed one.");
	    else
			$display("Test failed, the digest is different from precomputed one: %s", d2_expected);




			// HASH PROPERTY 1: Check that two identical strings, except for one character,
			//									produce completely different digest values.
			$display("\n\n---- HASH PROPERTIES ----");

			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) state = HEAD;
			join
			@(posedge clk) message_valid = 1'b0;

			foreach(hp00[j]) begin
				fork
					@(posedge clk) message_valid = 1'b1;
					@(posedge clk) state = MESSAGE;
					@(posedge clk) message_byte = hp00[j];
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

			foreach(hp01[j]) begin
				fork
					@(posedge clk) message_valid = 1'b1;
					@(posedge clk) state = MESSAGE;
					@(posedge clk) message_byte = hp01[j];
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
			$display("\nInput Message 00: %s, Output Digest 00: %s", hp00, digest_str);
			$display("Input Message 01: %s, Output Digest 01: %s", hp01, digest_str2);
			if(digest_str != digest_str2)
				$display("Test ok, digests are different.");
			else
				$display("Test failed, digest are identical");


			// HASH PROPERTY 2: Check that two identical strings,
			//									produce indentical digest values.

			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) state = HEAD;
			join
			@(posedge clk) message_valid = 1'b0;

			foreach(hp10[j]) begin
				fork
					@(posedge clk) message_valid = 1'b1;
					@(posedge clk) state = MESSAGE;
					@(posedge clk) message_byte = hp10[j];
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

			foreach(hp11[j]) begin
				fork
					@(posedge clk) message_valid = 1'b1;
					@(posedge clk) state = MESSAGE;
					@(posedge clk) message_byte = hp11[j];
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
			$display("\nInput Message 10: %s, Output Digest 10: %s", hp10, digest_str);
			$display("Input Message 11: %s, Output Digest 11: %s", hp11, digest_str2);
			if(digest_str == digest_str2)
				$display("Test ok, digests are identical.\n\n");
			else
				$display("Test failed, digest are different\n\n");


		@(posedge clk) $stop;
	end

endmodule
