import LDPC_pkg::*;
import BG1_pkg::*;
import BG2_pkg::*;

module C_23_muxes #(parameter  MUXES_INPUT_SIZE = 4 , MUXES_COUNT = 23) (
  input logic [MAX_ZC-1:0] parity_blocks [MUXES_INPUT_SIZE-1:0],
  input logic [1:0] select_lines [MUXES_COUNT-1:0],

  output logic [MAX_ZC-1:0] C_muxes_selected_parity_blocks [MUXES_COUNT-1:0]
);
  
  always_comb begin
    for (int mux_no = 0; mux_no < MUXES_COUNT ; mux_no++) begin
      C_muxes_selected_parity_blocks[mux_no] = parity_blocks[select_lines[mux_no]];
    end
  end

endmodule