`timescale 1ns/100ps
integer output_file , stimulus_file;

module LDPC_encoder_tb (
  
);
  import LDPC_pkg::* ;
  import BG1_pkg::*;
  import BG2_pkg::*;

//::-------------------------------------------------:://
//::--------->> Inputs of Encoder <<-----------------:://
//::-------------------------------------------------:://
  logic [MAX_ZC-1:0] msg_block;
  logic new_msg_block;
  logic [13:0] tb_with_crc_size;
  logic tb_valid;
  logic [4:0] rate;
  logic [8:0] parity_out_address;
  logic parity_out_rd_en;
//::-------------------------------------------------:://
//::-------------------------------------------------:://


//::-------------------------------------------------:://
//::--------->> Outputs of Encoder <<-----------------:://
//::-------------------------------------------------:://
  logic   ready_to_encode;
  logic   cw_vector_valid;
  logic [MAX_ZC-1:0] parity_out;
//::-------------------------------------------------:://
//::-------------------------------------------------:://


  logic clk, reset_n;


//::-------------------------------------------------:://
//::--------->> Outputs of Pre-Encoder <<------------:://
//::-------------------------------------------------:://
  logic [8:0] bg1_calc_out [BG1_MAX_TRANSFORMS-1:0];
  logic [8:0] bg2_calc_out [BG2_MAX_TRANSFORMS-1:0];
  logic bg1_calc_valid , bg2_calc_valid;
  logic [MAX_ZC-1:0] segmented_msg_block;
  logic seg_busy;
  logic new_seg_msg_block;
//::-------------------------------------------------:://
//::-------------------------------------------------:://


  
  int i;
  int col_counter;
  real msg_blocks_384_no;
  real tb_with_crc_size_real;

  assign msg_blocks_384_no = tb_with_crc_size_real/384;
  assign tb_with_crc_size_real = tb_with_crc_size;


//::-------------------------------------------------:://
//::--------->> Pre-Encoder instantiation <<---------:://
//::-------------------------------------------------:://
  LDPC_encoder U_LDPC_encoder(.*);
//::-------------------------------------------------:://
//::-------------------------------------------------:://


  always #(ENCODER_HALF_CLK_PERIOD) clk = ~clk;


  initial begin
    clk = 0;
    new_msg_block = 0;
    msg_block = 0;
    tb_valid = 0;
    
    
    reset_n = 0;
    #2;
    reset_n = 1;
    #3
    
    output_file = $fopen("D:/ERI Internship/LDPC/RTL Implementation/Design Behaviour/RTL_Output.txt", "w");
    stimulus_file = $fopen( "D:/ERI Internship/LDPC/RTL Implementation/MATLAB stimulus/MATLAB_stimulus.txt", "r");
    
    
    if(output_file && stimulus_file)
    begin
      $display("files are opened successfully !!");
    end
    
    else
    begin
      $display("files are NOT opened successfully !!");
    end
    
    
    import_stimulus_export_results();
    
    $display("Test is finished !!! @time= " , $time);
    $fclose(output_file);
    // $stop;
  end
  
  // initial begin
  //   #905
  //   // ($time == time'(905))
    
  //   $display("BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[0][1] = %p" , TRIVIAL_MSG_NO);
  // end

  bit [384:0] line_no;
  string line;

  task import_stimulus_export_results();
    
    
    tb_valid = 1;
    
    
    fork
      begin
          
        while(!$feof(stimulus_file)) begin
          $fgets(line,stimulus_file);
          if(line_no == 0)
          begin
            //::---------------------------------:://
            //::--->> Importing Rate <<----------:://
            //::---------------------------------:://
            $sscanf(line,"%b" , rate);
            $display("rate = %p" , rate);
            //::---------------------------------:://
            //::---------------------------------:://
          end
          
          else if (line_no == 1)
          begin
            //::---------------------------------:://
            //::--->> Importing TB size <<-------:://
            //::---------------------------------:://
            $sscanf(line,"%d",tb_with_crc_size);
            $display("tb_with_crc_size = %p" , tb_with_crc_size);
            //::---------------------------------:://
            //::---------------------------------:://
          end
          
          else
          begin
            if(line_no == 2) //::---->> First message block to be transmitted needs to wait for params and BG calculation <<-----:://
            begin           
              @(posedge U_LDPC_encoder.U_pre_encoder.U_params_select_cb_segmnt.params_valid);  
              @(posedge (U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg1_calc_valid || U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg2_calc_valid)); 
            end
            
            $sscanf(line,"%b" , msg_block);
            // $display("agggain @time = %t", $time);
            $display("msg_block = %b" , msg_block);
            
            if( line_no == $ceil(msg_blocks_384_no) +2 )
            begin
              
              break;
            end
            
            #(ENCODER_CLK_PERIOD+0.1)
            
            new_msg_block = 1;
            #ENCODER_CLK_PERIOD
            new_msg_block = 0;
            
            @(posedge (U_LDPC_encoder.U_pre_encoder.U_msg_seg_fillers_append.seg_busy == 0));
          end
          line_no++;
          
          
        end
        // $display("bbbbbbbbrrrrrrreakkkk @time = %t", $time);
      end
      
      begin
        wait(U_LDPC_encoder.U_pre_encoder.U_params_select_cb_segmnt.params_valid == 1)
        $fdisplay(output_file, "################ params calculation ######################");
        
        
        $fdisplay(output_file, "kb = %d" , U_LDPC_encoder.U_pre_encoder.U_params_select_cb_segmnt.kb);
        $fdisplay(output_file, "zc = %d" , U_LDPC_encoder.U_pre_encoder.U_params_select_cb_segmnt.zc);
        
        
        
        
        
        @(posedge (U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg1_calc_valid || U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg2_calc_valid))
        $fdisplay(output_file, "################# selected_bg ##################### ");
        $fdisplay(output_file, "selected bg = ");
        
        if(U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg1_calc_valid && !U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg2_calc_valid)
        begin
          for (int m = 0; m < BG1_MAX_TRANSFORMS  ;m++ ) begin
            $fdisplay(output_file, "%d" ,U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg1_calc_out[m]);
          end
        end
        
        else if(!U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg1_calc_valid && U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg2_calc_valid)
        begin
          for (int i = 0; i < BG2_MAX_TRANSFORMS  ;i++ ) begin
            $fdisplay(output_file, "%d" ,U_LDPC_encoder.U_pre_encoder.U_BG_calc.bg2_calc_out[i]);
          end
        end
        
        
        
        
        
        $fdisplay(output_file, "################ msg segmentation ###################### ");
        wait(U_LDPC_encoder.U_pre_encoder.U_msg_seg_fillers_append.col_counter > 0)
        while(col_counter < U_LDPC_encoder.U_pre_encoder.U_msg_seg_fillers_append.max_col_count) begin
          #0.1
          wait( (U_LDPC_encoder.U_pre_encoder.U_msg_seg_fillers_append.new_seg_msg_block == 1));
          $fdisplay(output_file, "%384b",U_LDPC_encoder.U_pre_encoder.U_msg_seg_fillers_append.segmented_msg_block);
          // $display("%384b ,new_seg_msg_block=%p , @time=%t",U_LDPC_encoder.U_pre_encoder.U_msg_seg_fillers_append.segmented_msg_block , U_LDPC_encoder.U_pre_encoder.U_msg_seg_fillers_append.new_seg_msg_block ,$time);
          
          col_counter ++;
          #ENCODER_CLK_PERIOD;
        end
        
        
        
        // $display("gap_eval_done = %d , time_before_gap = %t" ,U_LDPC_encoder.U_lambda_gap_evaluate.gap_eval_done ,$time);
        // $display("BG2_ILS_6[2] = " , BG2_ILS_6[2]);
        $fdisplay(output_file, "################ gap generation ###################### ");
        wait( U_LDPC_encoder.U_lambda_gap_evaluate.gap_eval_done)
        for (int j = 0; j<GAP_COLS_COUNT ;j++ ) begin
          $fdisplay(output_file, "%384b",U_LDPC_encoder.U_lambda_gap_evaluate.gap_array[j]);
        end
        
        
        
        for (int i =0 ; i<30 ;i++ ) begin
          $fdisplay(output_file," ");
        end
        
        $fdisplay(output_file, "################ First-Half NON-gap generation ###################### ");
        @(posedge (U_LDPC_encoder.U_encoder_controller.current_col == U_LDPC_encoder.U_encoder_controller.max_col_count+GAP_COLS_COUNT) )
        for (int j = GAP_COLS_COUNT; j<MUL_SH_BLOCKS_COUNT ;j++ ) begin
          $fdisplay(output_file, "%384b",U_LDPC_encoder.non_gap_parities[j]);
        end
        
        
        for (int i =0 ; i<30 ;i++ ) begin
          $fdisplay(output_file," ");
        end
        
        
        
        $fdisplay(output_file, "################ Second-Half NON-gap generation ###################### ");
        @(posedge U_LDPC_encoder.U_encoder_controller.cw_done)
        if(U_LDPC_encoder.BG == BG1)
        begin
          for (int j = 0; j<MUL_SH_BLOCKS_COUNT ;j++ ) begin
            $fdisplay(output_file, "%384b",U_LDPC_encoder.non_gap_parities[j]);
          end
        end
        
        else if(U_LDPC_encoder.BG == BG2)
        begin
          for (int j = 0; j<MUL_SH_BLOCKS_COUNT-GAP_COLS_COUNT ;j++ ) begin
            $fdisplay(output_file, "%384b",U_LDPC_encoder.non_gap_parities[j]);
          end
        end
        
        
      end
    join
    
    #ENCODER_CLK_PERIOD;
    tb_valid = 0;
  endtask 
  
endmodule