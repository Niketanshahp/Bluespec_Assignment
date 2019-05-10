package wwlltt;
`define param 4		// # of bits length of the input multiplier and multiplicant
`define size 8		// # of bits length of the multiplied result (2 x inputs bits length)
`define N 8 		// # of bits length of the final SUM and CARRY to be passed to the CLA
`define Log_N 3 	// # of recursive multiplications to be carried out by the CLA
`define N1 9
(* synthesize *)

module mkwwlltt (Empty);

	Reg#(Bit#(`param)) i_num1 <- mkReg(11);		//Input value - Multiplier
	Reg#(Bit#(`param)) i_num2 <- mkReg(13);		//Input value - Multiplicant

	function Bit#(`size) parpro_sum(Bit#(`size) pp1, Bit#(`size) pp2, Bit#(`size) pp3);	//Function to calculate SUM of the partial products

		Bit#(`size) ppsum;
		for(Integer i=0;i<`size;i=i+1)
			ppsum[i]=pp1[i]^pp2[i]^pp3[i];

		return ppsum;
	endfunction

	function Bit#(`size) parpro_carry(Bit#(`size) pp1, Bit#(`size) pp2, Bit#(`size) pp3); //Function to calculate CARRY of the partial products
 
		Bit#(`size) ppcarry;
		for(Integer i=0;i<`size;i=i+1)
			ppcarry[i]=(pp1[i]&pp2[i]) | (pp1[i]&pp3[i]) | (pp2[i]&pp3[i]); 
	
		return ppcarry;
	endfunction

	rule wallacetree if(i_num2 != 0);
		Bit#(`param) temp ='b0000;
		Bit#(`param) ip1 = i_num1;
		Bit#(`param) ip2 = i_num2;
		Bit#(`size) result[`param];
		for(Integer j=0;j<`param;j=j+1)
		begin
			if(ip2[0] == 0)
			begin
				result[j] = zeroExtend(temp);
				result[j] = result[j] << j;
			end
			else
			begin
				result[j] = zeroExtend(ip1);
				result[j] = result[j] << j;
			end
		ip2 = ip2 >> 1;
		end
        	i_num2 <= ip2;

		Integer qout=`param/3;
		Integer rem=(`param)%3;
		Integer k=0;

		Integer flag=0;
		Bit#(`size) s;	
		Bit#(`size) c;
	
		while(flag!=1)
		begin
			for(Integer i=0;i<(3*qout);i=i+3)
			begin
		
				s=parpro_sum(result[i],result[i+1],result[i+2]);
				c=parpro_carry(result[i],result[i+1],result[i+2]);
				result[k]=s;
			
				k=k+1;
				result[k]=c<<1;
				k=k+1;
				 
			end

			if(rem!=0)
			begin
				for(Integer i=0;i<rem;i=i+1)
				begin
				
					result[k]=result[qout*3+i];
					k=k+1;
				end
			end
			if(k==2)
			begin
				flag=1;
			end
			else
			begin
				qout=k/3;
				rem=k%3;
				flag=0;
				k=0;
			end
		
		end 

	Bit#(`N) cla_num1; 
	Bit#(`N) cla_num2; 

	
	cla_num1 = result[0]; 
	cla_num2 = result[1]; 

	Bit#(`N1) result_cla; 
	Bit#(2) level[`Log_N+1][`N+1];	
		level[0][0] = 'b00;  

		for(Integer i=`N-1;i>=0;i=i-1) 
		begin
			if(cla_num1[i] == 1 && cla_num2[i] == 1) 
				level[0][i+1] = 'b11;
			else if(cla_num1[i] == 0 && cla_num2[i] == 0) 
				level[0][i+1] = 'b00;
			else
				level[0][i+1] = 'b10; 
		end


		Integer k1=1; 
		
		for(Integer i=1;i<=`Log_N;i=i+1)   
            begin
			for(Integer j=`N;j>=0;j=j-1)  
			begin
				if(j-k1 >= 0)  
				begin
					
					if(level[i-1][j] == 'b11 && (level[i-1][j-k1] == 'b11 || level[i-1][j-k1] == 'b00 || level[i-1][j-k1] == 'b10))
					begin
						level[i][j] = 'b11;
					end
					else if(level[i-1][j] == 'b00 && (level[i-1][j-k1] == 'b00 || level[i-1][j-k1] == 'b11 || level[i-1][j-k1] == 'b10))
					begin
						level[i][j] = 'b00;
					end
					else if(level[i-1][j] == 'b10 && level[i-1][j-k1] == 'b10) 
					begin
						level[i][j] = 'b10;
					end
					else if(level[i-1][j] == 'b10 && level[i-1][j-k1] == 'b00) 
					begin
						level[i][j] = 'b00;
					end
					else if(level[i-1][j] == 'b10 && level[i-1][j-k1] == 'b11) 
					begin
						level[i][j] = 'b11;
					end
				end
				else 
				begin
					level[i][j] = level[i-1][j]; 
				end
				
			end
			k1=k1*2; 
		end

		for(Integer l=`N-1;l>=0;l=l-1)
		begin
			result_cla[l] = (cla_num1[l] ^ cla_num2[l]) ^ level[`Log_N][l][0]; 
                                                                                   
		end

		result_cla[`N] = level[`Log_N][`N][0]; 
		$display("Result : %b",result_cla); 
		$finish(0);  
	
	endrule 

endmodule 


endpackage 
