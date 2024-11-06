import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module stored_msg_select(
  input logic [MAX_ZC-1:0] segmented_msg_block,
  input logic              new_seg_msg_block,
  input logic [4:0]        current_col,
  input logic [1:0]        stored_msg_selects [MUL_SH_BLOCKS_COUNT-1:0],
  input BG_Type BG,

  input logic clk,reset_n,

  output logic[MAX_ZC-1:0] selected_msg_blocks[MUL_SH_BLOCKS_COUNT-1:0]
);
  
  // logic [4:0] current_col;
  logic [MAX_ZC-1:0] msg_buffer      [BG1_MSG_COL_COUNT-1:0];
  logic [MAX_ZC-1:0] muxed_msg_blocks[BG1_MSG_COL_COUNT-1:0];
  
  logic [4:0]        msg_buffer_select_lines [MUL_SH_BLOCKS_COUNT-1:0];
  

  logic[MAX_ZC-1:0] BG1_msg_0_in [MUL_SH_BLOCKS_COUNT-1:0];
  logic[MAX_ZC-1:0] BG1_msg_1_in [MUL_SH_BLOCKS_COUNT-1:0];
  logic[MAX_ZC-1:0] BG1_msg_2_in [MUL_SH_BLOCKS_COUNT-1:0];
  logic[MAX_ZC-1:0] BG1_msg_3_in [MUL_SH_BLOCKS_COUNT-1:0];

  logic[MAX_ZC-1:0] BG2_msg_0_in [MUL_SH_BLOCKS_COUNT-1:0];
  logic[MAX_ZC-1:0] BG2_msg_1_in [MUL_SH_BLOCKS_COUNT-1:0];
  logic[MAX_ZC-1:0] BG2_msg_2_in [MUL_SH_BLOCKS_COUNT-1:0];
  logic[MAX_ZC-1:0] BG2_msg_3_in [MUL_SH_BLOCKS_COUNT-1:0];

  logic[MAX_ZC-1:0] BG1_selected_msg_blocks[MUL_SH_BLOCKS_COUNT-1:0];
  logic[MAX_ZC-1:0] BG2_selected_msg_blocks[MUL_SH_BLOCKS_COUNT-1:0];


  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      for (int msg_index = 0;msg_index< BG1_MSG_COL_COUNT;msg_index++ ) begin
        msg_buffer[msg_index] <= 0;
      end
    end
    
    else if(new_seg_msg_block)
    begin
      msg_buffer[current_col] <= segmented_msg_block;
    end
  end
  
  
  
  
  always_comb begin
      for (int row_no = 0 ; row_no<MUL_SH_BLOCKS_COUNT ; row_no++) begin
        BG1_msg_0_in [row_no] = msg_buffer[  BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [0]  ];
        BG1_msg_1_in [row_no] = msg_buffer[  BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [1]  ];
        BG1_msg_2_in [row_no] = msg_buffer[  BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [2]  ];
        BG1_msg_3_in [row_no] = msg_buffer[  BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [3]  ];
      end
      
      for (int row_no = 0 ; row_no<MUL_SH_BLOCKS_COUNT ; row_no++) begin
        BG2_msg_0_in [row_no] = msg_buffer[  BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [0]  ];
        BG2_msg_1_in [row_no] = msg_buffer[  BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [1]  ];
        BG2_msg_2_in [row_no] = msg_buffer[  BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [2]  ];
        BG2_msg_3_in [row_no] = msg_buffer[  BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW[row_no] [3]  ];
      end
  end
  
  
  
  
  
  
  always_comb begin 
    if(BG == BG1)
    begin
      for (int block_no = 0; block_no<MUL_SH_BLOCKS_COUNT ; block_no++) begin
        selected_msg_blocks[block_no] = BG1_selected_msg_blocks[block_no];
      end
    end
    
    else
    begin
      for (int block_no = 0; block_no<MUL_SH_BLOCKS_COUNT ; block_no++) begin
        selected_msg_blocks[block_no] = BG2_selected_msg_blocks[block_no];
      end
    end
    
  end
  
  
  
  
  
  always_comb begin
    
    for (int block_no = 0; block_no < MUL_SH_BLOCKS_COUNT ; block_no++ ) begin
      if(stored_msg_selects[block_no] == 0)
      begin
        BG1_selected_msg_blocks[block_no] = BG1_msg_0_in[block_no];
      end
      
      else if(stored_msg_selects[block_no] == 1)
      begin
        BG1_selected_msg_blocks[block_no] = BG1_msg_1_in[block_no];
      end
      
      else if(stored_msg_selects[block_no] == 2)
      begin
        BG1_selected_msg_blocks[block_no] = BG1_msg_2_in[block_no];
      end
      
      else
      begin
        BG1_selected_msg_blocks[block_no] = BG1_msg_3_in[block_no];
      end
    end
    
    
    
    for (int block_no = 0; block_no < MUL_SH_BLOCKS_COUNT ; block_no++ ) begin
      if(stored_msg_selects[block_no] == 0)
      begin
        BG2_selected_msg_blocks[block_no] = BG2_msg_0_in[block_no];
      end
      
      else if(stored_msg_selects[block_no] == 1)
      begin
        BG2_selected_msg_blocks[block_no] = BG2_msg_1_in[block_no];
      end
      
      else if(stored_msg_selects[block_no] == 2)
      begin
        BG2_selected_msg_blocks[block_no] = BG2_msg_2_in[block_no];
      end
      
      else
      begin
        BG2_selected_msg_blocks[block_no] = BG2_msg_3_in[block_no];
      end
    end
    
  end
  
  
  // genvar BG1_mux_no;
  // generate
  //   for (BG1_mux_no =0;BG1_mux_no<MUL_SH_BLOCKS_COUNT ;BG1_mux_no++ )    begin : BG1_MSG_MUXES
  //     msg_mux_4_to_1 U0_msg_mux_4_to_1(.msg_0_in(BG1_msg_0_in[BG1_mux_no]),
  //                                     .msg_1_in(BG1_msg_1_in[BG1_mux_no]),
  //                                     .msg_2_in(BG1_msg_2_in[BG1_mux_no]),
  //                                     .msg_3_in(BG1_msg_3_in[BG1_mux_no]),
  //                                     .select(stored_msg_selects[BG1_mux_no]),
  //                                     .msg_selected(BG1_selected_msg_blocks[BG1_mux_no])
  //                                     );
  //   end
  // endgenerate



  // genvar BG2_mux_no;
  // generate
  //   for (BG2_mux_no =0;BG2_mux_no<MUL_SH_BLOCKS_COUNT ;BG2_mux_no++ )    begin : BG2_MSG_MUXES
  //     msg_mux_4_to_1 U1_msg_mux_4_to_1( .msg_0_in(BG2_msg_0_in[BG2_mux_no]),
  //                                       .msg_1_in(BG2_msg_1_in[BG2_mux_no]),
  //                                       .msg_2_in(BG2_msg_2_in[BG2_mux_no]),
  //                                       .msg_3_in(BG2_msg_3_in[BG2_mux_no]),
  //                                       .select(stored_msg_selects[BG2_mux_no]),
  //                                       .msg_selected(BG2_selected_msg_blocks[BG2_mux_no])
  //                                     );
  //   end
  // endgenerate

endmodule