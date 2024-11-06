import LDPC_pkg::* ;
import BG1_pkg::* ;
import BG2_pkg::* ;

module BG_calc (
  input logic [8:0] zc,
  input logic [8:0] bg1 [BG1_MAX_TRANSFORMS-1:0],
  input logic [8:0] bg2 [BG2_MAX_TRANSFORMS-1:0],
  input logic bg1_valid , bg2_valid,
  input logic [2:0] ils_selected,

  input logic clk, reset_n,

  output logic [8:0] bg1_calc_out [BG1_MAX_TRANSFORMS-1:0],
  output logic [8:0] bg2_calc_out [BG2_MAX_TRANSFORMS-1:0],
  // output logic        [6:0] bg1_indecies [BG1_MAX_TRANSFORMS-1:0][1:0],
  // output logic        [6:0] bg2_indecies [BG2_MAX_TRANSFORMS-1:0][1:0],
  output logic bg1_calc_valid , bg2_calc_valid
);
  
  
  enum logic[1:0] {IDLE, BG1_CALC , BG2_CALC} current_state,next_state;



  logic [8:0] element_dividend;
  logic [8:0] result_element;

  logic [9:0] transforms_counter;

  logic no_transform_needed;

  assign no_transform_needed = {ils_selected , zc} inside {
                                                            {3'd0 , 9'd256} , 
                                                            {3'd1 , 9'd384} ,
                                                            {3'd2 , 9'd320} ,
                                                            {3'd3 , 9'd224} ,
                                                            {3'd4 , 9'd288} ,
                                                            {3'd5 , 9'd352} ,
                                                            {3'd6 , 9'd208} ,
                                                            {3'd7 , 9'd240} 
                                                                              };







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






//::-----------------------------------------------------------------:://
//::----->> next_state calculation <<------:://
//::-----------------------------------------------------------------:://
  always_comb begin
    next_state = current_state;
    
    case (current_state)
      IDLE: 
      begin
        if(bg1_valid && !bg2_valid)
        begin
          
          if(no_transform_needed)
          begin
            next_state = IDLE;
          end
          
          else
          begin
            next_state = BG1_CALC;
          end
            
        end
        
        else if(!bg1_valid && bg2_valid)
        begin
          if(no_transform_needed)
          begin
            next_state = IDLE;
          end
          
          else
          begin
            next_state = BG2_CALC;
          end
        end
        
        else
        begin
          next_state = IDLE;
        end
      end

      BG1_CALC:
      begin
        if(transforms_counter == BG1_MAX_TRANSFORMS)
        begin
          next_state = IDLE;
        end
        
        else if(transforms_counter < BG1_MAX_TRANSFORMS)
        begin
          next_state = BG1_CALC;
        end
      end

      BG2_CALC:
      begin
        if(transforms_counter == BG2_MAX_TRANSFORMS)
        begin
          next_state = IDLE;
        end
        
        else if(transforms_counter < BG2_MAX_TRANSFORMS)
        begin
          next_state = BG2_CALC;
        end
      end
      default: next_state = current_state;

    endcase
  end
//::----------------------------------------------------------------:://
//::----------------------------------------------------------------:://






//::-----------------------------------------------------------------:://
//::----->> base graph indecies <<------:://
//::-----------------------------------------------------------------:://
always_comb begin
  element_dividend = 0;
  
  case (current_state)

    BG1_CALC:
    begin
      element_dividend = bg1[transforms_counter];
    end

    BG2_CALC:
    begin
      element_dividend = bg2[transforms_counter];
    end

    default: begin
      element_dividend = 0;
    end

  endcase
  
end

  remainder U_remainder (.element_dividend(element_dividend) , .zc_divisor(zc) , .result_element(result_element));

//::-----------------------------------------------------------------:://
//::-----------------------------------------------------------------:://






//::-----------------------------------------------------------------:://
//::----->> valid outputs calculation <<------:://
//::-----------------------------------------------------------------:://

  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      
      bg1_calc_valid <= 0;
      bg2_calc_valid <= 0;
      
      transforms_counter <= 0;
      
      for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
          bg1_calc_out[index] <= 0;
      end
      
      for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
          bg2_calc_out[index] <= 0;
      end
      
    end
    
    else
    begin
      case (current_state)

        IDLE:
        begin
          transforms_counter <= 0;
          
          if(!bg1_valid && !bg2_valid || (bg1_valid && bg2_valid))
          begin
            bg1_calc_valid <= 0;
            bg2_calc_valid <= 0;
          end
          
          else if(bg1_valid && !bg2_valid)
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
                bg1_calc_out[index] <= bg1[index];
            end
            
            if(no_transform_needed)
            begin
              bg1_calc_valid <= 1;
              bg2_calc_valid <= 0;
            end
          
          end
          
          else if(!bg1_valid && bg2_valid)
          begin
              
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
                bg2_calc_out[index] <= bg2[index];
            end
            
            if(no_transform_needed)
            begin
              bg1_calc_valid <= 0;
              bg2_calc_valid <= 1;
            end
            
          end
          
        end 

        BG1_CALC:
        begin
          if(transforms_counter == BG1_MAX_TRANSFORMS)
          begin
            bg1_calc_valid <=1;
            bg2_calc_valid <=0;
          end
          
          else if(transforms_counter < BG1_MAX_TRANSFORMS)
          begin
            bg1_calc_out[transforms_counter] <= result_element;
            transforms_counter <= transforms_counter+1;
          end
        end

        BG2_CALC:
        begin
          if(transforms_counter == BG2_MAX_TRANSFORMS)
          begin
            bg1_calc_valid <=0;
            bg2_calc_valid <=1;
          end
          
          else if(transforms_counter < BG2_MAX_TRANSFORMS)
          begin
            bg2_calc_out[transforms_counter] <= result_element;
            transforms_counter <= transforms_counter+1;
          end
        end

      endcase
    end
  end
//::-----------------------------------------------------------------:://
//::-----------------------------------------------------------------:://


endmodule