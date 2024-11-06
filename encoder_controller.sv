import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module encoder_controller (
  input logic bg1_calc_valid , bg2_calc_valid,
  input logic new_seg_msg_block,
  input logic gap_eval_done,
  input logic first_half_pc_eval_done,
  input BG_Type BG,
  input logic   [8:0] selected_bg [BG1_MAX_TRANSFORMS-1:0],
  
  input clk, reset_n,
  
  output logic                           lambda_eval_en,
  output logic                           pc_first_half_Eval_en,
  output logic                           pc_second_half_Eval_en,
  output logic [MUL_SH_BLOCKS_COUNT-1:0] A_muxes_selects,                                      //!==> This is for A_muxes
  output logic [MUL_SH_BLOCKS_COUNT-1:0] B_muxes_select_lines ,                                //!==> This is for B_muxes
  output logic [1:0]                     C_muxes_select_lines     [MUL_SH_BLOCKS_COUNT-1:0],   //!==> This is for C_muxes
  output logic [8:0]                     shift_factors            [MUL_SH_BLOCKS_COUNT-1:0],   //!==> mul_shift blocks' inputs
  output logic [1:0]                     stored_msg_selects       [MUL_SH_BLOCKS_COUNT-1:0],   //!==> This is for stored mssgs
  output logic                           mul_shift_enables        [MUL_SH_BLOCKS_COUNT-1:0],   //!==> mul_shift blocks' inputs
  output logic [4:0]                     current_col,
  output logic [4:0]                     max_col_count,
  output logic                           cw_vector_valid,
  output logic                           cw_done
);

enum logic[2:0] {IDLE, NEW_SEG_MSG_MUL ,GAP_EVAL ,GAP_MUL , SECOND_HALF_PCS_EVAL} current_state,next_state;

logic bg1_calc_valid_stored, bg2_calc_valid_stored,new_seg_msg_block_stored;

logic [8:0] comb_row_stopped_col_indecies_in_BG [BG1_ROW_COUNT/2-1:0];
logic [8:0] row_stopped_col_indecies_in_BG      [BG1_ROW_COUNT/2-1:0];


logic [4:0] row_stopped_col [MUL_SH_BLOCKS_COUNT-1:0];
logic [4:0] comb_row_stopped_col [MUL_SH_BLOCKS_COUNT-1:0];

bit[5:0] comb_positive_elements_col_indecies [BG1_MAX_TRANSFORMS-1:0];
bit[5:0] positive_elements_col_indecies      [BG1_MAX_TRANSFORMS-1:0];

//::-------------------------------------------------------------------------------:://
//::----->> comb_row_stopped_col_indecies_in_BG determination <<---:://
//::------------------------------------------------------------------------------:://
  always_comb begin 
    
    
    for (int j = 0; j<BG1_MAX_TRANSFORMS ; j++ ) begin
      comb_positive_elements_col_indecies [j] = 0;
    end
    for (int i = 0;i< BG1_ROW_COUNT/2;i++ ) begin
      comb_row_stopped_col_indecies_in_BG[i] = 0;
    end
    
    
    
    
    if(BG == BG1 && new_seg_msg_block)
    begin
      for (int i = 0;i< BG1_ROW_COUNT/2;i++ ) begin
        comb_row_stopped_col_indecies_in_BG[i] = BG1_POSITIVE_ELEMENTS_INDECIES_STARTS_PER_ROW[BG1_ROW_COUNT-1-i];
      end
      
      for (int j = 0; j<BG1_MAX_TRANSFORMS ; j++ ) begin
        comb_positive_elements_col_indecies [j] = BG1_NON_MINUS_ONE_ELEMENTS[j];
      end
      
    end
    
    else if(BG == BG2 && new_seg_msg_block)
    begin
      for (int i = 0;i< BG1_ROW_COUNT/2;i++ ) begin
          comb_row_stopped_col_indecies_in_BG[i] = BG2_POSITIVE_ELEMENTS_INDECIES_STARTS_PER_ROW[BG2_ROW_COUNT-1-i];
      end
      
      for (int j = 0; j<BG1_MAX_TRANSFORMS ; j++ ) begin
        if(j<BG2_MAX_TRANSFORMS)
        begin
          comb_positive_elements_col_indecies [j] = BG2_NON_MINUS_ONE_ELEMENTS[j];
        end
        
        else
        begin
          comb_positive_elements_col_indecies [j] = 0;
        end
      end
      
    end
    
    else if(BG == BG1 && ((current_state == GAP_MUL && current_col == BG1_MSG_COL_COUNT + GAP_COLS_COUNT) || current_state == SECOND_HALF_PCS_EVAL))
    begin
      for (int i = BG1_ROW_COUNT/2;i< BG1_ROW_COUNT;i++ ) begin
        comb_row_stopped_col_indecies_in_BG[i-BG1_ROW_COUNT/2] = BG1_POSITIVE_ELEMENTS_INDECIES_STARTS_PER_ROW[BG1_ROW_COUNT-1-i];
      end
    end
    
    
    else if(BG == BG2 && ( (current_state == GAP_MUL && current_col == BG2_MSG_COL_COUNT + GAP_COLS_COUNT) || current_state == SECOND_HALF_PCS_EVAL ))
    begin
      for (int i = BG1_ROW_COUNT/2;i< BG1_ROW_COUNT;i++ ) begin
        if(i <BG2_ROW_COUNT)
          comb_row_stopped_col_indecies_in_BG[i-BG1_ROW_COUNT/2] = BG2_POSITIVE_ELEMENTS_INDECIES_STARTS_PER_ROW[BG2_ROW_COUNT-1-i];
        else
          comb_row_stopped_col_indecies_in_BG[i-BG1_ROW_COUNT/2] = 0;
      end
    end
    
    
    else
    begin
      
      for (int j = 0; j<BG1_MAX_TRANSFORMS ; j++ ) begin
        comb_positive_elements_col_indecies [j] = 0;
      end
      
      for (int i = 0;i< BG1_ROW_COUNT/2;i++ ) begin
        comb_row_stopped_col_indecies_in_BG[i] = 0;
      end
      
    end
  end
