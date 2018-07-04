// Jump_Ctrl

module Jump_Ctrl( Zero,
                  JumpOP,
			Branch,
			Jump,
			Jr
				  );

    input Zero;
	input Branch;
	input Jump;
	input Jr;
	output [1:0] JumpOP;
	// write your code in here
	assign JumpOp = (Branch&&Zero)?1:(Jump==1)?2:(Jr==1)?3:0;
	
endmodule





