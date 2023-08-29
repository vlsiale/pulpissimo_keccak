module keccak_cu 
    #(
      localparam D_WIDTH=1600,
      localparam D_KECCAK_WIDTH=64
    )(
     input logic 		       clk_i,
     input logic 		       rst_ni,
     input logic 		       start_i,
     input logic 		       ready_keccak_i, 
     input logic [D_WIDTH-1:0] 	       din_i,
     input logic [D_KECCAK_WIDTH-1:0]  dout_keccak_i,
     input logic 		       dout_valid_keccak_i,
     output logic 		       start_keccak_o,
     output logic 		       last_block_keccak_o, 
     output logic [D_WIDTH-1:0]	       dout_o,
     output logic [D_KECCAK_WIDTH-1:0] din_keccak_o,
     output logic 		       din_valid_keccak_o,
     output logic 		       status		       
   );


   parameter S_0 = 0, S_1 = 1,
             S_2 = 2, S_3 = 3;

   //reg[4:0]  			       counter;
   shortint unsigned		       counter;
 			       
   
   reg [1:0] 			       State, State_next;

   // State reg
   always_ff @(posedge clk_i) begin
      if ( !rst_ni) begin
	 State <= S_0;
	 counter <= 0;
      end else begin 
	if ( State != State_next || State == S_0) begin
	   //counter <= 0;
	   if ( State_next == S_1) begin
	      din_keccak_o <= din_i[D_KECCAK_WIDTH*counter +: D_KECCAK_WIDTH];
	      counter <= counter+1;
	   //end else if (State_next == S_3) begin
	   //   dout_o[0 +: D_KECCAK_WIDTH] <= dout_keccak_i;
	   //   counter <= 1;
	   end else begin 
	      counter <= 0;
	   end
	end else begin
	   counter <= counter + 1;   //NOTE : concurrent process, counter seen by bit slicing is not the updated one 
	   if ( State == S_1) begin
	      if ( counter != 25) begin
		 din_keccak_o <= din_i[D_KECCAK_WIDTH*counter +: D_KECCAK_WIDTH];
	      end else begin
		 din_keccak_o <= 0;
	      end
	   end else if (State == S_3 ) begin
	      dout_o[D_KECCAK_WIDTH*counter +: D_KECCAK_WIDTH] <= dout_keccak_i;
	   end else begin
	      din_keccak_o <= 0;
	      dout_o <= 0;
	   end   
	end
	State <= State_next;
      end
   end 

   // Comb logic      
   always_comb begin
      case (State)
	S_0 : begin
	   din_valid_keccak_o <= 0;
	   last_block_keccak_o <= 0;
	   if (start_i && ready_keccak_i) begin
	      start_keccak_o <= 1;
	      State_next <= S_1;
	   end else begin
	      start_keccak_o <= 0;
	      State_next <= S_0;	      
	   end
	end
	S_1 : begin
	   start_keccak_o <= 0;
	   din_valid_keccak_o <= 1;
	   last_block_keccak_o <= 0;
	   status <= 0;
	   if (counter == 26) begin
	      //din_keccak_o <= 0;
	      State_next <= S_2;
	   end else begin
	      State_next <= S_1;
	   end
        end
	S_2 : begin
	   start_keccak_o <= 0;
	   din_valid_keccak_o <= 0;
	   //din_keccak_o <= 0;
	   status <= 0;
	   if (counter == 25) begin
	      last_block_keccak_o <= 1;
	   end else begin
	      last_block_keccak_o <= 0;
	   end    
	   if ( counter == 26) begin
	      State_next <= S_3;
	   end else begin
	      State_next <= S_2; 
	   end
        end 
	S_3 : begin
	   start_keccak_o <= 0;
	   din_valid_keccak_o <= 0;
	   //din_keccak_o <= 0;
	   last_block_keccak_o <= 0;
	   if (counter == 25) begin
	      State_next <= S_0;
	       status <= 1;
	   end else begin
	      State_next <= S_3;
	   end
	end
	default : begin
	   start_keccak_o <= 0;
	   //dout_o <='{default: '0};
	   din_valid_keccak_o <= 0;
	   //din_keccak_o <= 0;
	   last_block_keccak_o <= 0;
	   State_next <= S_0;
	   status <= 0;
	   
	end
   endcase
   end // always_comb @

   endmodule : keccak_cu

	    
      
	 
	 
 