//::------------------------------------------------------------------------------:://
//::------------------------------------------------------------------------------:://




//::----------------------------------------------:://
//::----->> current_state register <<------:://
//::----------------------------------------------:://
  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      current_state <= IDLE;
    end
  
    else
    begin
      current_state <= next_state;
    end
  
  end
//::----------------------------------------------:://
//::----------------------------------------------:://




//::----------------------------------------------:://
//::----->> current col and max col count register <<------:://
//::----------------------------------------------:://
  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      current_col <= 0;
      max_col_count <= 0;
    end
  
    else
    begin
      
      case (current_state)
        IDLE:
        begin
          if(new_seg_msg_block)
          begin
            current_col <= current_col+1;  
            
            if(BG == BG1)
              max_col_count <= BG1_MSG_COL_COUNT;
            else if(BG == BG2)
              max_col_count <= BG2_MSG_COL_COUNT;
          end
        end
        
        NEW_SEG_MSG_MUL:
        begin
          if(new_seg_msg_block && current_col<max_col_count)
          begin
            current_col <= current_col+1;  
          end
        end
        
        GAP_MUL:
        begin
          if(gap_eval_done && current_col<max_col_count+GAP_COLS_COUNT)
          begin
            current_col <= current_col+1;  
          end
          
          else if (current_col == max_col_count+GAP_COLS_COUNT )
          begin
            current_col <= 0;
          end
        end

        SECOND_HALF_PCS_EVAL:
        begin
          current_col <= (current_col < MAX_POSITIVE_MSG_COL_COUNT_2ND_HALF_BG1)? current_col+1:0;
        end
        
      endcase
      
    end
  
  end
//::----------------------------------------------:://
//::----------------------------------------------:://





//::-----------------------------------------------------------------:://
//::----->> check if a new message arrived for encoding <<------:://
//::-----------------------------------------------------------------:://
always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      bg1_calc_valid_stored <= 0;
      bg1_calc_valid_stored <= 0;
      new_seg_msg_block_stored          <= 0;
    end
    
    else
    begin
      if(current_state ==IDLE && (bg1_calc_valid_stored || bg2_calc_valid_stored) && new_seg_msg_block_stored)
      begin
        bg1_calc_valid_stored  <= 0;  
        bg2_calc_valid_stored  <= 0;
        new_seg_msg_block_stored    <= 0;
      end
      
      else
      begin
        if(!bg1_calc_valid_stored && bg1_calc_valid)
          bg1_calc_valid_stored <= bg1_calc_valid;
        
        if(!bg2_calc_valid_stored && bg2_calc_valid)
          bg2_calc_valid_stored <= bg2_calc_valid;
        
        if(!new_seg_msg_block_stored && new_seg_msg_block)
          new_seg_msg_block_stored <= new_seg_msg_block;
      end
      
    end
end
//::---------------------------------------------------------------:://
//::---------------------------------------------------------------:://





