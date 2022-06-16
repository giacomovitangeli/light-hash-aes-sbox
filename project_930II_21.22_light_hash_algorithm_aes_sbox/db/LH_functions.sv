// Init digest
function reg [7:0] digest_tmp [0:7] restore_digest;
    restore_digest[0] = 8'h34;
	restore_digest[1] = 8'h55;
	restore_digest[2] = 8'h0F;
	restore_digest[3] = 8'h14;
	restore_digest[4] = 8'hDA;
	restore_digest[5] = 8'hC0;
	restore_digest[6] = 8'h2B;
	restore_digest[7] = 8'hEE;
endfunction