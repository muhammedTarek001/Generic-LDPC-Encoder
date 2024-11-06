module remainder (
  input  [8:0] element_dividend,
  input  [8:0] zc_divisor,

  output [8:0] result_element 
);
  
  assign result_element = element_dividend % zc_divisor;
endmodule