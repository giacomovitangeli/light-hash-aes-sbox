// -----------------------------------------------------------------------------
// ---- Testbench of light hash module for debug and corner cases check
// -----------------------------------------------------------------------------
module light_hash_tb_checks;

  reg clk = 1'b0;
  always #10 clk = !clk;

  reg rst_n = 1'b0;
  event reset_deassertion; // event(s), when asserted, can be used as time trigger(s) to synchronize with: e.g. refer to lines and 14 and 81

  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion; // trigger event named 'reset_deassertion'
  end

  reg  [7:0] ptxt_char;
  wire [63:0] ctxt_char;

  LH_AES INSTANCE_NAME (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_char                 (ctxt_char)
    ,.digest_char               (digest_char)
    ,.digest_ready              (digest_ready)
    ,.err_invalid_ptxt_char     (/* Unconnected */)
  );

  reg [7:0] EXPECTED_GEN;
  reg [7:0] EXPECTED_CHECK;
  reg [7:0] EXPECTED_QUEUE [$]; // Usage of $ to indicate unpacked dimension makes the array dynamic (similar to a C language dynamic array), that is called queue in SystemVerilog

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
    // ------------------------------------------------------------------
    @(reset_deassertion); // Hook reset deassertion (event)
    // ------------------------------------------------------------------
    // Alternative:
    // do not create event reset_deassertion, keep rst_n with same behaviour, and here replace with...
    // @(posedge rst_n);
    // ------------------------------------------------------------------

    @(posedge clk);   // Hook next rising edge of signal clk (used as clock)

    fork  // -------------------------------------------------------------------

      begin: STIMULI_1R
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end

        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1R

      begin: CHECK_1R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1R

    join  // closing fork at line 92 -------------------------------------------

    // -------------------------------------------------------------------------
    /*  SystemVerilog offers the fork-join statement that works like in C language
        Use cases:
          1.  fork
                <...>
                <...>
              join
          // -- wait for all actions within fork - join are completed: the simulation hangs within this block until all actions are completed.
                Pay attention to the kind of actions specified and their duration.

          2.  fork
                <...>
                <...>
              join_none
          // -- no wait of actions within fork - join_none: all actions are launched without waiting for their completion, hence the simulation continues
                with the next statement after the join_none keyword, independently if actions within fork - join_none are completed or not. In this case
                it can be very useful to name the actions (or blocks, delimited by a begin - end couple) with a label, in order to eventually disable them
                with the statement disable, e.g.: refer to begin - end block starting at line 126, whose name is STIMULI_1R, it could be disable by using
                the statement 'disable STIMULI_1R;'.
                The usage of fork - join_none is useful in case some tasks or actions need to be run and executed in background while continuing with the
                simulation.

          3.  fork
                <...>
                <...>
              join_any
          // -- wait only the first action within fork - join_any is completed: all actions are launched and just the first one which is completed makes the
                simulation exit from the fork - join_any block and continues with the statements after the join_any keyword; all other actions of fork - join_any
                block that are not concluded are still executed in background. Also in this case, the usage of labels for actions/blocks (begin - end) inside
                the fork - join_any block allows to disable them later, if required.
    */
    // -------------------------------------------------------------------------

    @(posedge clk);
    shift_dir = 1'b1; // Set shift direction to left; note: number of positions to be shifted is unmodified, hence it is still 1, as set at line 90

    fork  // -------------------------------------------------------------------

      begin: STIMULI_1L
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end

        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1L

      begin: CHECK_1L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1L

    join  // closing fork at line 158 ------------------------------------------

    @(posedge clk);
    shift_dir = 1'b0; // Set shift direction to right
    shift_N   = 5'd5; // Set number of positions to be shifted to 5

    fork  // -------------------------------------------------------------------

      begin: STIMULI_5R
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end

        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_5R

      begin: CHECK_5R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_5R

    join  // closing fork at line 192 ------------------------------------------

    @(posedge clk);
    shift_dir = 1'b1;

    fork  // -------------------------------------------------------------------

      begin: STIMULI_5L
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end

        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_5L

      begin: CHECK_5L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_5L

    join  // closing fork at line 225 ------------------------------------------

    @(posedge clk);
    shift_dir = 1'b0; // Set shift direction to right
    shift_N   = 5'd5; // Set number of positions to be shifted to 5

    fork  // -------------------------------------------------------------------

      begin: STIMULI_1R_FULL_SWEEP
        for(int i = 0; i < 128; i++) begin
          ptxt_char = 8'h00 + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1R_FULL_SWEEP

      begin: CHECK_1R_FULL_SWEEP
        @(posedge clk);
        for(int j = 0; j < 128; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1R_FULL_SWEEP

    join  // closing fork at line 259 ------------------------------------------

    @(posedge clk);
    shift_dir = 1'b0;   // Set shift direction to right
    shift_N   = 5'd27;  // Set number of positions to be shifted to 27

    fork  // -------------------------------------------------------------------

      begin: STIMULI_1R_INVALID_SHIFT_N
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end

        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
          expected_calc(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: STIMULI_1R_INVALID_SHIFT_N

      begin: CHECK_1R_INVALID_SHIFT_N
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("%c %c %-5s", ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: CHECK_1R_INVALID_SHIFT_N

    join  // closing fork at line 286 ------------------------------------------

    $stop;

  end

endmodule
/* ################################################################################################################################################################## */

// -----------------------------------------------------------------------------
// ---- Testbench for file encryption
// -----------------------------------------------------------------------------
module caesar_ciph_tb_file_enc;

  reg clk = 1'b0;
  always #5 clk = !clk;

  reg rst_n = 1'b0;
  initial #12.8 rst_n = 1'b1;

  reg        shift_dir;
  reg  [4:0] shift_N;
  reg  [7:0] ptxt_char;
  wire [7:0] ctxt_char;

  caesar_cipher INSTANCE_NAME (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.key_shift_dir             (shift_dir)
    ,.key_shift_num             (shift_N)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_char                 (ctxt_char)
    ,.err_invalid_key_shift_num (/* Unconnected */)
    ,.err_invalid_ptxt_char     (/* Unconnected */)
  );

  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;

  int FP_PTXT;
  int FP_CTXT;
  string char;
  reg [7:0] CTXT [$];
  reg [7:0] PTXT [$];

  initial begin
    @(posedge rst_n);

    @(posedge clk);
    FP_PTXT = $fopen("tv/ptxt.txt", "r");
    $write("Hash file 'tv/ptxt.txt' to 'tv/ctxt.txt'... ");
    shift_dir = 1'b0;
    shift_N = 5'd2;

    while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        CTXT.push_back(ctxt_char);
      end
      else
        CTXT.push_back(ptxt_char);
    end
    $fclose(FP_PTXT);

    FP_CTXT = $fopen("tv/ctxt.txt", "w");
    foreach(CTXT[i])
      $fwrite(FP_CTXT, "%c", CTXT[i]);
    $fclose(FP_CTXT);

    $display("Done!");

    @(posedge clk);
    FP_CTXT = $fopen("tv/ctxt.txt", "r");
    $write("Decrypting file 'tv/ctxt.txt' to 'tv/dec.txt'... ");
    shift_dir = 1'b1;
    shift_N = 5'd2;

    while($fscanf(FP_CTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        PTXT.push_back(ctxt_char);
      end
      else
        PTXT.push_back(ptxt_char);
    end
    $fclose(FP_CTXT);

    FP_PTXT = $fopen("tv/dec.txt", "w");
    foreach(PTXT[i])
      $fwrite(FP_PTXT, "%c", PTXT[i]);
    $fclose(FP_PTXT);

    $display("Done!");

    $stop;
  end

endmodule
// -----------------------------------------------------------------------------
