import LDPC_pkg::* ;
import BG1_pkg::* ;
import BG2_pkg::* ;

module LDPC_encoder (
  input logic [MAX_ZC-1:0] msg_block,
  input logic              new_msg_block,
  input logic [13:0]       tb_with_crc_size,
  input logic              tb_valid,
  input logic [4:0]        rate,
  input logic [8:0]        parity_out_address,
  input logic              parity_out_rd_en,




  input clk, reset_n,

  output logic              ready_to_encode,
  output logic              cw_vector_valid,
  output logic              seg_busy,
  output logic [MAX_ZC-1:0] parity_out 
);



//::----->> pre-encoder outputs <<------------------------------------:://
logic   [8:0] bg1_calc_out [BG1_MAX_TRANSFORMS-1:0];
logic   [8:0] bg2_calc_out [BG2_MAX_TRANSFORMS-1:0];
logic   bg1_calc_valid , bg2_calc_valid;
logic   [MAX_ZC-1:0] segmented_msg_block;
logic   new_seg_msg_block;
logic   [8:0] zc;
logic   [4:0] kb;
BG_Type BG;
logic   [2:0] ils_selected;
logic   params_valid;
logic   [8:0] selected_bg [BG1_MAX_TRANSFORMS-1:0];
//::------------------------------------------------------------------:://



//::----->> Controller outputs <<------------------------------------:://
logic [MUL_SH_BLOCKS_COUNT-1:0] A_muxes_selects ;                                                  //!==> This is for A_muxes
logic [MUL_SH_BLOCKS_COUNT-1:0] B_muxes_select_lines ;                                         //!==> This is for B_muxes
logic [1:0]                     C_muxes_select_lines [MUL_SH_BLOCKS_COUNT-1:0];                //!==> This is for C_muxes
logic [1:0]                     stored_msg_selects [MUL_SH_BLOCKS_COUNT-1:0];                      //!==> This is for stored mssgs
logic [8:0]                     shift_factors            [MUL_SH_BLOCKS_COUNT-1:0];                //!==> mul_shift blocks' inputs
logic                           mul_shift_enables        [MUL_SH_BLOCKS_COUNT-1:0];                //!==> mul_shift blocks' inputs
logic                           lambda_eval_en;                                                    //!==> lambda_gap_evaluate input
logic                           pc_first_half_Eval_en; 
logic                           pc_second_half_Eval_en;                                            
logic                           cw_done;
logic [4:0]                     current_col;
logic [4:0]                     max_col_count;
//::------------------------------------------------------------------:://





//::----->> lambda_gap_evaluate output <<-----------------------------:://
logic [MAX_ZC-1:0] gap_array         [GAP_COLS_COUNT-1:0];
logic [MAX_ZC-1:0] non_gap_parities  [MUL_SH_BLOCKS_COUNT-1:0];
logic gap_eval_done;
logic first_half_pc_eval_done;
//::------------------------------------------------------------------:://


//::----->> msg_buffer outputs <<-----------------------------:://
logic[MAX_ZC-1:0] selected_msg_blocks[MUL_SH_BLOCKS_COUNT-1:0];
//::------------------------------------------------------------------:://



//::----->> parity_buffer outputs <<-----------------------------:://
logic [MAX_ZC-1:0] result_parities [MUL_SH_BLOCKS_COUNT];
//::------------------------------------------------------------------:://



//::----->> mul_shift blocks inputs <<------------------------------------:://
  logic        [MAX_ZC-1:0] B_muxes_selected_msg_parity_blocks [MUL_SH_BLOCKS_COUNT-1:0];
//::------------------------------------------------------------------:://



//::----->> mul_shift blocks outputs <<------------------------------------:://
  logic        [MAX_ZC-1:0] shifted_msg_block  [MUL_SH_BLOCKS_COUNT-1:0];
  logic [MAX_ZC-1:0] first_4_shifted_msg_block [GAP_COLS_COUNT-1:0];
//::------------------------------------------------------------------:://


//::----->> A_muxes outputs <<-----------------------------:://
logic [MAX_ZC-1:0] selected_blocks [MUL_SH_BLOCKS_COUNT-1:0];  
//::------------------------------------------------------------------:://


//::----->> C_muxes outputs && B_muxes inputs <<------------:://
logic [MAX_ZC-1:0] selected_gap_parities [MUL_SH_BLOCKS_COUNT-1:0];  
logic [MAX_ZC-1:0] new_msg_parity_blocks [MUL_SH_BLOCKS_COUNT-1:0];
//::------------------------------------------------------------------:://



assign ready_to_encode = bg1_calc_valid || bg2_calc_valid;


