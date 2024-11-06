import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module non_gap_parity_evaluate(
input logic   [MAX_ZC-1:0]  shifted_msg_block  [MUL_SH_BLOCKS_COUNT-1:0],
// input logic                 new_seg_msg_block,
input logic                 gap_eval_done, 
input logic                 pc_first_half_Eval_en,
input logic                 pc_second_half_Eval_en,
// input logic                 lambda_eval_en,
input logic                 cw_vector_valid,
// input BG_Type               BG,
input logic   [4:0]         current_col,
input logic   [4:0]         max_col_count,

input logic reset_n , clk,

output logic first_half_pc_eval_done,
output logic [MAX_ZC-1:0] non_gap_parities  [MUL_SH_BLOCKS_COUNT-1:0]
);


//enum logic[2:0] {IDLE , FIRST_HALF_MSG_MUL , GAP_EVAL_WAIT ,FIRST_HALF_GAP_MUL, SECOND_HALF_PARITIES} current_state,next_state;


// //::----------------------------------------------:://
// //::----->> current_state register <<------:://
// //::----------------------------------------------:://
//   always_ff @(posedge clk or negedge reset_n) begin
//     if(!reset_n)
//     begin
//       current_state <= IDLE;
//     end
  
//     else
//     begin
//       current_state <= next_state;
//     end
  
//   end
// //::----------------------------------------------:://
// //::----------------------------------------------:://





// //::----------------------------------------------:://
// //::----->> next_state <<------:://
// //::----------------------------------------------:://
// always_comb begin
//   next_state = current_state ;
  
//   case (current_state)
//     IDLE: 
//     begin
//       if(new_seg_msg_block)
//       begin
//         next_state = FIRST_HALF_MSG_MUL;
//       end
      
//       else
//       begin
//         next_state = IDLE;
//       end
//     end

//     FIRST_HALF_MSG_MUL:
//     begin
//       if(current_col == max_col_count )
//       begin
//         next_state = GAP_EVAL_WAIT;
//       end
      
//       else
//       begin
//         next_state = FIRST_HALF_MSG_MUL;
//       end
//     end

//     GAP_EVAL_WAIT:
//     begin
//       if(gap_eval_done)
//       begin
        
//       end
//     end
//     default: 
//   endcase
// end
// //::----------------------------------------------:://
// //::----------------------------------------------:://





//::-----------------------------------------------------------:://
//::------>>  evaluating non-gap array<<-----------:://
//::-----------------------------------------------------------:://
always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      first_half_pc_eval_done <= 0;
      
      for (int i =0 ; i<MUL_SH_BLOCKS_COUNT ;i++) begin
        non_gap_parities [i] <= 0;
      end
      
    end
    
    else if( pc_first_half_Eval_en
          //     ( (current_col < max_col_count && current_col >= 0)  && gap_eval_done == 0  && pc_first_half_Eval_en)
          // ||  
          //     ( current_col >= max_col_count && current_col < max_col_count+GAP_COLS_COUNT && max_col_count > 0 && gap_eval_done && pc_first_half_Eval_en) 
          )
    begin
      first_half_pc_eval_done <= 0;
      for (int i = GAP_COLS_COUNT; i< MUL_SH_BLOCKS_COUNT ;i++) begin
        non_gap_parities [i] <= non_gap_parities [i] ^ shifted_msg_block[i];
      end
      
    end
    
    else if(current_col == max_col_count+GAP_COLS_COUNT)
    begin
      
      first_half_pc_eval_done <= 1;
      for (int i = 0; i< MUL_SH_BLOCKS_COUNT ;i++) begin
        non_gap_parities [i] <= 0;
      end
    
    end
    
    if(pc_second_half_Eval_en)
    begin
      for (int i = 0; i< MUL_SH_BLOCKS_COUNT ;i++) begin
        non_gap_parities [i] <= non_gap_parities [i] ^ shifted_msg_block[i];
      end
    end
    
    
end
//::----------------------------------------------------------:://
//::----------------------------------------------------------:://






endmodule