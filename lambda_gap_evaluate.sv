import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module lambda_gap_evaluate(
  input logic [MAX_ZC-1:0] shifted_msg_block  [GAP_COLS_COUNT-1:0],
  input logic [8:0]        zc,
  input logic              lambda_eval_en,
  input BG_Type            BG,
  input logic [2:0]        ils_selected,

  input logic clk,reset_n,

  output logic [MAX_ZC-1:0] gap_array    [GAP_COLS_COUNT-1:0],
  output logic gap_eval_done
);


logic [MAX_ZC-1:0] lambda_array [GAP_COLS_COUNT-1:0];

logic [4:0] lambda_counter;


logic signed [9:0] shift_factor;
logic mul_shift_enable;
logic [MAX_ZC-1:0] shifted_vector;
logic [MAX_ZC-1:0] mul_shift_input_vector;

logic [4:0] max_col_count;

logic [MAX_ZC-1:0] lambda_sum;



assign lambda_sum= lambda_array[0] ^ lambda_array[1] ^ lambda_array[2] ^ lambda_array[3];
// assign gap_eval_on = (lambda_counter == GAP_COLS_COUNT && gap_eval_counter == 0) ? 1:0;

//::-------------------------------------------------------:://
//::--------->> max. column counter determination <<-------:://
//::-------------------------------------------------------:://
  always_comb begin 
    if(BG == BG1)
    begin
      max_col_count = BG1_MSG_COL_COUNT;
    end
    
    else if(BG == BG2)
    begin
      max_col_count = BG2_MSG_COL_COUNT;
    end
    
    else
    begin
      max_col_count = 0;
    end
  end
//::-------------------------------------------------------:://
//::-------------------------------------------------------:://



//::-----------------------------------------------------------:://
//::------>>  evaluating lambdas & gap array<<-----------:://
//::-----------------------------------------------------------:://
always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      lambda_counter    <= 0;
      gap_eval_done     <= 0;
      
      for (int i =0 ; i<GAP_COLS_COUNT ;i++) begin
        lambda_array [i] <= 0;
        gap_array    [i] <= 0;
      end
      
    end
    
    else if( (lambda_counter < max_col_count && lambda_counter >= 0 && max_col_count > 0) && gap_eval_done == 0  && lambda_eval_en)
    begin
      gap_eval_done     <= 0;
      lambda_counter    <= lambda_counter+1;
      
      for (int i =0 ; i<GAP_COLS_COUNT ;i++) begin
        lambda_array [i] <= lambda_array [i] ^ shifted_msg_block[i];
      end
      
    end
//::----------------------------------------------------------:://
//::----------------------------------------------------------:://