always_comb begin
  for (int i = 0; i < MUL_SH_BLOCKS_COUNT ;i++ ) begin
    
    if(i==0)
    begin
      new_msg_parity_blocks [i] = segmented_msg_block;
    end
    
    
    else if(i>0 && i < GAP_COLS_COUNT+1)
    begin
      new_msg_parity_blocks [i] = selected_gap_parities[i-1];
    end
    
  end
end


always_comb begin
  for (int i =0 ; i<GAP_COLS_COUNT ;i++ ) begin
    first_4_shifted_msg_block[i] = shifted_msg_block[i]; 
  end
end





always_comb begin
  if(BG == BG1)
  begin
    
    for (int bg_index = 0; bg_index<BG1_MAX_TRANSFORMS ;bg_index++ ) begin
      selected_bg[bg_index] = bg1_calc_out[bg_index];
    end
  end
  
  else if(BG == BG2)
  begin
    
    for (int bg_index = 0; bg_index<BG1_MAX_TRANSFORMS ;bg_index++) begin
      if(bg_index <BG2_MAX_TRANSFORMS)
      begin
        selected_bg[bg_index] = bg2_calc_out[bg_index];
      end
      else
      begin
        selected_bg[bg_index] = 0;
      end
    end
    
  end
  
  else
  begin
    for (int bg_index = 0; bg_index<BG1_MAX_TRANSFORMS ;bg_index++ ) begin
      selected_bg[bg_index] = 0;
    end
  end
end



always_comb begin 
  for ( int indexx = 0; indexx < GAP_COLS_COUNT ; indexx++ ) begin
    result_parities [indexx] = gap_array[indexx];
  end

  for ( int indexx = GAP_COLS_COUNT; indexx < MUL_SH_BLOCKS_COUNT ; indexx++ ) begin
    result_parities [indexx] = non_gap_parities[indexx-GAP_COLS_COUNT];
  end
end






//::------------------------------------------------------------------:://
//::----->> 23 mul_shift blocks <<------:://
//::------------------------------------------------------------------:://
  genvar mul_sh_block_no;
  
  generate
    for (mul_sh_block_no = 0; mul_sh_block_no<MUL_SH_BLOCKS_COUNT ;mul_sh_block_no++ ) begin
      
      mul_shift U_mul_shift(
        .msg_block(selected_blocks[mul_sh_block_no]),
        .msg_block_size(zc),
        .shift_factor(shift_factors[mul_sh_block_no]),
        .mul_shift_enable(mul_shift_enables[mul_sh_block_no]),
        
        .result(shifted_msg_block[mul_sh_block_no])
        );
        
    end
  endgenerate
//::------------------------------------------------------------------:://
//::------------------------------------------------------------------:://


pre_encoder U_pre_encoder(.*);

stored_msg_select U_stored_msg_select(.segmented_msg_block(segmented_msg_block),
                                      .new_seg_msg_block(new_seg_msg_block),
                                      .current_col(current_col),
                                      .stored_msg_selects(stored_msg_selects),
                                      .BG(BG),
                                      
                                      .clk(clk) , .reset_n(reset_n),
                                      
                                      .selected_msg_blocks(selected_msg_blocks)
                                      );

non_gap_parity_evaluate U_non_gap_parity_evaluate(.*);
lambda_gap_evaluate U_lambda_gap_evaluate(.* , .shifted_msg_block(first_4_shifted_msg_block));
encoder_controller U_encoder_controller(.*);

parity_buffer U_parity_buffer ( .result_parities(result_parities) ,
                                .rd_address(parity_out_address),
                                .wr_en(first_half_pc_eval_done),
                                .rd_en(parity_out_rd_en),
                                
                                .clk(clk) , .reset_n(reset_n),
                                
                                .parity_out(parity_out)
                                );




A_23_muxes U_A_23_muxes ( .stored_msg_blocks(selected_msg_blocks) ,
                          .new_msg_parity_blocks(B_muxes_selected_msg_parity_blocks),
                          .select_lines(A_muxes_selects),
                          
                          .A_muxes_selected_msg_blocks(selected_blocks)
                          );





B_23_muxes U_B_23_muxes(
                        .new_msg(segmented_msg_block),
                        .parity_blocks(selected_gap_parities),
                        .select_lines(B_muxes_select_lines),
                        .B_muxes_selected_msg_parity_blocks(B_muxes_selected_msg_parity_blocks)
                        );




C_23_muxes U_C_23_muxes ( 
                        .parity_blocks(gap_array),
                        .select_lines(C_muxes_select_lines),
                        .C_muxes_selected_parity_blocks(selected_gap_parities)
                        );


endmodule