package cla;
`define param 12							//Insert the parameterized bit number 
`define logvl 4 							//Insert the log value 

(* synthesize *)

module mkcla (Empty);
	rule operation;
	Int#(`param) input1 = 1024;			 			//Insert the input number 1 which consumes param bits
	Int#(`param) input2 = 1001;						//Insert the input number 2 which consumes param bits
	Bit#(`param) i_num1 = pack(input1);		//Convrting from type int to type Bit# with specified bit length param
	Bit#(`param) i_num2 = pack(input2);
	Bit#(1) outresult[`param+1];			//Array of type one bit of size param+1 to hold the final result including carry out
	Bit#(2) rowlevel[`logvl+1][`param+1];	//2D array of log(param) rows and param+1 column to hold initial and intermediate carry status
	rowlevel[0][0] = 'b00;					//Initialising first carry status as kill
	for(Integer i=`param-1;i>=0;i=i-1)		//Loop which initialises first row of 2D array by computing carry status by using given two 											//numbers where as 00,10 and 11 represents kill,propogate and generate respectively 
	begin
		if(i_num1[i] == 1 && i_num2[i] == 1)
			rowlevel[0][i+1] = 'b11;
		else if(i_num1[i] == 0 && i_num2[i] == 0)
			rowlevel[0][i+1] = 'b00;
		else
			rowlevel[0][i+1] = 'b10;
	end	
		Integer k=1;						
		for(Integer i=1;i<=`logvl;i=i+1) 	//To compute the intermediate carry status of log(param) level of rows
		begin
			for(Integer j=`param;j>=0;j=j-1)	//Traverse all param bit of columns for carry status 
			begin
				if(j-k >= 0)					//If the difference of column and row level at each node is positive then compute carry status
				begin
												//If left bit is generate and it's descendent bit could be anything then simly store carry //status as generate
					if(rowlevel[i-1][j] == 'b11 && (rowlevel[i-1][j-k] == 'b11 || rowlevel[i-1][j-k] == 'b00 || rowlevel[i-1][j-k] == 'b10))
					begin
						rowlevel[i][j] = 'b11;
					end
												//If left bit is kill and it's descendent bit could be anything then simly store carry //status as kill
					else if(rowlevel[i-1][j] == 'b00 && (rowlevel[i-1][j-k] == 'b00 || rowlevel[i-1][j-k] == 'b11 || rowlevel[i-1][j-k] == 'b10))
					begin
						rowlevel[i][j] = 'b00;
					end
												//If left bit is either generate,kill ot propogate then according to it's descendent bit //store carry status
					else if(rowlevel[i-1][j] == 'b10 && rowlevel[i-1][j-k] == 'b10)
					begin
						rowlevel[i][j] = 'b10;
					end
					else if(rowlevel[i-1][j] == 'b10 && rowlevel[i-1][j-k] == 'b00)
					begin
						rowlevel[i][j] = 'b00;
					end
					else if(rowlevel[i-1][j] == 'b10 && rowlevel[i-1][j-k] == 'b11)
					begin
						rowlevel[i][j] = 'b11;
					end
				end
				else 									//If the difference of column and row level at each node is negative then copy carry 										//status from it's previous row's descendent column
					rowlevel[i][j] = rowlevel[i-1][j];
			end
			k=k*2;										//Power of 2 to achieve logarithmic row traversal
		end

		for(Integer l=`param-1;l>=0;l=l-1)				//Final result computation by XORing with two input number's bits and final row  												    //log(param) carry status
			outresult[l] = (i_num1[l] ^ i_num2[l]) ^ rowlevel[`logvl][l][0];

		outresult[`param] = rowlevel[`logvl][`param][0];	//Appending output carry

		for(Integer l=`param;l>=0;l=l-1)				//Displays output result from MSB to LSB
			$display("%b",outresult[l]);
		$finish(0);
	endrule
endmodule
endpackage