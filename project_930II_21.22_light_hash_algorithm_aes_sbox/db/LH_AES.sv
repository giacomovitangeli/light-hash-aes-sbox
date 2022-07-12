`define NULL_CHAR 8'h00
typedef reg [7:0] array [0:7];


module light_hash (
	input              clk			    // clock
	,input             rst_n			// reset
	,input		[7:0]  message_byte	    // 8 bit input
	,input			   message_valid	// define the validity of the input 8 bit message
	,input 		[1:0]  state			// state = 2'b00 => HEAD of the messagge, 2'b01 => TAIL, 2'b10 MESSAGE e default 2'b11
	,output reg [63:0] digest	        // 64 bit digest output --> composition of 8 blocks H[i] of 8 bit
	,output reg		   digest_ready	    // hash function of the input message is completed
	);


localparam  HEAD = 2'b00;
localparam  TAIL = 2'b01;
localparam  MESSAGE = 2'b10;
// init digest
localparam reg [7:0] restore_digest [0:7] = '{8'h34, 8'h55, 8'h0F, 8'h14, 8'hDA, 8'hC0, 8'h2B, 8'hEE};


// VARIABLES

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


// FUNCTIONS

function logic [7:0] aes128_sbox;
  input [7:0] sbox_in;
	case (sbox_in[7:0])
		8'h00:	aes128_sbox[7:0] = 8'h63;
		8'h01:	aes128_sbox[7:0] = 8'h7c;
		8'h02:	aes128_sbox[7:0] = 8'h77;
		8'h03:	aes128_sbox[7:0] = 8'h7b;
		8'h04:	aes128_sbox[7:0] = 8'hf2;
		8'h05:	aes128_sbox[7:0] = 8'h6b;
		8'h06:	aes128_sbox[7:0] = 8'h6f;
		8'h07:	aes128_sbox[7:0] = 8'hc5;
		8'h08:	aes128_sbox[7:0] = 8'h30;
		8'h09:	aes128_sbox[7:0] = 8'h01;
		8'h0a:	aes128_sbox[7:0] = 8'h67;
		8'h0b:	aes128_sbox[7:0] = 8'h2b;
		8'h0c:	aes128_sbox[7:0] = 8'hfe;
		8'h0d:	aes128_sbox[7:0] = 8'hd7;
		8'h0e:	aes128_sbox[7:0] = 8'hab;
		8'h0f:	aes128_sbox[7:0] = 8'h76;
		//----------------------------
		8'h10:	aes128_sbox[7:0] = 8'hca;
		8'h11:	aes128_sbox[7:0] = 8'h82;
		8'h12:	aes128_sbox[7:0] = 8'hc9;
		8'h13:	aes128_sbox[7:0] = 8'h7d;
		8'h14:	aes128_sbox[7:0] = 8'hfa;
		8'h15:	aes128_sbox[7:0] = 8'h59;
		8'h16:	aes128_sbox[7:0] = 8'h47;
		8'h17:	aes128_sbox[7:0] = 8'hf0;
		8'h18:	aes128_sbox[7:0] = 8'had;
		8'h19:	aes128_sbox[7:0] = 8'hd4;
		8'h1a:	aes128_sbox[7:0] = 8'ha2;
		8'h1b:	aes128_sbox[7:0] = 8'haf;
		8'h1c:	aes128_sbox[7:0] = 8'h9c;
		8'h1d:	aes128_sbox[7:0] = 8'ha4;
		8'h1e:	aes128_sbox[7:0] = 8'h72;
		8'h1f:	aes128_sbox[7:0] = 8'hc0;
		//----------------------------
		8'h20:	aes128_sbox[7:0] = 8'hb7;
		8'h21:	aes128_sbox[7:0] = 8'hfd;
		8'h22:	aes128_sbox[7:0] = 8'h93;
		8'h23:	aes128_sbox[7:0] = 8'h26;
		8'h24:	aes128_sbox[7:0] = 8'h36;
		8'h25:	aes128_sbox[7:0] = 8'h3f;
		8'h26:	aes128_sbox[7:0] = 8'hf7;
		8'h27:	aes128_sbox[7:0] = 8'hcc;
		8'h28:	aes128_sbox[7:0] = 8'h34;
		8'h29:	aes128_sbox[7:0] = 8'ha5;
		8'h2a:	aes128_sbox[7:0] = 8'he5;
		8'h2b:	aes128_sbox[7:0] = 8'hf1;
		8'h2c:	aes128_sbox[7:0] = 8'h71;
		8'h2d:	aes128_sbox[7:0] = 8'hd8;
		8'h2e:	aes128_sbox[7:0] = 8'h31;
		8'h2f:	aes128_sbox[7:0] = 8'h15;
		//----------------------------
		8'h30:	aes128_sbox[7:0] = 8'h04;
		8'h31:	aes128_sbox[7:0] = 8'hc7;
		8'h32:	aes128_sbox[7:0] = 8'h23;
		8'h33:	aes128_sbox[7:0] = 8'hc3;
		8'h34:	aes128_sbox[7:0] = 8'h18;
		8'h35:	aes128_sbox[7:0] = 8'h96;
		8'h36:	aes128_sbox[7:0] = 8'h05;
		8'h37:	aes128_sbox[7:0] = 8'h9a;
		8'h38:	aes128_sbox[7:0] = 8'h07;
		8'h39:	aes128_sbox[7:0] = 8'h12;
		8'h3a:	aes128_sbox[7:0] = 8'h80;
		8'h3b:	aes128_sbox[7:0] = 8'he2;
		8'h3c:	aes128_sbox[7:0] = 8'heb;
		8'h3d:	aes128_sbox[7:0] = 8'h27;
		8'h3e:	aes128_sbox[7:0] = 8'hb2;
		8'h3f:	aes128_sbox[7:0] = 8'h75;
		//----------------------------
		8'h40:	aes128_sbox[7:0] = 8'h09;
		8'h41:	aes128_sbox[7:0] = 8'h83;
		8'h42:	aes128_sbox[7:0] = 8'h2c;
		8'h43:	aes128_sbox[7:0] = 8'h1a;
		8'h44:	aes128_sbox[7:0] = 8'h1b;
		8'h45:	aes128_sbox[7:0] = 8'h6e;
		8'h46:	aes128_sbox[7:0] = 8'h5a;
		8'h47:	aes128_sbox[7:0] = 8'ha0;
		8'h48:	aes128_sbox[7:0] = 8'h52;
		8'h49:	aes128_sbox[7:0] = 8'h3b;
		8'h4a:	aes128_sbox[7:0] = 8'hd6;
		8'h4b:	aes128_sbox[7:0] = 8'hb3;
		8'h4c:	aes128_sbox[7:0] = 8'h29;
		8'h4d:	aes128_sbox[7:0] = 8'he3;
		8'h4e:	aes128_sbox[7:0] = 8'h2f;
		8'h4f:	aes128_sbox[7:0] = 8'h84;
		//----------------------------
		8'h50:	aes128_sbox[7:0] = 8'h53;
		8'h51:	aes128_sbox[7:0] = 8'hd1;
		8'h52:	aes128_sbox[7:0] = 8'h00;
		8'h53:	aes128_sbox[7:0] = 8'hed;
		8'h54:	aes128_sbox[7:0] = 8'h20;
		8'h55:	aes128_sbox[7:0] = 8'hfc;
		8'h56:	aes128_sbox[7:0] = 8'hb1;
		8'h57:	aes128_sbox[7:0] = 8'h5b;
		8'h58:	aes128_sbox[7:0] = 8'h6a;
		8'h59:	aes128_sbox[7:0] = 8'hcb;
		8'h5a:	aes128_sbox[7:0] = 8'hbe;
		8'h5b:	aes128_sbox[7:0] = 8'h39;
		8'h5c:	aes128_sbox[7:0] = 8'h4a;
		8'h5d:	aes128_sbox[7:0] = 8'h4c;
		8'h5e:	aes128_sbox[7:0] = 8'h58;
		8'h5f:	aes128_sbox[7:0] = 8'hcf;
		//----------------------------
		8'h60:	aes128_sbox[7:0] = 8'hd0;
		8'h61:	aes128_sbox[7:0] = 8'hef;
		8'h62:	aes128_sbox[7:0] = 8'haa;
		8'h63:	aes128_sbox[7:0] = 8'hfb;
		8'h64:	aes128_sbox[7:0] = 8'h43;
		8'h65:	aes128_sbox[7:0] = 8'h4d;
		8'h66:	aes128_sbox[7:0] = 8'h33;
		8'h67:	aes128_sbox[7:0] = 8'h85;
		8'h68:	aes128_sbox[7:0] = 8'h45;
		8'h69:	aes128_sbox[7:0] = 8'hf9;
		8'h6a:	aes128_sbox[7:0] = 8'h02;
		8'h6b:	aes128_sbox[7:0] = 8'h7f;
		8'h6c:	aes128_sbox[7:0] = 8'h50;
		8'h6d:	aes128_sbox[7:0] = 8'h3c;
		8'h6e:	aes128_sbox[7:0] = 8'h9f;
		8'h6f:	aes128_sbox[7:0] = 8'ha8;
		//----------------------------
		8'h70:	aes128_sbox[7:0] = 8'h51;
		8'h71:	aes128_sbox[7:0] = 8'ha3;
		8'h72:	aes128_sbox[7:0] = 8'h40;
		8'h73:	aes128_sbox[7:0] = 8'h8f;
		8'h74:	aes128_sbox[7:0] = 8'h92;
		8'h75:	aes128_sbox[7:0] = 8'h9d;
		8'h76:	aes128_sbox[7:0] = 8'h38;
		8'h77:	aes128_sbox[7:0] = 8'hf5;
		8'h78:	aes128_sbox[7:0] = 8'hbc;
		8'h79:	aes128_sbox[7:0] = 8'hb6;
		8'h7a:	aes128_sbox[7:0] = 8'hda;
		8'h7b:	aes128_sbox[7:0] = 8'h21;
		8'h7c:	aes128_sbox[7:0] = 8'h10;
		8'h7d:	aes128_sbox[7:0] = 8'hff;
		8'h7e:	aes128_sbox[7:0] = 8'hf3;
		8'h7f:	aes128_sbox[7:0] = 8'hd2;
		//----------------------------
		8'h80:	aes128_sbox[7:0] = 8'hcd;
		8'h81:	aes128_sbox[7:0] = 8'h0c;
		8'h82:	aes128_sbox[7:0] = 8'h13;
		8'h83:	aes128_sbox[7:0] = 8'hec;
		8'h84:	aes128_sbox[7:0] = 8'h5f;
		8'h85:	aes128_sbox[7:0] = 8'h97;
		8'h86:	aes128_sbox[7:0] = 8'h44;
		8'h87:	aes128_sbox[7:0] = 8'h17;
		8'h88:	aes128_sbox[7:0] = 8'hc4;
		8'h89:	aes128_sbox[7:0] = 8'ha7;
		8'h8a:	aes128_sbox[7:0] = 8'h7e;
		8'h8b:	aes128_sbox[7:0] = 8'h3d;
		8'h8c:	aes128_sbox[7:0] = 8'h64;
		8'h8d:	aes128_sbox[7:0] = 8'h5d;
		8'h8e:	aes128_sbox[7:0] = 8'h19;
		8'h8f:	aes128_sbox[7:0] = 8'h73;
		//----------------------------
		8'h90:	aes128_sbox[7:0] = 8'h60;
		8'h91:	aes128_sbox[7:0] = 8'h81;
		8'h92:	aes128_sbox[7:0] = 8'h4f;
		8'h93:	aes128_sbox[7:0] = 8'hdc;
		8'h94:	aes128_sbox[7:0] = 8'h22;
		8'h95:	aes128_sbox[7:0] = 8'h2a;
		8'h96:	aes128_sbox[7:0] = 8'h90;
		8'h97:	aes128_sbox[7:0] = 8'h88;
		8'h98:	aes128_sbox[7:0] = 8'h46;
		8'h99:	aes128_sbox[7:0] = 8'hee;
		8'h9a:	aes128_sbox[7:0] = 8'hb8;
		8'h9b:	aes128_sbox[7:0] = 8'h14;
		8'h9c:	aes128_sbox[7:0] = 8'hde;
		8'h9d:	aes128_sbox[7:0] = 8'h5e;
		8'h9e:	aes128_sbox[7:0] = 8'h0b;
		8'h9f:	aes128_sbox[7:0] = 8'hdb;
		//----------------------------
		8'ha0:	aes128_sbox[7:0] = 8'he0;
		8'ha1:	aes128_sbox[7:0] = 8'h32;
		8'ha2:	aes128_sbox[7:0] = 8'h3a;
		8'ha3:	aes128_sbox[7:0] = 8'h0a;
		8'ha4:	aes128_sbox[7:0] = 8'h49;
		8'ha5:	aes128_sbox[7:0] = 8'h06;
		8'ha6:	aes128_sbox[7:0] = 8'h24;
		8'ha7:	aes128_sbox[7:0] = 8'h5c;
		8'ha8:	aes128_sbox[7:0] = 8'hc2;
		8'ha9:	aes128_sbox[7:0] = 8'hd3;
		8'haa:	aes128_sbox[7:0] = 8'hac;
		8'hab:	aes128_sbox[7:0] = 8'h62;
		8'hac:	aes128_sbox[7:0] = 8'h91;
		8'had:	aes128_sbox[7:0] = 8'h95;
		8'hae:	aes128_sbox[7:0] = 8'he4;
		8'haf:	aes128_sbox[7:0] = 8'h79;
		//----------------------------
		8'hb0:	aes128_sbox[7:0] = 8'he7;
		8'hb1:	aes128_sbox[7:0] = 8'hc8;
		8'hb2:	aes128_sbox[7:0] = 8'h37;
		8'hb3:	aes128_sbox[7:0] = 8'h6d;
		8'hb4:	aes128_sbox[7:0] = 8'h8d;
		8'hb5:	aes128_sbox[7:0] = 8'hd5;
		8'hb6:	aes128_sbox[7:0] = 8'h4e;
		8'hb7:	aes128_sbox[7:0] = 8'ha9;
		8'hb8:	aes128_sbox[7:0] = 8'h6c;
		8'hb9:	aes128_sbox[7:0] = 8'h56;
		8'hba:	aes128_sbox[7:0] = 8'hf4;
		8'hbb:	aes128_sbox[7:0] = 8'hea;
		8'hbc:	aes128_sbox[7:0] = 8'h65;
		8'hbd:	aes128_sbox[7:0] = 8'h7a;
		8'hbe:	aes128_sbox[7:0] = 8'hae;
		8'hbf:	aes128_sbox[7:0] = 8'h08;
		//----------------------------
		8'hc0:	aes128_sbox[7:0] = 8'hba;
		8'hc1:	aes128_sbox[7:0] = 8'h78;
		8'hc2:	aes128_sbox[7:0] = 8'h25;
		8'hc3:	aes128_sbox[7:0] = 8'h2e;
		8'hc4:	aes128_sbox[7:0] = 8'h1c;
		8'hc5:	aes128_sbox[7:0] = 8'ha6;
		8'hc6:	aes128_sbox[7:0] = 8'hb4;
		8'hc7:	aes128_sbox[7:0] = 8'hc6;
		8'hc8:	aes128_sbox[7:0] = 8'he8;
		8'hc9:	aes128_sbox[7:0] = 8'hdd;
		8'hca:	aes128_sbox[7:0] = 8'h74;
		8'hcb:	aes128_sbox[7:0] = 8'h1f;
		8'hcc:	aes128_sbox[7:0] = 8'h4b;
		8'hcd:	aes128_sbox[7:0] = 8'hbd;
		8'hce:	aes128_sbox[7:0] = 8'h8b;
		8'hcf:	aes128_sbox[7:0] = 8'h8a;
		//----------------------------
		8'hd0:	aes128_sbox[7:0] = 8'h70;
		8'hd1:	aes128_sbox[7:0] = 8'h3e;
		8'hd2:	aes128_sbox[7:0] = 8'hb5;
		8'hd3:	aes128_sbox[7:0] = 8'h66;
		8'hd4:	aes128_sbox[7:0] = 8'h48;
		8'hd5:	aes128_sbox[7:0] = 8'h03;
		8'hd6:	aes128_sbox[7:0] = 8'hf6;
		8'hd7:	aes128_sbox[7:0] = 8'h0e;
		8'hd8:	aes128_sbox[7:0] = 8'h61;
		8'hd9:	aes128_sbox[7:0] = 8'h35;
		8'hda:	aes128_sbox[7:0] = 8'h57;
		8'hdb:	aes128_sbox[7:0] = 8'hb9;
		8'hdc:	aes128_sbox[7:0] = 8'h86;
		8'hdd:	aes128_sbox[7:0] = 8'hc1;
		8'hde:	aes128_sbox[7:0] = 8'h1d;
		8'hdf:	aes128_sbox[7:0] = 8'h9e;
		//----------------------------
		8'he0:	aes128_sbox[7:0] = 8'he1;
		8'he1:	aes128_sbox[7:0] = 8'hf8;
		8'he2:	aes128_sbox[7:0] = 8'h98;
		8'he3:	aes128_sbox[7:0] = 8'h11;
		8'he4:	aes128_sbox[7:0] = 8'h69;
		8'he5:	aes128_sbox[7:0] = 8'hd9;
		8'he6:	aes128_sbox[7:0] = 8'h8e;
		8'he7:	aes128_sbox[7:0] = 8'h94;
		8'he8:	aes128_sbox[7:0] = 8'h9b;
		8'he9:	aes128_sbox[7:0] = 8'h1e;
		8'hea:	aes128_sbox[7:0] = 8'h87;
		8'heb:	aes128_sbox[7:0] = 8'he9;
		8'hec:	aes128_sbox[7:0] = 8'hce;
		8'hed:	aes128_sbox[7:0] = 8'h55;
		8'hee:	aes128_sbox[7:0] = 8'h28;
		8'hef:	aes128_sbox[7:0] = 8'hdf;
		//----------------------------
		8'hf0:	aes128_sbox[7:0] = 8'h8c;
		8'hf1:	aes128_sbox[7:0] = 8'ha1;
		8'hf2:	aes128_sbox[7:0] = 8'h89;
		8'hf3:	aes128_sbox[7:0] = 8'h0d;
		8'hf4:	aes128_sbox[7:0] = 8'hbf;
		8'hf5:	aes128_sbox[7:0] = 8'he6;
		8'hf6:	aes128_sbox[7:0] = 8'h42;
		8'hf7:	aes128_sbox[7:0] = 8'h68;
		8'hf8:	aes128_sbox[7:0] = 8'h41;
		8'hf9:	aes128_sbox[7:0] = 8'h99;
		8'hfa:	aes128_sbox[7:0] = 8'h2d;
		8'hfb:	aes128_sbox[7:0] = 8'h0f;
		8'hfc:	aes128_sbox[7:0] = 8'hb0;
		8'hfd:	aes128_sbox[7:0] = 8'h54;
		8'hfe:	aes128_sbox[7:0] = 8'hbb;
		8'hff:	aes128_sbox[7:0] = 8'h16;
		default: aes128_sbox[7:0] = 8'hXX;
	endcase
endfunction

// copy the digest to the output
function [63:0] get_digest(input [7:0] digest[0:7]);
	get_digest[7:0] = digest[7];
	get_digest[15:8] = digest[6];
	get_digest[23:16] = digest[5];
	get_digest[31:24] = digest[4];
	get_digest[39:32] = digest[3];
	get_digest[47:40] = digest[2];
	get_digest[55:48] = digest[1];
	get_digest[63:56] = digest[0];
endfunction

// hard left circular shift
function reg [7:0] shift_digest(input [7:0] shifter, input [3:0] j);
	case (j)
		0 : shift_digest = shifter;
		1 : shift_digest = {shifter[6:0], shifter[7]};
		2 : shift_digest = {shifter[5:0], shifter[7:6]};
		3 : shift_digest = {shifter[4:0], shifter[7:5]};
		4 : shift_digest = {shifter[3:0], shifter[7:4]};
		5 : shift_digest = {shifter[2:0], shifter[7:3]};
		6 : shift_digest = {shifter[1:0], shifter[7:2]};
		7 : shift_digest = {shifter[0:0], shifter[7:1]};
	endcase
endfunction

// function to compute new digest value
function array update_digest(input [7:0] digest[0:7]);
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


// LOGIC DESIGN

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