//::------------------------------------------------------------------------------------------------:://
//::----->> row stop and positive_elements_col_indecies determination evaluation loops_NOT_okay<<------:://
//::------------------------------------------------------------------------------------------------:://
always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      for (int i = 0;i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
        row_stopped_col[i] <= 0;
      end
      
      for (int j = 0; j<BG1_MAX_TRANSFORMS ; j++ ) begin
        positive_elements_col_indecies [j] <= 0;
      end
      
      for (int i = 0;i< BG1_ROW_COUNT/2;i++ ) begin
        row_stopped_col_indecies_in_BG[i] <= 0;
      end
    end
    
    else
    begin
      case (current_state)
        IDLE:
        begin
          if(new_seg_msg_block)
          begin
            
            for (int i = 0;i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
              if(comb_positive_elements_col_indecies[comb_row_stopped_col_indecies_in_BG[i]] == 0)
              begin
                row_stopped_col[i] <= comb_positive_elements_col_indecies[comb_row_stopped_col_indecies_in_BG[i]+1];
                row_stopped_col_indecies_in_BG[i] <= comb_row_stopped_col_indecies_in_BG[i] +1;
              end
              
              else if(comb_positive_elements_col_indecies[comb_row_stopped_col_indecies_in_BG[i]] > 0)
              begin
                row_stopped_col[i] <= comb_positive_elements_col_indecies[comb_row_stopped_col_indecies_in_BG[i]];
                row_stopped_col_indecies_in_BG[i] <= comb_row_stopped_col_indecies_in_BG[i];
              end
              
              
            end
            
            for (int j = 0; j<BG1_MAX_TRANSFORMS ; j++ ) begin
              positive_elements_col_indecies [j] <= comb_positive_elements_col_indecies [j];
            end
            
          end
          
        end
        
        NEW_SEG_MSG_MUL :
        begin
          if(new_seg_msg_block)
          begin
            for (int i = 0;i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
              
              if(current_col == row_stopped_col[i])
              begin
                row_stopped_col[i] <= positive_elements_col_indecies[row_stopped_col_indecies_in_BG[i]+1];
                row_stopped_col_indecies_in_BG[i] <= row_stopped_col_indecies_in_BG[i]+1;
              end
                
            end
          end
        end

        GAP_MUL:
        begin
          if(gap_eval_done)
          begin
            for (int i = 0;i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
              
              if(current_col == row_stopped_col[i])
              begin
                row_stopped_col[i] <= positive_elements_col_indecies[row_stopped_col_indecies_in_BG[i]+1];
                row_stopped_col_indecies_in_BG[i] <= row_stopped_col_indecies_in_BG[i]+1;
              end
                
            end
          end
        end

        // SECOND_HALF_PCS_EVAL:
        // begin
          
        // end

        
      endcase
    end
end
//::------------------------------------------------------------------------------------------------:://
//::------------------------------------------------------------------------------------------------:://






//::-------------------------------------------------------------------------------:://
//::----->> Control Signals Calculation <<------:://
//::-------------------------------------------------------------------------------:://
always_comb begin
  
  for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
    B_muxes_select_lines [i]  = 0;
    A_muxes_selects [i]  = 1;
    stored_msg_selects [i] = 0;
    C_muxes_select_lines [i]  = 0;
    shift_factors            [i]  = 0;
    mul_shift_enables        [i]  = 0;
  end
  
  lambda_eval_en             = 0; 
  pc_first_half_Eval_en      = 0;
  pc_second_half_Eval_en     = 0;
  cw_vector_valid            = 0;
  cw_done                    = 0;
  
  
  case (current_state) //try the inside for the synthesis tool

//::-----------------------------------------------:://
//::----->> IDLE state <<------:://
//::-----------------------------------------------:://
    IDLE:
    begin
      if(new_seg_msg_block)
      begin
        lambda_eval_en         = 1;
        pc_first_half_Eval_en  = 1; 
        pc_second_half_Eval_en = 0;
        cw_vector_valid        = 0; 
        cw_done                = 0;
        
        for (int i = 0;i< MUL_SH_BLOCKS_COUNT;i++ ) begin
          if(current_col == comb_positive_elements_col_indecies[comb_row_stopped_col_indecies_in_BG[i]])
          begin
            shift_factors[i]      = selected_bg[comb_row_stopped_col_indecies_in_BG[i]];
            mul_shift_enables[i]  = 1;
          end
          
          else
          begin
            shift_factors[i]     = 0;
            mul_shift_enables[i]  = 0;
          end
        end
        
        for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
          B_muxes_select_lines [i]  = 0; //!:: Allow newly segmented messages to pass
          A_muxes_selects [i]  = 1; 
          stored_msg_selects [i] = 0;
          C_muxes_select_lines [i]  = 0;
        end
        
      end
      
      else
      begin
        
        for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
          B_muxes_select_lines [i]  = 0;
          A_muxes_selects [i]  = 1;
          stored_msg_selects [i] = 0;
          C_muxes_select_lines [i]  = 0;
          shift_factors            [i]  = 0;
          mul_shift_enables        [i]  = 0;
        end
        
        lambda_eval_en             = 0; 
        pc_first_half_Eval_en      = 0;
        pc_second_half_Eval_en     = 0;
        cw_vector_valid            = 0;
        cw_done                    = 0;
        
      end
    end 



//::-----------------------------------------------:://
//::----->> NEW_SEG_MSG_MUL state <<------:://
//::-----------------------------------------------:://
    NEW_SEG_MSG_MUL:
    begin
      if(new_seg_msg_block && current_col < max_col_count)
      begin
        lambda_eval_en  = 1;
        pc_first_half_Eval_en      = 1; 
        pc_second_half_Eval_en     = 0;
        cw_vector_valid = 0; 
        cw_done         = 0;
        
        for (int i = 0;i< MUL_SH_BLOCKS_COUNT;i++ ) begin
          if(current_col == row_stopped_col[i])
          begin
            shift_factors[i]     = selected_bg[row_stopped_col_indecies_in_BG[i]];
            mul_shift_enables[i] = 1;
          end
          
          else
          begin
            shift_factors[i]     = 0;
            mul_shift_enables[i] = 0;
          end
        end
        
        for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
          B_muxes_select_lines [i]  = 0; //!:: Allow newly segmented messages to pass
          A_muxes_selects [i]  = 1; 
          stored_msg_selects [i] = 0;
          C_muxes_select_lines [i]  = 0;
        end
        
      end
      
      else
      begin
        
        for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
          B_muxes_select_lines [i]      = 0;
          A_muxes_selects [i]           = 1;
          stored_msg_selects [i]        = 0;
          C_muxes_select_lines [i]      = 0;
          shift_factors [i]             = 0;
          mul_shift_enables [i]         = 0;
        end
        
        pc_first_half_Eval_en      = 0;
        pc_second_half_Eval_en     = 0;
        lambda_eval_en             = 0;
        cw_vector_valid            = 0;
        cw_done                    = 0;
        
      end
    end



//::-----------------------------------------------:://
//::----->> GAP_EVAL state <<------:://
//::-----------------------------------------------:://
    GAP_EVAL: //!:: In this state we are waiting for the gap evaluation to be done 
    begin
      for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
        B_muxes_select_lines [i]      = 0;
        A_muxes_selects [i]           = 1;
        stored_msg_selects [i]        = 0;
        C_muxes_select_lines [i]      = 0;
        shift_factors [i]             = 0;
        mul_shift_enables [i]         = 0;
      end
      
      pc_first_half_Eval_en      = 0;
      pc_second_half_Eval_en     = 0;
      lambda_eval_en             = 0;
      cw_vector_valid            = 0;
      cw_done                    = 0;
    end




//::-----------------------------------------------:://
//::----->> GAP_MUL state <<------:://
//::-----------------------------------------------:://
    GAP_MUL:
    begin
      
      for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
        B_muxes_select_lines [i]  = 1;
        A_muxes_selects [i]       = 1;
        stored_msg_selects [i]    = 0;
        C_muxes_select_lines [i]  = row_stopped_col[i] - max_col_count;
      end
      
      
      pc_first_half_Eval_en      = 1;
      pc_second_half_Eval_en     = 0;
      lambda_eval_en             = 0;
      cw_vector_valid            = 0;
      cw_done                    = 0;
      
      if(current_col < max_col_count+GAP_COLS_COUNT)
      begin
        
        for (int i = 0;i< MUL_SH_BLOCKS_COUNT;i++ ) begin
          if(current_col == row_stopped_col[i])
          begin
            shift_factors[i]      = selected_bg[row_stopped_col_indecies_in_BG[i]];
            mul_shift_enables[i]  = 1;
          end
          
          else
          begin
            shift_factors[i]     = 0;
            mul_shift_enables[i] = 0;
          end
        end
        
      end
      
      else
      begin
        for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
          B_muxes_select_lines [i]  = 0;
          A_muxes_selects [i]       = 1;
          stored_msg_selects [i]    = 0;
          shift_factors [i]         = 0;
          mul_shift_enables [i]     = 0;
          C_muxes_select_lines [i]  = 0;
        end
        
        pc_first_half_Eval_en      = 0;
        pc_second_half_Eval_en     = 0;
        lambda_eval_en             = 0;
        cw_vector_valid            = 1;
        cw_done                    = 0;
      end
      
      
    end
    
    SECOND_HALF_PCS_EVAL:
    begin
      
      pc_first_half_Eval_en      = 0;
      pc_second_half_Eval_en     = 1;
      lambda_eval_en             = 0;
      cw_vector_valid            = 0;
      cw_done                    = 0;
      
      
      for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
        B_muxes_select_lines [i]  = 1;
        C_muxes_select_lines [i]  = 0;
        shift_factors [i]         = selected_bg[comb_row_stopped_col_indecies_in_BG[i] + current_col];
      end
      
      
      
      if(current_col == MAX_POSITIVE_MSG_COL_COUNT_2ND_HALF_BG1)
      begin
        pc_second_half_Eval_en = 0;
        cw_done = 1;
        cw_vector_valid = 1;
      end
      
      else
      begin
        pc_second_half_Eval_en = 1;
        cw_done = 0;
        cw_vector_valid = 0;
      end
      
      
      
      if (BG == BG1) begin
        for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
          if(BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] < BG1_MSG_COL_COUNT)
          begin
            A_muxes_selects [i]       = 0;
            stored_msg_selects [i]    = current_col;
            mul_shift_enables [i]     = 1;
            C_muxes_select_lines [i]  = 0;
          end
          
          else if(BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] >= BG1_MSG_COL_COUNT && BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] < BG1_MSG_COL_COUNT+GAP_COLS_COUNT)
          begin
            A_muxes_selects [i]       = 1;
            mul_shift_enables [i]     = 1;
            stored_msg_selects [i]    = 0;
            C_muxes_select_lines [i]  = BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] - BG1_MSG_COL_COUNT;
          end
          
          else
          begin
            A_muxes_selects [i]     = 1;
            mul_shift_enables [i]   = 0;
            stored_msg_selects [i]  = 0;
            shift_factors [i]       = 0;
          end
        end
      end
      
      else begin
        for (int i = 0; i<MUL_SH_BLOCKS_COUNT ;i++ ) begin
          if(BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] < BG2_MSG_COL_COUNT)
          begin
            A_muxes_selects [i]       = 0;
            stored_msg_selects [i]    = current_col;
            mul_shift_enables [i]     = 1;
            C_muxes_select_lines [i]  = 0;
          end
          
          else if(BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] >= BG2_MSG_COL_COUNT && BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] < BG2_MSG_COL_COUNT+GAP_COLS_COUNT)
          begin
            A_muxes_selects [i]       = 1;
            mul_shift_enables [i]     = 1;
            stored_msg_selects [i]    = 0;
            C_muxes_select_lines [i]  = BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[i][current_col] - BG2_MSG_COL_COUNT;
          end
          
          else
          begin
            A_muxes_selects [i]     = 1;
            mul_shift_enables [i]   = 0;
            stored_msg_selects [i]  = 0;
            shift_factors [i]       = 0;
          end
        end
      end
      
    end
    
  endcase
