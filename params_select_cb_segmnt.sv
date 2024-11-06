import LDPC_pkg::* ;

module params_select_cb_segmnt (
  input logic [4:0] rate,
  input logic       tb_valid,
  input logic       new_tb,
  input logic [13:0] tb_with_crc_size,

  input clk,reset_n,

  output rd_en1, rd_en2,
  output logic [2:0] ils_selected,
  output logic [9:0] zc,
  output logic [4:0] kb,
  output logic [12:0] mssg_size_in_bg,
  output BG_Type BG,
  output logic params_valid
);
  logic [5:0] zc_index;
  logic zc_calc_done;

  enum logic[1:0] {IDLE, BG_KB_CALC ,ZC_CALC ,FILLER_CALC} current_state,next_state;



assign rd_en1 = (BG == BG1 && params_valid)? 1:0;
assign rd_en2 = (BG == BG2 && params_valid)? 1:0;


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
//::----->> next_state calculation <<------:://
//::----------------------------------------------:://
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: 
      begin
        if(tb_valid && new_tb)
          next_state = BG_KB_CALC;
        else
          next_state = IDLE;
      end 

      BG_KB_CALC:
      begin
        next_state = ZC_CALC;
      end

      ZC_CALC:
      begin
        if(zc_calc_done)
        begin
          next_state = FILLER_CALC;
        end
      end

      FILLER_CALC:
      begin
        next_state = IDLE;
      end
      default: next_state = current_state;
    endcase
  end
//::----------------------------------------------:://
//::----------------------------------------------:://






//::----------------------------------------------:://
//::----->> outputs calculation <<------:://
//::----------------------------------------------:://
  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      BG           <= NONE;
      kb           <= 0;
      zc           <= 0;
      zc_index     <= 0;
      zc_calc_done <= 0;
      params_valid <= 0;
      ils_selected <= 0;
    end
    
    else
    begin
      case (current_state)

      IDLE:
      begin
        zc_calc_done <= 0;
        params_valid <= 0;
        // BG           <= NONE;
      end

        BG_KB_CALC:
        begin
          zc_calc_done <= 0;
          params_valid <= 0;
          
          if((tb_with_crc_size <= 12'd3824 && rate < MAX_BG2_RATE) || tb_with_crc_size <9'd292 || rate <= MIN_BG1_RATE)
          begin
            BG <= BG2;
            if(tb_with_crc_size>640)
            begin
              kb <= 10;
            end
            
            else if(tb_with_crc_size>560)
            begin
              kb <= 9;
            end
            
            else if(tb_with_crc_size>192)
            begin
              kb <= 8;
            end
            
            else
            begin
              kb <= 6;
            end
            
          end
          
          else
          begin
            BG <= BG1;
            kb <= 22;
          end
          
        end

        ZC_CALC:
        
        begin
          if(Zc_values[zc_index]*kb >= tb_with_crc_size)
          begin
            zc <= Zc_values[zc_index];
            ils_selected <= Zc_iLS_mapping[zc_index];
            zc_calc_done <= 1;
          end
          
          else
          begin
            zc_index <= zc_index+1;
          end
        end

        FILLER_CALC:
        begin
          zc_calc_done <= 0;
          params_valid <= 1;
          
          if(kb == 22)
          begin
            mssg_size_in_bg <= (zc<<4) + (zc<<2) + (zc<<1);
          end
          
          else if(kb == 10)
          begin
            mssg_size_in_bg <= (zc<<3) + (zc<<1);
          end
          
          else if(kb == 9)
          begin
            mssg_size_in_bg <= (zc<<3) +zc;
          end
          
          else if(kb == 8)
          begin
            mssg_size_in_bg <= (zc<<3);
          end

          else if(kb == 6)
          begin
            mssg_size_in_bg <= (zc<<2) + (zc<<1);
          end
        end
      endcase
    end
    
  end
//::----------------------------------------------:://
//::----------------------------------------------:://





endmodule