`timescale 1ns/10ps
`define PERIOD 10.0
`define PatternPATH "./pattern/"
`define offset 54
`define size_width 256
`define size_pic `size_width*`size_width
`define MAXCYCLE 12000000

module tb_median_fliter;

reg                   clk;
reg                   rst;
reg                enable;
wire   [7:0]    RAM_IMG_Q;
wire   [7:0]    RAM_OUT_Q;
wire           RAM_IMG_OE;
wire           RAM_IMG_WE;
wire   [15:0]   RAM_IMG_A;
wire   [7:0]    RAM_IMG_D;
wire           RAM_OUT_OE;
wire           RAM_OUT_WE;
wire   [15:0]   RAM_OUT_A;
wire   [7:0]    RAM_OUT_D;
wire                 done;

reg [7:0] ANS [`size_pic-1:0];
reg [7:0] header [`offset-1:0];
integer ofile, ifile;
integer ErrorNum;
int linedata1, linedata2, linedata3;

median_fliter median_fliter(
  // input port
  .clk       (clk       ),
  .rst       (rst       ),
  .enable    (enable    ),
  .RAM_IMG_Q (RAM_IMG_Q ),
  .RAM_OUT_Q (RAM_OUT_Q ),
  // output port
  .RAM_IMG_OE(RAM_IMG_OE),
  .RAM_IMG_WE(RAM_IMG_WE),
  .RAM_IMG_A (RAM_IMG_A ),
  .RAM_IMG_D (RAM_IMG_D ),
  .RAM_OUT_OE(RAM_OUT_OE),
  .RAM_OUT_WE(RAM_OUT_WE),
  .RAM_OUT_A (RAM_OUT_A ),
  .RAM_OUT_D (RAM_OUT_D ),
  .done      (done      ) 
);

RAM IMG_RAM(
  .CK(clk), 
  .A (RAM_IMG_A), 
  .WE(RAM_IMG_WE), 
  .OE(RAM_IMG_OE), 
  .D (RAM_IMG_D), 
  .Q (RAM_IMG_Q)
);

RAM OUT_RAM(
  .CK(clk), 
  .A (RAM_OUT_A), 
  .WE(RAM_OUT_WE), 
  .OE(RAM_OUT_OE), 
  .D (RAM_OUT_D), 
  .Q (RAM_OUT_Q)
);

always #(`PERIOD / 2.0)clk = ~clk;

initial begin
  $display("********************************");
  $display("**      Simulation Start      **");
  $display("********************************");
end 

initial begin
  linedata1 = $fopen({`PatternPATH, "Golden.dat"}, "r");
  linedata2 = $fopen({`PatternPATH, "Lena_pepper.dat"} ,"r");
  linedata3 = $fopen({`PatternPATH, "BmpHeader.dat"} ,"r");
  if (linedata1 == 0 || linedata2 == 0 || linedata3 == 0) begin
    $display("\n");
    $display("********************************");
    $display("**    pattern handle null     **");
    $display("********************************");
    $finish;
  end
  $fclose(linedata1);
  $fclose(linedata2);
  $fclose(linedata3);
end

initial begin
  $readmemh({`PatternPATH, "Golden.dat"}, ANS);
  $readmemh({`PatternPATH, "Lena_pepper.dat"}, IMG_RAM.memory);
  $readmemh({`PatternPATH, "BmpHeader.dat"}, header);
end

initial begin
  clk    = 0;
  rst    = 1;
  enable = 0;
  ErrorNum = 0;
  ofile = 0;
  ifile = 0;
  repeat(3)@(posedge clk)rst = 1;
  rst = 0;
  #(`PERIOD);
  #(`PERIOD / 2.0)enable = 1;
  #(`PERIOD)enable = 0;
  // ===================== check ANS =====================
  wait(done == 1);
  @(posedge clk);
  for(int i=0;i<`size_pic;i=i+1)begin
    if( (OUT_RAM.memory[i] !== ANS[i] || $isunknown(OUT_RAM.memory[i])))begin
      $display("Error, RAM_OUT[%5d] = %3d, expect = %3d", i, OUT_RAM.memory[i], ANS[i]);
      ErrorNum = ErrorNum + 1;
    end
  end
  if(ErrorNum === 0)begin
    $display("\n");
    $display(" ****************************               ");
    $display(" **                        **       |\__||  ");
    $display(" **  Congratulations !!    **      / O.O  | ");
    $display(" **                        **    /_____   | ");
    $display(" **  Simulation PASS!!     **   /^ ^ ^ \\  |");
    $display(" **                        **  |^ ^ ^ ^ |w| ");
    $display(" ****************************   \\m___m__|_|");
    $display("\n");
  end
  else begin
    $display("\n");
    $display(" ****************************               ");
    $display(" **                        **       |\__||  ");
    $display(" **  OOPS!!                **      / X,X  | ");
    $display(" **                        **    /_____   | ");
    $display(" **  Simulation Failed!!   **   /^ ^ ^ \\  |");
    $display(" **                        **  |^ ^ ^ ^ |w| ");
    $display(" ****************************   \\m___m__|_|");
    $display(" Correct / ALL : %5d / %5d  " ,`size_pic-ErrorNum, `size_pic);
    $display("\n");
  end
  // ===================== write BMP file =====================
  ifile = $fopen("input_image.bmp", "wb");
  ofile = $fopen("your_result.bmp", "wb");
  // write header
  for(int i=0;i<`offset;i++)begin
    $fwrite(ifile, "%c", header[i]);
    $fwrite(ofile, "%c", header[i]);
  end
  // write data
  for(int i=0;i<`size_pic;i++)begin
    automatic int y = (`size_pic-1-i) / 256;
    automatic int x = (`size_pic-1-i) % 256;
    automatic int newAddr = y * 256 + (255-x);
    for(int rgb=0;rgb<3;rgb++)begin
      $fwrite(ifile, "%c", IMG_RAM.memory[newAddr]);
      $fwrite(ofile, "%c", OUT_RAM.memory[newAddr]);
    end
  end
  $fclose(ifile); 
  $fclose(ofile); 
  $finish;
end

initial begin
  #(`MAXCYCLE * `PERIOD);
  $display("*************************************");
  $display("                                     ");
  $display(" OOPS, simulation can not finish...  ");
  $display("                                     ");
  $display("*************************************");
  $finish;
end
 
endmodule


module RAM (CK, A, WE, OE, D, Q);

  input                      CK;
  input  [15:0]               A;
  input                      WE;
  input                      OE;
  input  [7:0]                D;
  output [7:0]                Q;

  reg    [7:0]                Q;
  reg    [15:0]       latched_A;
  reg    [15:0]   latched_A_neg;
  reg    [7:0] memory [65535:0];

  always @(posedge CK) begin
    if (WE) begin
      memory[A] <= D;
    end
		latched_A <= A;
  end
  
  always@(negedge CK) begin
    latched_A_neg <= latched_A;
  end
  
  always @(*) begin
    if (OE) begin
      Q = memory[latched_A_neg];
    end
    else begin
      Q = 8'hzz;
    end
  end
  
endmodule