end
//::----------------------------------------------:://
//::----------------------------------------------:://



//::----------------------------------------------:://
//::----->> next_state calculation <<------:://
//::----------------------------------------------:://
always_comb begin
  next_state = current_state;
  
  case (current_state)
    IDLE:
    begin
      if(new_seg_msg_block)
      begin
        next_state = NEW_SEG_MSG_MUL;
      end
      
      else
      begin
        next_state = IDLE;
      end
    end 
    
    NEW_SEG_MSG_MUL:
    begin
      if(current_col == max_col_count)
      begin
        next_state = GAP_EVAL;
      end
      
      else
      begin
        next_state = NEW_SEG_MSG_MUL;
      end
    end
    
    GAP_EVAL:
    begin
      if(gap_eval_done)
      begin
        next_state = GAP_MUL;
      end
      
      else
      begin
        next_state = GAP_EVAL;
      end
    end
    
    GAP_MUL:
    if(current_col == max_col_count + GAP_COLS_COUNT)
    begin
      next_state = SECOND_HALF_PCS_EVAL;
    end
    
    else
    begin
      next_state = GAP_MUL;
    end
    
    SECOND_HALF_PCS_EVAL:
    begin
      if(current_col == MAX_POSITIVE_MSG_COL_COUNT_2ND_HALF_BG1)
      begin
        next_state = IDLE;
      end
      
      else
      begin
        next_state = SECOND_HALF_PCS_EVAL;
      end
    end
    
    
  endcase
  
end

endmodule