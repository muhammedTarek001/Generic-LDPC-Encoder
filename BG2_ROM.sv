import LDPC_pkg::* ;
import BG2_pkg::* ;

module BG2_ROM (
  input logic rd_en2,
  input logic [2:0] ils_selected,

  input logic clk , reset_n,

  output logic [8:0] bg2_out [BG2_MAX_TRANSFORMS-1:0],
  output logic bg2_valid
);
  
  
  
  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      bg2_valid <= 0;
      
      for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
        bg2_out[index] <= 0;
      end
    end
    
    else
    begin
      if(rd_en2)
      begin
        
        bg2_valid <= 1;
        
        case (ils_selected)

          //::------------------------------------------------:://
          //::--->> BG2_ILS0 <<---:://
          //::------------------------------------------------:://
          0: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              bg2_out[index] <= BG2_ILS_0[index];
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG2_ILS2 <<---:://
          //::------------------------------------------------:://
          1: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg2_out[index] <= BG2_ILS_1[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://
          



          //::------------------------------------------------:://
          //::--->> BG2_ILS2 <<---:://
          //::------------------------------------------------:://
          2: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg2_out[index] <= BG2_ILS_2[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG2_ILS3 <<---:://
          //::------------------------------------------------:://
          3: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg2_out[index] <= BG2_ILS_3[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG2_ILS4 <<---:://
          //::------------------------------------------------:://
          4: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg2_out[index] <= BG2_ILS_4[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG2_ILS5 <<---:://
          //::------------------------------------------------:://
          5: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg2_out[index] <= BG2_ILS_5[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://


          //::------------------------------------------------:://
          //::--->> BG2_ILS6 <<---:://
          //::------------------------------------------------:://
          6: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg2_out[index] <= BG2_ILS_6[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://


          //::------------------------------------------------:://
          //::--->> BG2_ILS7 <<---:://
          //::------------------------------------------------:://
          7: 
          begin
            
            for (int index = 0; index<BG2_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg2_out[index] <= BG2_ILS_7[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://

        endcase
      end
      
      else
      begin
        bg2_valid <= 0;
      end
    end
  end
endmodule