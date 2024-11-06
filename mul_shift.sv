module mul_shift#(
  parameter MAX_ZC = 384
) (
    input logic [MAX_ZC-1:0] msg_block,
    input logic [8:0] msg_block_size,
    input logic [8:0] shift_factor,
    input logic mul_shift_enable,


    output logic [MAX_ZC-1:0] result
);

  logic [MAX_ZC-1:0] merged_shifted_msg_block;

  logic [MAX_ZC-1:0] right_shifted_msg_block;
  logic [MAX_ZC-1:0] left_shifted_msg_block;

  logic [MAX_ZC-1:0] right_shifted_muxes_input [MAX_ZC-1:0];
  logic [MAX_ZC-1:0] left_shifted_muxes_input  [MAX_ZC-1:0];

  logic [8:0] right_shift;

  assign right_shift =msg_block_size-shift_factor;

  assign result = (mul_shift_enable)? merged_shifted_msg_block : 0;




  always_comb begin
    for (int mux_set =0 ; mux_set<MAX_ZC ; mux_set++ ) begin
      for (int mux_input_no = 0 ; mux_input_no<MAX_ZC ; mux_input_no++ ) begin
        
        if(mux_input_no+mux_set < MAX_ZC)
        begin
          right_shifted_muxes_input[mux_set][mux_input_no] = msg_block[(mux_input_no+mux_set)];
        end
        
        else
        begin
          right_shifted_muxes_input[mux_set][mux_input_no] = 0;
        end
        
      end
    end
  end





always_comb begin
  for (int mux_set =0 ; mux_set<MAX_ZC ; mux_set++ ) begin
      for (int mux_input_no = 0 ; mux_input_no<MAX_ZC ; mux_input_no++ ) begin
        
        if(mux_input_no-mux_set >= 0)
        begin
          left_shifted_muxes_input[mux_set][mux_input_no] = msg_block[(mux_input_no-mux_set)];
        end
        
        else
        begin
          left_shifted_muxes_input[mux_set][mux_input_no] = 0;
        end
        
      end
    end
end




always_comb begin
  for (int index = MAX_ZC-1 ; index>=0 ; index-- ) begin
    if(index < right_shift && index < msg_block_size) //replace comparator with something less dense
    begin
      merged_shifted_msg_block[index] = right_shifted_msg_block[index]; 
    end
    
    else if(index >= right_shift && index < msg_block_size)
    begin
      merged_shifted_msg_block[index] = left_shifted_msg_block[index];
    end
    
    else
    begin
      merged_shifted_msg_block[index] = 0;
    end
  end
end


always_comb begin
  right_shifted_msg_block = right_shifted_muxes_input[shift_factor];
  left_shifted_msg_block  = left_shifted_muxes_input[right_shift];
end

  // genvar right_shift_mux_no;
  // genvar left_shift_mux_no;


  // generate
  //   for (right_shift_mux_no =0;right_shift_mux_no<MAX_ZC ;right_shift_mux_no++ ) begin : RIGHT_SHIFT_MUXES_512
  //     mux_512_to_1 U_right_rotator_mux_512_to_1(.mux_in(right_shifted_muxes_input[right_shift_mux_no]),
  //                                               .select(shift_factor),
  //                                               .mux_out(right_shifted_msg_block[right_shift_mux_no])
  //                                               );
    
  //   end
  // endgenerate

  // generate
  //   for (left_shift_mux_no =0;left_shift_mux_no<MAX_ZC ;left_shift_mux_no++ )    begin : LEFT_SHIFT_MUXES_512
  //     mux_512_to_1 U_left_rotator_mux_512_to_1( .mux_in(left_shifted_muxes_input[left_shift_mux_no]),
  //                                               .select(right_shift),
  //                                               .mux_out(left_shifted_msg_block[left_shift_mux_no])
  //                                               );
  //   end
  // endgenerate


endmodule
