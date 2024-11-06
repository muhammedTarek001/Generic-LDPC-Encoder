import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module pre_encoder (
  input logic [MAX_ZC-1:0] msg_block,
  input logic new_msg_block,
  input logic [13:0] tb_with_crc_size,
  input logic tb_valid,
  input logic [4:0] rate,
  
  input logic clk, reset_n,

  output logic   [8:0] bg1_calc_out [BG1_MAX_TRANSFORMS-1:0],
  output logic   [8:0] bg2_calc_out [BG2_MAX_TRANSFORMS-1:0],
  output logic   bg1_calc_valid , bg2_calc_valid,
  output logic   [MAX_ZC-1:0] segmented_msg_block,
  output logic   seg_busy,
  output logic   new_seg_msg_block,
  output logic   [8:0] zc,
  output logic   [4:0] kb,
  output BG_Type BG,
  output logic   [2:0] ils_selected,
  output logic   params_valid
);






  logic rd_en1 , rd_en2;

  
  logic [12:0] mssg_size_in_bg;

  logic new_tb;
  logic tb_valid_delayed;





  logic  [8:0] bg1_out [BG1_MAX_TRANSFORMS-1:0];
  logic bg1_valid;

  logic  [8:0] bg2_out [BG2_MAX_TRANSFORMS-1:0];
  logic bg2_valid;



  // logic        [6:0] bg1_indecies [BG1_MAX_TRANSFORMS-1:0][1:0];
  // logic        [6:0] bg2_indecies [BG2_MAX_TRANSFORMS-1:0][1:0];

  assign new_tb = ~(tb_valid_delayed) && tb_valid; // this must b

  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      tb_valid_delayed <= 0;
    end
    
    begin
      tb_valid_delayed <= tb_valid;
    end
  end


  
  params_select_cb_segmnt U_params_select_cb_segmnt(.*);
  msg_seg_fillers_append U_msg_seg_fillers_append (.*);
  BG1_ROM U_BG1_ROM(.*);
  BG2_ROM U_BG2_ROM(.*);
  BG_calc U_BG_calc(.* , .bg1(bg1_out) , .bg2(bg2_out));
endmodule
