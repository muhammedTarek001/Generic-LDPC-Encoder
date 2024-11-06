import LDPC_pkg::* ;
import BG1_pkg::* ;

module BG1_ROM (
  input logic rd_en1,
  input logic [2:0] ils_selected,

  input logic clk , reset_n,

  output logic [8:0] bg1_out [BG1_MAX_TRANSFORMS-1:0],
  output logic bg1_valid
);
  
  


  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      bg1_valid <= 0;
      
      for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
        bg1_out[index] <= 0;
      end
    end

    else
    begin
      if(rd_en1)
      begin
        
        bg1_valid <= 1;
        
        case (ils_selected)

          //::------------------------------------------------:://
          //::--->> BG1_ILS0 <<---:://
          //::------------------------------------------------:://
          0: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              bg1_out[index] <= BG1_ILS_0[index];
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG1_ILS1 <<---:://
          //::------------------------------------------------:://
          1: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg1_out[index] <= BG1_ILS_1[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://
          



          //::------------------------------------------------:://
          //::--->> BG1_ILS2 <<---:://
          //::------------------------------------------------:://
          2: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg1_out[index] <= BG1_ILS_2[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG1_ILS3 <<---:://
          //::------------------------------------------------:://
          3: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg1_out[index] <= BG1_ILS_3[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG1_ILS4 <<---:://
          //::------------------------------------------------:://
          4: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg1_out[index] <= BG1_ILS_4[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://



          //::------------------------------------------------:://
          //::--->> BG1_ILS5 <<---:://
          //::------------------------------------------------:://
          5: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg1_out[index] <= BG1_ILS_5[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://


          //::------------------------------------------------:://
          //::--->> BG1_ILS6 <<---:://
          //::------------------------------------------------:://
          6: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg1_out[index] <= BG1_ILS_6[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://


          //::------------------------------------------------:://
          //::--->> BG1_ILS7 <<---:://
          //::------------------------------------------------:://
          7: 
          begin
            
            for (int index = 0; index<BG1_MAX_TRANSFORMS ;index++ ) begin
              for ( int col = 0; col<26 ;col++ ) begin
                bg1_out[index] <= BG1_ILS_7[index];
              end
            end
          end
          //::------------------------------------------------:://
          //::------------------------------------------------:://

        endcase
      end

      else
      begin
        bg1_valid <= 0;
      end
    end
  end
endmodule