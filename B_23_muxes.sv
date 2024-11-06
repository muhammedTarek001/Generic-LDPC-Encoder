import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module B_23_muxes #(parameter  MUXES_INPUT_SIZE = 2 , MUXES_COUNT = 23) (
  input logic [MAX_ZC-1:0] new_msg ,
  input logic [MAX_ZC-1:0] parity_blocks [MUXES_COUNT-1:0],
  input logic [MUXES_COUNT-1:0] select_lines ,

  output logic [MAX_ZC-1:0] B_muxes_selected_msg_parity_blocks [MUXES_COUNT-1:0]
);
  
  always_comb begin
    for (int mux_no = 0; mux_no < MUXES_COUNT ; mux_no++) begin
      if(select_lines[mux_no] == 0)
      begin
        B_muxes_selected_msg_parity_blocks[mux_no] = new_msg;
      end
      
      else
      begin
        B_muxes_selected_msg_parity_blocks[mux_no] = parity_blocks[mux_no];
      end
    end
    
  end
  
endmodule