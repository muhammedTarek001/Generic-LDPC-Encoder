import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module msg_seg_fillers_append (
  input logic [MAX_ZC-1:0] msg_block,
  input logic [8:0] zc,
  input logic new_msg_block,
  input logic [13:0] tb_with_crc_size,
  input BG_Type BG, 

  input logic clk, reset_n,

  output logic [MAX_ZC-1:0] segmented_msg_block,
  output logic new_seg_msg_block,
  output logic seg_busy
);

  localparam FRAGS_SIZE = 352;

  logic [9:0]  bit_counter;
  logic [13:0] absolute_bit_counter;

  logic [4:0] col_counter;
  logic [4:0] max_col_count;

  logic [MAX_ZC-1:0] segmented_msg_block_comb;

  logic [FRAGS_SIZE-1:0] last_frags;
  logic [FRAGS_SIZE-1:0] last_frags_muxed; 
  logic frags_flag;
  logic [9:0] frags_start_index;

  logic signed [9:0] seg_muxes_selects [MAX_ZC-1:0];

always_comb begin
  for (int j = 0; j<MAX_ZC ; j++) begin
    seg_muxes_selects [j] = (j-MAX_ZC)+frags_start_index; //start from here
  end
end

  assign seg_busy = (bit_counter > 0 || (bit_counter == 0 && new_seg_msg_block)) ? 1:0;

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


  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      bit_counter           <= 0;
      absolute_bit_counter  <= 0;
      col_counter           <= 0;
      segmented_msg_block   <= 0;
      frags_flag            <= 0;
      last_frags            <= 0;
      frags_start_index     <= 0;
      new_seg_msg_block     <= 0;
    end
    
    else if(absolute_bit_counter <= tb_with_crc_size && tb_with_crc_size > 0) begin
      if( (new_msg_block && bit_counter == 0 && (col_counter == 0 || zc == 9'd384)) || (  ((bit_counter+zc)>=1 && (bit_counter+zc)<=MAX_ZC-2) && col_counter > 0 && col_counter < max_col_count && max_col_count > 0 && (new_msg_block || seg_busy) ) )
      begin
        col_counter <= col_counter+1;
        absolute_bit_counter <= absolute_bit_counter + zc;
        
        if(frags_flag == 0)  // CORRECT !!
        begin
          // $display("heello  new_msg_block =%p , @time= %t  " , new_msg_block, $time);
          bit_counter <= bit_counter+zc;
          new_seg_msg_block <= 1;
          
          for (int i = 0; i<MAX_ZC ;i++ ) begin
            if(i < zc) //384 comparator
            begin
              segmented_msg_block[i] <=  segmented_msg_block_comb[i];
            end
            
            else
            begin
              segmented_msg_block[i] <= 0;
            end
          end
        end
        
        else if(frags_flag == 1) begin
          frags_flag <= 0;
          new_seg_msg_block <= 1;
          bit_counter <= zc-(MAX_ZC-frags_start_index);
          
          for (int index = 0; index<FRAGS_SIZE ;index++) begin
            if(index < zc)           //384 comparator
            begin
              if(index < MAX_ZC-frags_start_index) //384 comparator
              begin
                segmented_msg_block[index] <= last_frags_muxed[index];
              end
              
              else if(absolute_bit_counter + (MAX_ZC-frags_start_index) < tb_with_crc_size)
              begin
                segmented_msg_block[index] <= segmented_msg_block_comb[index];
              end
              
              else
              begin
                segmented_msg_block[index] <= 0;
              end
            end
            
            else
            begin
              segmented_msg_block[index] <= 0;
            end
          end
          
          
          
          
          
          for (int index = FRAGS_SIZE; index < MAX_ZC ; index++ ) begin
            if(index < zc)
            begin
              if(absolute_bit_counter + (MAX_ZC-frags_start_index) < tb_with_crc_size)
              begin
                segmented_msg_block[index] <= segmented_msg_block_comb[index];
              end
              
              else
              begin
                segmented_msg_block[index] <= 0;
              end
            end
            
            else
            begin
              segmented_msg_block[index] <= 0;
            end
          end
          
          
        end
      end
      
      else if(bit_counter+zc >= MAX_ZC && col_counter < max_col_count ) begin
        
        if(zc != 9'd384)
        begin
          new_seg_msg_block <= 0;
          frags_start_index <= bit_counter;
          last_frags <= msg_block[MAX_ZC-1:MAX_ZC-FRAGS_SIZE];
          frags_flag <= 1;
          bit_counter <= 0;
        end
        
        
        else if(bit_counter == MAX_ZC && zc == 9'd384)
        begin
          new_seg_msg_block <= 0;
          bit_counter <= 0;
        end
        
        // segmented_msg_block <=0; //WHY ???
        // if(bit_counter+zc < tb_with_crc_size)
        // begin
          
        // end
        
        // else
        // begin
        //   col_counter <= col_counter+1;
        //   new_seg_msg_block <= 1;
        //   frags_flag  <= 0;
        //   // bit_counter <= 0;
        //   segmented_msg_block <=0;
        // end
        
      end
      
      else if((bit_counter+zc == MAX_ZC-1) && col_counter < max_col_count)
      begin
        col_counter <= col_counter+1;
        new_seg_msg_block <= 1;
        frags_flag  <= 0;
        bit_counter <= 0;
      end
      
      else if(col_counter == max_col_count && max_col_count > 0)
      begin
        col_counter <= 0;
        new_seg_msg_block <= 0;
        frags_flag  <= 0;
        bit_counter <= 0;
        frags_start_index <= 0;
      end
    end
    
    
    else if(absolute_bit_counter > tb_with_crc_size && tb_with_crc_size > 0 && col_counter < max_col_count && max_col_count > 0)
    begin
      bit_counter <= 0;

      if(bit_counter == 0)
      begin
        if(frags_flag == 0)
        begin
          col_counter <= col_counter+1;
          segmented_msg_block <= 0;
          new_seg_msg_block <= 1;
        end
        
        else if(frags_flag == 1)
        begin
          
          for (int index = 0; index<FRAGS_SIZE ;index++) begin
            
            if(index < zc)           //384 comparator
            begin
              if(index < MAX_ZC-frags_start_index) //384 comparator
              begin
                segmented_msg_block[index] <= last_frags_muxed[index];
              end
              else
              begin
                segmented_msg_block[index] <= 0;
              end
            end
          end
          
          for (int index = FRAGS_SIZE; index<MAX_ZC ;index++) begin
            if(index < zc)
            begin
              segmented_msg_block[index] <= 0;
            end
          end
          
        end  
      end
      
      else 
      begin
        col_counter <= col_counter+1;
        segmented_msg_block <= 0;
        new_seg_msg_block <= 1;
      end
      
    end
    
    else if(absolute_bit_counter > tb_with_crc_size && tb_with_crc_size > 0 && col_counter == max_col_count && max_col_count > 0)
    begin
        absolute_bit_counter <= 0;
        bit_counter <= 0;
        col_counter <= 0;
        segmented_msg_block <= 0;
        new_seg_msg_block <= 0;
    end
    
  end




logic [8:0] normal_seg_selects[MAX_ZC-1:0];

always_comb begin 
  for (int seg_index = 0; seg_index < MAX_ZC  ;seg_index++ ) begin
    normal_seg_selects[seg_index] = (frags_flag == 1) ? (seg_muxes_selects[seg_index]) : (bit_counter+seg_index);
    segmented_msg_block_comb [seg_index] = msg_block[normal_seg_selects[seg_index]];
  end
end




logic [8:0] frag_seg_selects[FRAGS_SIZE-1:0];

always_comb begin 
  for (int muxed_frag_index = 0; muxed_frag_index < FRAGS_SIZE  ;muxed_frag_index++ ) begin
    frag_seg_selects [muxed_frag_index] = frags_start_index + (muxed_frag_index-32);
    last_frags_muxed [muxed_frag_index] = last_frags[frag_seg_selects [muxed_frag_index]];
  end
end

endmodule