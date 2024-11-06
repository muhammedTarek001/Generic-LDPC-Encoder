`ifndef LDPC_PARAM
`define LDPC_PARAM

package LDPC_pkg;

  parameter POLY_24A = 25'b1101111100110010011000011,
            POLY_24B = 25'b1100011000000000000000011,
            POLY_16  = 17'b10000100000010001,
            MAX_TB_WITH_CRC_SIZE = 8024,
            ENCODER_CLK_PERIOD = 10,
            MAX_BG1_CB_SIZE = 8448,
            MAX_BG2_CB_SIZE = 3840,
            MIN_BG1_RATE = 5'b01000,
            MAX_BG2_RATE = 5'b10110,
            BG1_COL_COUNT = 68,
            BG1_ROW_COUNT = 46,
            HALF_BG1_ROW_COUNT = 23,
            HALF_BG2_ROW_COUNT = 19,
            GAP_COLS_COUNT =4, 
            BG1_MSG_COL_COUNT = 22,
            BG2_COL_COUNT = 52,
            BG2_ROW_COUNT = 42,
            BG2_MSG_COL_COUNT = 10,
            MAX_ZC = 384,
            MUL_SH_BLOCKS_COUNT = 23,
            ENCODER_HALF_CLK_PERIOD = 5,
            MAX_POSITIVE_MSG_COL_COUNT_2ND_HALF_BG1 = 5,
            MAX_POSITIVE_MSG_COL_COUNT_2ND_HALF_BG2 = 4;
            
  parameter bit [5:0] TRIVIAL_MSG_NO = 6'd32;
  parameter bit       ROW_INDEX_NON_MINUS_ONE = 0;
  parameter bit       COL_INDEX_NON_MINUS_ONE = 1;


  
  parameter bit [9:0]   Zc_values      [51]   =  '{
    2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24, 26, 28, 30, 32, 36, 40, 44, 48, 52, 
    56, 60, 64, 72, 80, 88, 96, 104, 112, 120, 128, 144, 160, 176, 192, 208, 224, 240, 256, 288, 320, 352, 384};

  parameter bit [9:0]   Zc_iLS_mapping [51]   =  '{
    0, 1, 0, 2, 1, 3, 0, 4, 2, 5, 1, 6, 3, 7, 0, 4, 2, 5, 1, 6, 3, 7, 0, 4, 2, 5, 
    1, 6, 3, 7, 0, 4, 2, 5, 1, 6, 3, 7, 0, 4, 2, 5, 1, 6, 3, 7, 0, 4, 2, 5, 1};
  

  typedef enum logic[1:0] { NONE,BG1,BG2 } BG_Type;


//::----------------------------------------------------------------------------------------:://
//::--------->> BG1 Extracting non-minus-one elements positions for each row <<---------:://
//::----------------------------------------------------------------------------------------:://
parameter bit[8:0] BG1_POSITIVE_ELEMENTS_INDECIES_STARTS_PER_ROW [BG1_ROW_COUNT-1:0] =  '{0, 17, 33, 50, 67, 69, 76, 84, 90, 99, 107, 113, 120, 126, 131, 137, 143, 148,
                                                                                          153, 158, 163, 168, 173, 177, 181, 186, 190, 194, 197, 201, 205, 209, 213, 217, 
                                                                                          221, 225, 229, 233, 236, 240, 244, 247, 251, 254, 258, 262};

parameter bit[8:0] BG2_POSITIVE_ELEMENTS_INDECIES_STARTS_PER_ROW [BG2_ROW_COUNT-1:0] =  '{0, 6, 14, 19, 27, 30, 35, 40, 45, 48, 52, 56, 60, 63, 67, 71, 74, 78, 82, 85,
                                                                                          88, 91, 94, 96, 99, 102, 104, 108, 110, 113, 115, 119, 121, 124, 127 , 130,
                                                                                          133, 136, 138, 141, 144, 147};



parameter bit[5:0] BG1_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW [0:HALF_BG1_ROW_COUNT-1][0:MAX_POSITIVE_MSG_COL_COUNT_2ND_HALF_BG1-1] = '{
'{1 ,2 ,10 ,18 ,TRIVIAL_MSG_NO }, 
  
'{0 ,3 ,4 ,11 ,22 }, 
  
'{1 ,6 ,7 ,14 ,TRIVIAL_MSG_NO }, 
  
'{0 ,2 ,4 ,15 ,TRIVIAL_MSG_NO }, 
  
'{1 ,6 ,8 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,4 ,19 ,21 ,TRIVIAL_MSG_NO }, 
  
'{1 ,14 ,18 ,25 ,TRIVIAL_MSG_NO }, 
  
'{0 ,10 ,13 ,24 ,TRIVIAL_MSG_NO }, 
  
'{1 ,7 ,22 ,25 ,TRIVIAL_MSG_NO }, 
  
'{0 ,12 ,14 ,24 ,TRIVIAL_MSG_NO }, 
  
'{1 ,2 ,11 ,21 ,TRIVIAL_MSG_NO }, 
  
'{0 ,7 ,15 ,17 ,TRIVIAL_MSG_NO }, 
  
'{1 ,6 ,12 ,22 ,TRIVIAL_MSG_NO }, 
  
'{0 ,14 ,15 ,18 ,TRIVIAL_MSG_NO }, 
  
'{1 ,13 ,23 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,9 ,10 ,12 ,TRIVIAL_MSG_NO }, 
  
'{1 ,3 ,7 ,19 ,TRIVIAL_MSG_NO }, 
  
'{0 ,8 ,17 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{1 ,3 ,9 ,18 ,TRIVIAL_MSG_NO }, 
  
