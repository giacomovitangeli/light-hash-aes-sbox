// `define NULL_CHAR 8'h00
//
// module caesar_cipher (
//    input            clk
//   ,input            rst_n
//   ,input            key_shift_dir // 1'b0 = right shift; 1'b1 = left shift
//   ,input      [4:0] key_shift_num // range [0÷26]
//   ,input      [7:0] ptxt_char
//   ,output reg [7:0] ctxt_char
//   ,output           err_invalid_key_shift_num
//   ,output           err_invalid_ptxt_char
// );
//
//   // ---------------------------------------------------------------------------
//   // Variables
//   // ---------------------------------------------------------------------------
//   // localparam NULL_CHAR = 8'h00; --> defined as macro `NULL_CHAR (line 1)
//
//   localparam UPPERCASE_A_CHAR = 8'h41;  // ASCII code for 'A'
//   localparam UPPERCASE_Z_CHAR = 8'h5A;  // ASCII code for 'Z'
//   localparam LOWERCASE_A_CHAR = 8'h61;  // ASCII code for 'a'
//   localparam LOWERCASE_Z_CHAR = 8'h7A;  // ASCII code for 'z'
//
//   wire       ptxt_char_is_uppercase_letter;
//   wire       ptxt_char_is_lowercase_letter;
//   wire       ptxt_char_is_letter;
//
//   reg  [7:0] sub_letter;
//
//   // ---------------------------------------------------------------------------
//   // Logic Design
//   // ---------------------------------------------------------------------------
//   assign err_invalid_key_shift_num = key_shift_num > 26;
//
//   assign ptxt_char_is_uppercase_letter = (ptxt_char >= UPPERCASE_A_CHAR) &&
//                                          (ptxt_char <= UPPERCASE_Z_CHAR);
//
//   assign ptxt_char_is_lowercase_letter = (ptxt_char >= LOWERCASE_A_CHAR) &&
//                                          (ptxt_char <= LOWERCASE_Z_CHAR);
//
//   assign ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
//                                ptxt_char_is_lowercase_letter;
//
//   assign err_invalid_ptxt_char = !ptxt_char_is_letter;
//
//   // Substitution law (with checks)
//   always @ (*)
//     /* Right shift */
//     if(!key_shift_dir) begin
//       sub_letter = ptxt_char + {3'b000, key_shift_num}; // Shift
//       // -----------------------------------------------------------------
//       if(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR))  // Check if "overflow" (uppercase letter case)...
//         sub_letter -= 8'h1A;                                                // ... and wrap if so
//       if(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))  // Check if "overflow" (lowercase letter case)...
//         sub_letter -= 8'h1A;                                                // ... and wrap if so
//       // -----------------------------------------------------------------
//       //
//       //  Alternative version of code at lines 52-55: it's (almost) the same
//       /*
//       if(
//         (ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
//         (ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
//       )
//         sub_letter -= 8'h1A;
//       */
//       // -----------------------------------------------------------------
//     end
//     /* Left shift */
//     else begin
//       sub_letter = ptxt_char - {3'b000, key_shift_num};
//       if(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR))
//         sub_letter += 8'h1A;
//       if(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
//         sub_letter += 8'h1A;  // the same as: sub_letter = sub_letter + 8'h1A
//     end
//
//   // Output char (ciphertext)
//   always @ (posedge clk or negedge rst_n)
//     if(!rst_n)
//       ctxt_char <= `NULL_CHAR;
//     else if(err_invalid_ptxt_char || err_invalid_key_shift_num)
//       ctxt_char <= `NULL_CHAR;
//     else
//       ctxt_char <= sub_letter;
//
//
// endmodule































`define NULL_CHAR 8'h00

module caesar_cipher (
   input            clk
  ,input            rst_n
  ,input            key_shift_dir // 1'b0 = right shift; 1'b1 = left shift
  ,input      [4:0] key_shift_num // range [0÷26]
  ,input      [7:0] ptxt_char
  ,output reg [7:0] ctxt_char
  // ,output           err_invalid_key_shift_num
  // ,output           err_invalid_ptxt_char
  ,output reg       err_invalid_key_shift_num
  ,output reg       err_invalid_ptxt_char
);

  // ---------------------------------------------------------------------------
  // Variables
  // ---------------------------------------------------------------------------
  // localparam NULL_CHAR = 8'h00; --> defined as macro `NULL_CHAR (line 1)

  localparam UPPERCASE_A_CHAR = 8'h41;  // ASCII code for 'A'
  localparam UPPERCASE_Z_CHAR = 8'h5A;  // ASCII code for 'Z'
  localparam LOWERCASE_A_CHAR = 8'h61;  // ASCII code for 'a'
  localparam LOWERCASE_Z_CHAR = 8'h7A;  // ASCII code for 'z'

  wire       ptxt_char_is_uppercase_letter;
  wire       ptxt_char_is_lowercase_letter;
  wire       ptxt_char_is_letter;

  reg  [7:0] sub_letter;

  // ---------------------------------------------------------------------------
  // Logic Design
  // ---------------------------------------------------------------------------
  // assign err_invalid_key_shift_num = key_shift_num > 26;
  wire err_invalid_key_shift_num_wire = key_shift_num > 26;

  assign ptxt_char_is_uppercase_letter = (ptxt_char >= UPPERCASE_A_CHAR) &&
                                         (ptxt_char <= UPPERCASE_Z_CHAR);

  assign ptxt_char_is_lowercase_letter = (ptxt_char >= LOWERCASE_A_CHAR) &&
                                         (ptxt_char <= LOWERCASE_Z_CHAR);

  assign ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
                               ptxt_char_is_lowercase_letter;

  // assign err_invalid_ptxt_char = !ptxt_char_is_letter;
  wire err_invalid_ptxt_char_wire = !ptxt_char_is_letter;

  always @ (posedge clk or negedge rst_n)
    if(!rst_n) begin
      err_invalid_key_shift_num <= 1'b0;
      err_invalid_ptxt_char     <= 1'b0;
    end else begin
      err_invalid_key_shift_num <= err_invalid_key_shift_num_wire;
      err_invalid_ptxt_char     <= err_invalid_ptxt_char_wire;
    end

  // Substitution law (with checks)
  always @ (*)
    /* Right shift */
    if(!key_shift_dir) begin
      sub_letter = ptxt_char + {3'b000, key_shift_num}; // Shift
      if(
        (ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
        (ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
      )
        sub_letter -= 8'h1A;
    end
    /* Left shift */
    else begin
      sub_letter = ptxt_char - {3'b000, key_shift_num};
      if(
        (ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) ||
        (ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
      )
        sub_letter += 8'h1A;
    end

  // Output char (ciphertext)
  always @ (posedge clk or negedge rst_n)
    if(!rst_n)
      ctxt_char <= `NULL_CHAR;
    else if(err_invalid_ptxt_char_wire || err_invalid_key_shift_num_wire)
      ctxt_char <= `NULL_CHAR;
    else
      ctxt_char <= sub_letter;


endmodule
