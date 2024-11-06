module parity_buffer #(
    parameter MAX_ZC =384,
    MUL_SH_BLOCKS_COUNT = 23
) (
  input logic [MAX_ZC-1:0] result_parities  [MUL_SH_BLOCKS_COUNT-1:0],
  input logic [8:0] rd_address,
  input logic wr_en,rd_en,

  input clk, reset_n,

  output logic [MAX_ZC-1:0] parity_out
);
  logic [MAX_ZC-1:0] parities_buffer [MUL_SH_BLOCKS_COUNT-1:0];

  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
    begin
      for (int ind = 0; ind < MUL_SH_BLOCKS_COUNT ;ind++ ) begin
        parities_buffer[ind] <= 0;
      end
    end
    
    else
    begin
      if(wr_en && ~rd_en)
      begin
        for (int ind = 0; ind < MUL_SH_BLOCKS_COUNT ;ind++ ) begin
          parities_buffer[ind] <= result_parities[ind];
        end
      end
      
      else if(~wr_en && rd_en)
      begin
        parity_out = parities_buffer[rd_address];
      end
    end
    
  end
endmodule