'{0 ,4 ,24 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{1 ,16 ,18 ,25 ,TRIVIAL_MSG_NO }, 
  
'{0 ,7 ,9 ,22 ,TRIVIAL_MSG_NO }, 
  
'{1 ,6 ,10 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO}
};







parameter bit[5:0] BG2_2ND_HALF_POSITIVE_MSG_COLS_PER_ROW [0:HALF_BG1_ROW_COUNT-1][0:MAX_POSITIVE_MSG_COL_COUNT_2ND_HALF_BG1-1] = '{
'{0 ,3 ,5 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{1 ,2 ,9 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,5 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{2 ,7 ,12 ,13 ,TRIVIAL_MSG_NO }, 
  
'{0 ,6 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{1 ,2 ,5 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,4 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{2 ,5 ,7 ,9 ,TRIVIAL_MSG_NO }, 
  
'{1 ,13 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,5 ,12 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{2 ,7 ,10 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,12 ,13 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{1 ,5 ,11 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,2 ,7 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{10 ,13 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{1 ,5 ,11 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{0 ,7 ,12 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{2 ,10 ,13 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 
  
'{1 ,5 ,11 ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO },

'{TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 

'{TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 

'{TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }, 

'{TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO ,TRIVIAL_MSG_NO }
};
// parameter bit[4:0] BG1_ROW_23_POSITIVE_MSG_COLS[3:0] = {
// 1 ,2 ,10 ,18 };

// parameter bit[4:0] BG1_ROW_24_POSITIVE_MSG_COLS[3:0] = {
// 0 ,3 ,4 ,11 };

// parameter bit[4:0] BG1_ROW_25_POSITIVE_MSG_COLS[3:0] = {
// 1 ,6 ,7 ,14 };

// parameter bit[4:0] BG1_ROW_26_POSITIVE_MSG_COLS[3:0] = {
// 0 ,2 ,4 ,15 };

// parameter bit[4:0] BG1_ROW_27_POSITIVE_MSG_COLS[2:0] = {
// 1 ,6 ,8  };

// parameter bit[4:0] BG1_ROW_28_POSITIVE_MSG_COLS[3:0] = {
// 0 ,4 ,19 ,21 };

// parameter bit[4:0] BG1_ROW_29_POSITIVE_MSG_COLS[2:0] = {
// 1 ,14 ,18  };

// parameter bit[4:0] BG1_ROW_30_POSITIVE_MSG_COLS[2:0] = {
// 0 ,10 ,13  };

// parameter bit[4:0] BG1_ROW_31_POSITIVE_MSG_COLS[1:0] = {
// 1 ,7   };

// parameter bit[4:0] BG1_ROW_32_POSITIVE_MSG_COLS[2:0] = {
// 0 ,12 ,14  };

// parameter bit[4:0] BG1_ROW_33_POSITIVE_MSG_COLS[3:0] = {
// 1 ,2 ,11 ,21 };

// parameter bit[4:0] BG1_ROW_34_POSITIVE_MSG_COLS[3:0] = {
// 0 ,7 ,15 ,17 };

// parameter bit[4:0] BG1_ROW_35_POSITIVE_MSG_COLS[2:0] = {
// 1 ,6 ,12  };

// parameter bit[4:0] BG1_ROW_36_POSITIVE_MSG_COLS[3:0] = {
// 0 ,14 ,15 ,18 };

// parameter bit[4:0] BG1_ROW_37_POSITIVE_MSG_COLS[1:0] = {
// 1 ,13   };

// parameter bit[4:0] BG1_ROW_38_POSITIVE_MSG_COLS[3:0] = {
// 0 ,9 ,10 ,12 };

// parameter bit[4:0] BG1_ROW_39_POSITIVE_MSG_COLS[3:0] = {
// 1 ,3 ,7 ,19 };

// parameter bit[4:0] BG1_ROW_40_POSITIVE_MSG_COLS[2:0] = {
// 0 ,8 ,17  };

// parameter bit[4:0] BG1_ROW_41_POSITIVE_MSG_COLS[3:0] = {
// 1 ,3 ,9 ,18 };

// parameter bit[4:0] BG1_ROW_42_POSITIVE_MSG_COLS[1:0] = {
// 0 ,4   };

// parameter bit[4:0] BG1_ROW_43_POSITIVE_MSG_COLS[2:0] = {
// 1 ,16 ,18  };

// parameter bit[4:0] BG1_ROW_44_POSITIVE_MSG_COLS[2:0] = {
// 0 ,7 ,9  };

// parameter bit[4:0] BG1_ROW_45_POSITIVE_MSG_COLS[2:0] = {
// 1 ,6 ,10};



//====================================//


// parameter bit[1:0] ROW_24_POSITIVE_GAP_COLS = 0;



// parameter bit[1:0] ROW_29_POSITIVE_GAP_COLS = 3;

// parameter bit[1:0] ROW_30_POSITIVE_GAP_COLS = 2;

// parameter bit[1:0] ROW_31_POSITIVE_GAP_COLS[1:0] = {
// 0 ,3   };

// parameter bit[1:0] ROW_32_POSITIVE_GAP_COLS = 2;



// parameter bit[1:0] ROW_35_POSITIVE_GAP_COLS = 0;


// parameter bit[1:0] ROW_37_POSITIVE_GAP_COLS = 1;





// parameter bit[1:0] ROW_42_POSITIVE_GAP_COLS = 2;

// parameter bit[1:0] ROW_43_POSITIVE_GAP_COLS = 3;

// parameter bit[1:0] ROW_44_POSITIVE_GAP_COLS = 0;


//::----------------------------------------------------------------------------------------:://
//::----------------------------------------------------------------------------------------:://







endpackage

`endif