//::-----------------------------------------------------------:://
//::------>>  evaluating Pa1 <<-----------------------------:://
//::-----------------------------------------------------------:://
    else if(lambda_counter == max_col_count && max_col_count > 0)
    begin
      lambda_counter <= lambda_counter+1;
      gap_eval_done  <= 0;
      
      if(BG == BG2)
      begin
        if(ils_selected inside {3'd3,3'd7})
        begin
          gap_array[0] <= lambda_sum;
          // gap_eval_counter <= gap_eval_counter+1;
        end
        
        else
        begin
          gap_array[0] <= shifted_vector; 
          // gap_eval_counter <= gap_eval_counter+1;
        end
      end
      
      else if(BG == BG1)
      begin
        
        if(ils_selected != 3'd6)
        begin
          if(zc == 10'd208)
          begin
            gap_array[0] <= shifted_vector;
            // gap_eval_counter <= gap_eval_counter+1;
          end
          
          else
          begin
            // gap_eval_counter <= gap_eval_counter+1;
            gap_array[0] <= lambda_sum;
          end
          
        end
        
        else
        begin
          gap_array[0] <= shifted_vector;
          // gap_eval_counter <= gap_eval_counter+1;
        end
      end
    end


//::-------------------------------------------------------------:://
//::------>>  evaluating Pa2,4 <<------------------------------:://
//::-------------------------------------------------------------:://
    else if(lambda_counter == max_col_count+1 && max_col_count > 0)
    begin
      lambda_counter <= lambda_counter+1;
      gap_eval_done  <= 0;
      
      if(BG == BG2)
      begin
        // gap_eval_counter <= gap_eval_counter+1;
        gap_array[1] <= lambda_array[0] ^ gap_array[0];
        gap_array[3] <= lambda_array[3] ^ gap_array[0];
      end
      
      else if (BG == BG1)
      begin
        
        
        if(ils_selected == 3'd6)
        begin
          // gap_eval_counter <= gap_eval_counter+1;
          gap_array[1] <= lambda_array[0] ^ gap_array[0];
          gap_array[3] <= lambda_array[3] ^ gap_array[0];
        end
        
        else
        begin
          // gap_eval_counter <= gap_eval_counter+1;
          gap_array[1] <= lambda_array[0] ^ shifted_vector;
          gap_array[3] <= lambda_array[3] ^ shifted_vector;
        end
      end
    end
//::-----------------------------------------------------------:://
//::-----------------------------------------------------------:://


//::-----------------------------------------------------------:://
//::------>>  evaluating Pa3 <<------------------------------:://
//::-----------------------------------------------------------:://
    else if(lambda_counter == max_col_count+2 && max_col_count > 0)
    begin
      lambda_counter <= 0;
      gap_eval_done  <= 1; 
      
      if(BG == BG2)
      begin
        gap_array[2] <= lambda_array[1] ^ gap_array[1];
      end
      
      else if (BG == BG1)
      begin
        gap_array[2] <= lambda_array[2] ^ gap_array[3];
      end
    end
//::--------------------------------------------------------:://
//::--------------------------------------------------------:://

end
//::----------------------------------------------------------------------------:://
//::----------------------------------------------------------------------------:://





//::----------------------------------------------------------------------------:://
//::---->>  configure shift metrics to enable mul_shift block sharing <<----:://
//::----------------------------------------------------------------------------:://
always_comb begin
  shift_factor = 0;
  mul_shift_enable = 0;
  if(lambda_counter == max_col_count)
  begin
    mul_shift_input_vector = lambda_sum;
    
    if(BG == BG2)
    begin
      if(ils_selected inside {3'd3,3'd7})
      begin
        shift_factor = 0;
        mul_shift_enable = 0;
      end
        
      else
      begin
        shift_factor = zc-1;
        mul_shift_enable = 1;
      end
      
    end
    
    else if(BG == BG1)
    begin
      
      if(ils_selected != 3'd6)
      begin
        if(zc == 10'd208)
        begin
          shift_factor = 10'd103;
          mul_shift_enable = 1;
        end
        
        else
        begin
          shift_factor = 0;
          mul_shift_enable = 0;
        end
      end
      
      else
      begin
        shift_factor = zc-1;
        mul_shift_enable = 1;
      end
      
    end
      
    else
    begin
      shift_factor = 0;
      mul_shift_enable = 0;
    end
  end
  
  
  
  else if(lambda_counter == max_col_count+1)
  begin
    mul_shift_input_vector = gap_array[0];
    shift_factor = 1;
    mul_shift_enable = 1;
  end
  
  else
  begin
    mul_shift_input_vector = 0;
    shift_factor = 0;
    mul_shift_enable = 0;
  end
  
end
//::----------------------------------------------------------------------------:://
//::----------------------------------------------------------------------------:://




//::----------------------------------------------------------------------------:://
//::------>>  shift lambda_sum a shift factor <<--------:://
//::----------------------------------------------------------------------------:://
mul_shift U_mul_shift_by_zc_minus_one (
  .msg_block(mul_shift_input_vector),
  .msg_block_size(zc),
  .shift_factor(shift_factor),
  .mul_shift_enable(mul_shift_enable),
  
  .result(shifted_vector)
);
//::----------------------------------------------------------------------------:://
//::----------------------------------------------------------------------------:://


endmodule