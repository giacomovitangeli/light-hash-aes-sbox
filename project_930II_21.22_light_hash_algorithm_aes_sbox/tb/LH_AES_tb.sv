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

	// local variable correspond to a NULL char
	localparam NUL_CHAR = 8'h00;

	localparam UPPERCASE_A_CHAR = 8'h41;
	localparam UPPERCASE_Z_CHAR = 8'h5A;
	localparam LOWERCASE_A_CHAR = 8'h61;
	localparam LOWERCASE_Z_CHAR = 8'h7A;
	localparam LOWERBOUND_0_CHAR = 8'h30;
	localparam UPPERBOUND_9_CHAR = 8'h39;

	reg [7:0] digest_tmp = '{8'h34, 8'h55, 8'h0F, 8'h14, 8'hDA, 8'hC0, 8'h2B, 8'hEE};

	wire message_byte_is_uppercase_letter  = (message_byte >= UPPERCASE_A_CHAR)  && (message_byte <= UPPERCASE_Z_CHAR);
	wire message_byte_is_lowercase_letter  = (message_byte >= LOWERCASE_A_CHAR)  && (message_byte <= LOWERCASE_Z_CHAR);
	wire message_byte_is_letter            = message_byte_is_uppercase_letter    || message_byte_is_lowercase_letter;
	wire message_byte_is_number            = (message_byte >= LOWERBOUND_0_CHAR) && (message_byte <= UPPERBOUND_9_CHAR);
	wire err_invalid_message_byte_wire     = (!message_byte_is_letter)           && (!message_byte_is_number);

	// Tasks are similar to C/C++ functions: they can or cannot return values/objects and can or cannot have inputs;
	// in addition they can include time-based statements (e.g.: wait, posedge, negedge, ...)
	task expected_calc ( // Mi serve?
	 output [7:0] exp_char
	);

	if(err_invalid_message_byte_wire)
	  exp_char = NUL_CHAR;

	endtask

	initial begin
		@(posedge clk) rst_n = 1'b1;
	end

	string bin_out;				// the byte rapresentation of the final digest
	string string_out;			// the string rapresentation of the final digest

	//simulation
	initial begin
		// ----------------- BATTERY TEST 1 -----------------

		string s0 = "abcdefghijklmnopqrstuvwxyz";
		string s1 = "Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura ché la diritta via era smarrita. Ahi quanto a dir qual era è cosa dura esta selva selvaggia e aspra e forte che nel pensier rinova la paura! Tant’è amara che poco è più morte; ma per trattar del ben ch’i’ vi trovai, dirò de l’altre cose ch’i’ v’ho scorte. Io non so ben ridir com’i’ v’intrai, tant’era pien di sonno a quel punto che la verace via abbandonai. Ma poi ch’i’ fui al piè d’un colle giunto, là dove terminava quella valle che m’avea di paura il cor compunto, guardai in alto, e vidi le sue spalle vestite già de’ raggi del pianeta che mena dritto altrui per ogne calle.";
		string s2 = "AlessandroAndGiacomo";
		string s3 = "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278";

		string s01 = "dcdfac61d4981831";
		string s11 = "1abaa6f939b1cb79";
		string s21 = "865d11a728f1e4b6";
		string s31 = "3b4c7321510469a1";
		fork
			@(posedge clk) message_valid = 1'b1;
			@(posedge clk) message_byte = 8'b11111111;
		join
		@(posedge clk) message_valid = 1'b0;
		//case (0)//substitute i to zero when uncomment the for iterator

		/**** FIRST STRING ****/
		foreach(s0[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = s0[j];
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
		string_out = $sformatf("%0h", digest);
		$display("Digest string 0: %s", string_out);
		if(string_out == s01)
			$display("Test ok, the digest is equal to the pre-calculate.", string_out);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		/**** SECOND STRING ****/
		foreach(s1[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = s1[j];
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
		string_out = $sformatf("%0h", digest);
		$display("Digest string 1: %s", string_out);
		if(string_out == s11)
			$display("Test ok, the digest is equal to the pre-calculate.", string_out);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		/**** THIRD STRING ****/
		foreach(s2[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = s2[j];
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
		string_out = $sformatf("%0h", digest);
		$display("Digest string 2: %s", string_out);
		if(string_out == s21)
			$display("Test ok, the digest is equal to the pre-calculate.", string_out);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		/**** FOURTH STRING ****/
		foreach(s3[j]) begin
			fork
				@(posedge clk) message_valid = 1'b1;
				@(posedge clk) message_byte = s3[j];
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
		string_out = $sformatf("%0h", digest);
		$display("Digest string 3: %s", string_out);
		if(string_out == s31)
			$display("Test ok, the digest is equal to the pre-calculate.", string_out);
		else
			$display("Test failed, the digest is different from to the pre-calculate.");


		@(posedge clk) $stop;
	end

endmodule
// -----------------------------------------------------------------------------
