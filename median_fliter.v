module median_fliter(
  // input port
  input                  clk,
  input                  rst,
  input               enable,
  input  [7:0]     RAM_IMG_Q,
  input  [7:0]     RAM_OUT_Q,
  // output port
  output reg RAM_IMG_OE,
  output reg RAM_IMG_WE,
  output reg[15:0] RAM_IMG_A,
  output reg[7:0] RAM_IMG_D,
  output reg RAM_OUT_OE,
  output reg RAM_OUT_WE,
  output reg[15:0] RAM_OUT_A,
  output reg[7:0] RAM_OUT_D,
  output reg done
);

reg [15:0] c,c1,c2,c3,c4;
reg [17:0] n,r;
reg [3:0] i,j,k,a,d,b; 
reg [7:0] data[0:8];
reg [4:0] state,next_state;

reg [7:0] w_8_1, w_8_2, w_8_3, w_8_4, w_8_5, w_8_6, w_8_7, w_8_8;
reg [7:0] w_7_1, w_7_2, w_7_3, w_7_4, w_7_5, w_7_6, w_7_7;
reg [7:0] w_6_1, w_6_2, w_6_3, w_6_4, w_6_5, w_6_6;
reg [7:0] w_5_1, w_5_2, w_5_3, w_5_4, w_5_5;
reg [7:0] w_4_1, w_4_2, w_4_3, w_4_4;
reg [7:0] w_3_1, w_3_2, w_3_3;
reg [7:0] w_2_1, w_2_2;

reg[7:0]  sortNum1_o;
reg[7:0]  sortNum2_o;
reg[7:0]  sortNum3_o;
reg[7:0]  sortNum4_o;
reg[7:0]  sortNum5_o;
reg[7:0]  sortNum6_o;
reg[7:0]  sortNum7_o;
reg[7:0]  sortNum8_o;
reg[7:0]  sortNum9_o;

parameter INIT=4'd0,IMG_ADDR=4'd1,WAIT=4'd2,DATA_i=4'd3,
          DATA_j=4'd4,DATA_k=4'd5,DATA_a=4'd6,DATA_b=4'd7,DATA_d=4'd8,SORTING=4'd9,RESULT=4'd10;

always @(posedge clk or posedge rst ) begin
  if(rst) state=INIT;
  else state=next_state;
end

always @(*) begin
  case (state)
    INIT:begin
      next_state=(enable)?IMG_ADDR:INIT;
    end
  
    IMG_ADDR:begin
      next_state=WAIT;
    end

    WAIT:begin
      next_state=(n==0||n==255||n==65790||n==66045)?DATA_i
                 :(n>0&&n<255)?DATA_j:(n>65790&&n<66045)?
                DATA_b:(n%258==0&&n!=0&&n!=65790)?DATA_k:(n%258==255&&n!=255&&n!=66045)?DATA_d:DATA_a;
    end

    DATA_i:begin
      next_state=(i>3)?SORTING:IMG_ADDR;
    end 

    DATA_j:begin
      next_state=(j>5)?SORTING:IMG_ADDR;
    end

    DATA_k:begin
      next_state=(k>5)?SORTING:IMG_ADDR;
    end

    DATA_a:begin
      next_state=(a>8)?SORTING:IMG_ADDR;
    end

     DATA_b:begin
      next_state=(b>5)?SORTING:IMG_ADDR;
    end

    DATA_d:begin
      next_state=(d>5)?SORTING:IMG_ADDR;
    end

    SORTING:begin
      next_state=RESULT;
    end

    RESULT:begin
      next_state=(r>65535)?INIT:IMG_ADDR;
    end
    default:begin
    end
  endcase 
end

always @(posedge clk) begin
  case (state)
    INIT:begin
      c=0;
      c1=0;
      i=0;
      n=0;
      j=0;
      k=0;
      r=0;
      c2=0;
      a=0;
      d=0;
      b=0;
      c3=16'hFE;
      c4=16'hFE00;
      done=(RAM_OUT_A==65535)?1:0;
    end
  
    IMG_ADDR:begin
       RAM_OUT_WE=0;
       RAM_IMG_OE=1;
        if (n==0) begin
          if (i==0) RAM_IMG_A=16'h0;
          else if (i==1) RAM_IMG_A=16'h1;      
          else if (i==2) RAM_IMG_A=16'h100;
          else RAM_IMG_A=16'h101;
        end
        
        else if (n==255) begin
          if (i==0) RAM_IMG_A=16'hFE;
          else if (i==1) RAM_IMG_A=16'hFF;      
          else if (i==2) RAM_IMG_A=16'h1FE;
          else RAM_IMG_A=16'h1FF;
        end

        else if (n==65790) begin
          if (i==0) RAM_IMG_A=16'hFE00;
          else if (i==1) RAM_IMG_A=16'hFE01;      
          else if (i==2) RAM_IMG_A=16'hFF00;
          else RAM_IMG_A=16'h1FF01;
        end

        else if (n==66045) begin
          if (i==0) RAM_IMG_A=16'hFEFE;
          else if (i==1) RAM_IMG_A=16'hFEFF;      
          else if (i==2) RAM_IMG_A=16'hFFFE;
          else RAM_IMG_A=16'hFFFF;
        end

        else if (n>0&&n<255) begin
          if (j==0) RAM_IMG_A=c1;
          else if (j==1) RAM_IMG_A=c1+1;      
          else if (j==2) RAM_IMG_A=c1+2;
          else if (j==3) RAM_IMG_A=c1+256;
          else if (j==4) RAM_IMG_A=c1+257;      
          else RAM_IMG_A=c1+258;
        end

        else if (n%258==0&&n!=0&&n!=65790)begin
          if (k==0) RAM_IMG_A=c2;
          else if (k==1) RAM_IMG_A=c2+1;      
          else if (k==2) RAM_IMG_A=c2+256;
          else if (k==3) RAM_IMG_A=c2+257;
          else if (k==4) RAM_IMG_A=c2+512;      
          else RAM_IMG_A=c2+513;
        end

        else if (n%258==255&&n!=255&&n!=66045) begin
          if (d==0) RAM_IMG_A=c3;
          else if (d==1) RAM_IMG_A=c3+1;      
          else if (d==2) RAM_IMG_A=c3+256;
          else if (d==3) RAM_IMG_A=c3+257;
          else if (d==4) RAM_IMG_A=c3+512;      
          else RAM_IMG_A=c3+513;  
        end

        else if (n>65790&&n<66045) begin
          if (b==0) RAM_IMG_A=c4;
          else if (b==1) RAM_IMG_A=c4+1;      
          else if (b==2) RAM_IMG_A=c4+2;
          else if (b==3) RAM_IMG_A=c4+256;
          else if (b==4) RAM_IMG_A=c4+257;      
          else RAM_IMG_A=c4+258;
        end

        else begin// 259~66146
          if (a==0) RAM_IMG_A=c;
          else if (a==1) RAM_IMG_A=c+1;      
          else if (a==2) RAM_IMG_A=c+2;
          else if (a==3) RAM_IMG_A=c+256;
          else if (a==4) RAM_IMG_A=c+257;      
          else if (a==5) RAM_IMG_A=c+258;
          else if (a==6) RAM_IMG_A=c+512;
          else if (a==7) RAM_IMG_A=c+513;
          else  RAM_IMG_A=c+514;
        end  
    end

    WAIT:begin
    end

    DATA_i:begin //n=0,n=255,n=65790,n=66045
        data[4]=8'h0;
        data[5]=8'h0;
        data[6]=8'h0;
        data[7]=8'h0;
        data[8]=8'h0;  
        data[i]=RAM_IMG_Q;
        i=i+1;
    end

    DATA_j:begin //n>0&&n<255
        data[6]=8'h0;
        data[7]=8'h0;
        data[8]=8'h0; 
        data[j]=RAM_IMG_Q;
        j=j+1; 
    end

     DATA_k:begin //%258=0
        data[6]=8'h0;
        data[7]=8'h0;
        data[8]=8'h0; 
        data[k]=RAM_IMG_Q;
        k=k+1; 
    end

    DATA_a:begin //259~66416
        data[a]=RAM_IMG_Q;
        a=a+1; 
    end

    DATA_b:begin//n>65790&&n<66045
        data[6]=8'h0;
        data[7]=8'h0;
        data[8]=8'h0; 
        data[b]=RAM_IMG_Q;
        b=b+1; 
    end

     DATA_d:begin //%258=255
        data[6]=8'h0;
        data[7]=8'h0;
        data[8]=8'h0; 
        data[d]=RAM_IMG_Q;
        d=d+1; 
      end

    SORTING:begin
      RAM_IMG_OE=0;
      if (i>3)begin
        n=(n>=255&&n!=65790)?n+3:n+1;
        i=0;
      end
      else if (j>5) begin
        c1=c1+1;
        n=n+1;
        j=0;
      end 
      else if (k>5) begin     
        c2=c2+256;
        n=n+1;
        k=0;
      end
      else if (a>8) begin
        c=(c%256==253)?c+3:c+1;
        n=n+1;
        a=0;
      end
      else if (b>5) begin
        c4=c4+1;
        b=0;
        n=n+1;
      end
      else begin
        d=0;
        c3=c3+256;
        n=n+3;
      end
   
     if (data[0] >data[1] && data[0] >data[2] && data[0] >data[3] && data[0] >data[4] && data[0] >data[5] && data[0] >data[6] && data[0] >data[7] && data[0] >data[8]) begin
        sortNum9_o = data[0];
        w_8_1 = data[8];
        w_8_2 = data[7];
        w_8_3 = data[6];
        w_8_4 = data[5];
        w_8_5 = data[4];
        w_8_6 = data[3];
        w_8_7 = data[2];
        w_8_8 = data[1];
      end
      else if (data[1] >data[2] && data[1] >data[3] && data[1] >data[4] && data[1] >data[5] && data[1] >data[6] && data[1] >data[7] && data[1] >data[8]) begin
        sortNum9_o = data[1];
        w_8_1 = data[8];
        w_8_2 = data[7];
        w_8_3 = data[6];
        w_8_4 = data[5];
        w_8_5 = data[4];
        w_8_6 = data[3];
        w_8_7 = data[2];
        w_8_8 = data[0];
      end 
      else if (data[2] > data[3] && data[2] > data[4] && data[2] > data[5] && data[2] > data[6] && data[2] > data[7] && data[2] > data[8]) begin
        sortNum9_o = data[2];
        w_8_1 = data[8];
        w_8_2 = data[7];
        w_8_3 = data[6];
        w_8_4 = data[5];
        w_8_5 = data[4];
        w_8_6 = data[3];
        w_8_7 = data[1];
        w_8_8 = data[0];
      end 
      else if (data[3] > data[4] && data[3] > data[5] && data[3] > data[6] && data[3] > data[7] && data[3] > data[8]) begin
        sortNum9_o = data[3];
        w_8_1 = data[8];
        w_8_2 = data[7];
        w_8_3 = data[6];
        w_8_4 = data[5];
        w_8_5 = data[4];
        w_8_6 = data[2];
        w_8_7 = data[1];
        w_8_8 = data[0];
      end 
      else if (data[4] > data[5] && data[4] > data[6] && data[4] > data[7] && data[4] > data[8]) begin
        sortNum9_o = data[4];
        w_8_1 = data[8];
        w_8_2 = data[7];
        w_8_3 = data[6];
        w_8_4 = data[5];
        w_8_5 = data[3];
        w_8_6 = data[2];
        w_8_7 = data[1];
        w_8_8 = data[0];
      end 
      else if (data[5] > data[6] && data[5] > data[7] && data[5] > data[8]) begin
        sortNum9_o = data[5];
        w_8_1 = data[8];
        w_8_2 = data[7];
        w_8_3 = data[6];
        w_8_4 = data[4];
        w_8_5 = data[3];
        w_8_6 = data[2];
        w_8_7 = data[1];
        w_8_8 = data[0];
      end 
      else if (data[6] > data[7] && data[6] > data[8]) begin
        sortNum9_o = data[6];
        w_8_1 = data[8];
        w_8_2 = data[7];
        w_8_3 = data[5];
        w_8_4 = data[4];
        w_8_5 = data[3];
        w_8_6 = data[2];
        w_8_7 = data[1];
        w_8_8 = data[0];
      end 
      else if (data[7] > data[8]) begin
        sortNum9_o = data[7];
        w_8_1 = data[8];
        w_8_2 = data[6];
        w_8_3 = data[5];
        w_8_4 = data[4];
        w_8_5 = data[3];
        w_8_6 = data[2];
        w_8_7 = data[1];
        w_8_8 = data[0];
      end 
      else begin
        sortNum9_o = data[8];
        w_8_1 = data[7];
        w_8_2 = data[6];
        w_8_3 = data[5];
        w_8_4 = data[4];
        w_8_5 = data[3];
        w_8_6 = data[2];
        w_8_7 = data[1];
        w_8_8 = data[0];
      end

        //sortNum8_o
      if (w_8_8 > w_8_7 && w_8_8 > w_8_6 && w_8_8 > w_8_5 && w_8_8 > w_8_4 && w_8_8 > w_8_3 && w_8_8 > w_8_2 && w_8_8 > w_8_1) begin
        sortNum8_o = w_8_8;
        w_7_1 = w_8_1;
        w_7_2 = w_8_2;
        w_7_3 = w_8_3;
        w_7_4 = w_8_4;
        w_7_5 = w_8_5;
        w_7_6 = w_8_6;
        w_7_7 = w_8_7;
      end 
      else if (w_8_7 > w_8_6 && w_8_7 > w_8_5 && w_8_7 > w_8_4 && w_8_7 > w_8_3 && w_8_7 > w_8_2 && w_8_7 > w_8_1) begin
        sortNum8_o = w_8_7;
        w_7_1 = w_8_1;
        w_7_2 = w_8_2;
        w_7_3 = w_8_3;
        w_7_4 = w_8_4;
        w_7_5 = w_8_5;
        w_7_6 = w_8_6;
        w_7_7 = w_8_8;
      end 
      else if (w_8_6 > w_8_5 && w_8_6 > w_8_4 && w_8_6 > w_8_3 && w_8_6 > w_8_2 && w_8_6 > w_8_1) begin
        sortNum8_o = w_8_6;
        w_7_1 = w_8_1;
        w_7_2 = w_8_2;
        w_7_3 = w_8_3;
        w_7_4 = w_8_4;
        w_7_5 = w_8_5;
        w_7_6 = w_8_7;
        w_7_7 = w_8_8;
      end 
      else if (w_8_5 > w_8_4 && w_8_5 > w_8_3 && w_8_5 > w_8_2 && w_8_5 > w_8_1) begin
        sortNum8_o = w_8_5;
        w_7_1 = w_8_1;
        w_7_2 = w_8_2;
        w_7_3 = w_8_3;
        w_7_4 = w_8_4;
        w_7_5 = w_8_6;
        w_7_6 = w_8_7;
        w_7_7 = w_8_8;
      end 
      else if (w_8_4 > w_8_3 && w_8_4 > w_8_2 && w_8_4 > w_8_1) begin
        sortNum8_o = w_8_4;
        w_7_1 = w_8_1;
        w_7_2 = w_8_2;
        w_7_3 = w_8_3;
        w_7_4 = w_8_5;
        w_7_5 = w_8_6;
        w_7_6 = w_8_7;
        w_7_7 = w_8_8;
      end 
      else if (w_8_3 > w_8_2 && w_8_3 > w_8_1) begin
        sortNum8_o = w_8_3;
        w_7_1 = w_8_1;
        w_7_2 = w_8_2;
        w_7_3 = w_8_4;
        w_7_4 = w_8_5;
        w_7_5 = w_8_6;
        w_7_6 = w_8_7;
        w_7_7 = w_8_8;
      end 
      else if (w_8_2 > w_8_1) begin
        sortNum8_o = w_8_2;
        w_7_1 = w_8_1;
        w_7_2 = w_8_3;
        w_7_3 = w_8_4;
        w_7_4 = w_8_5;
        w_7_5 = w_8_6;
        w_7_6 = w_8_7;
        w_7_7 = w_8_8;
      end 
      else begin
        sortNum8_o = w_8_1;
        w_7_1 = w_8_2;
        w_7_2 = w_8_3;
        w_7_3 = w_8_4;
        w_7_4 = w_8_5;
        w_7_5 = w_8_6;
        w_7_6 = w_8_7;
        w_7_7 = w_8_8;
      end

        //sortNum7_o
      if (w_7_7 > w_7_6 && w_7_7 > w_7_5 && w_7_7 > w_7_4 && w_7_7 > w_7_3 && w_7_7 > w_7_2 && w_7_7 > w_7_1) begin
        sortNum7_o = w_7_7;
        w_6_1 = w_7_1;
        w_6_2 = w_7_2;
        w_6_3 = w_7_3;
        w_6_4 = w_7_4;
        w_6_5 = w_7_5;
        w_6_6 = w_7_6;
      end 
      else if (w_7_6 > w_7_5 && w_7_6 > w_7_4 && w_7_6 > w_7_3 && w_7_6 > w_7_2 && w_7_6 > w_7_1) begin
        sortNum7_o = w_7_6;
        w_6_1 = w_7_1;
        w_6_2 = w_7_2;
        w_6_3 = w_7_3;
        w_6_4 = w_7_4;
        w_6_5 = w_7_5;
        w_6_6 = w_7_7;
      end 
      else if (w_7_5 > w_7_4 && w_7_5 > w_7_3 && w_7_5 > w_7_2 && w_7_5 > w_7_1) begin
        sortNum7_o = w_7_5;
        w_6_1 = w_7_1;
        w_6_2 = w_7_2;
        w_6_3 = w_7_3;
        w_6_4 = w_7_4;
        w_6_5 = w_7_6;
        w_6_6 = w_7_7;
      end 
      else if (w_7_4 > w_7_3 && w_7_4 > w_7_2 && w_7_4 > w_7_1) begin
        sortNum7_o = w_7_4;
        w_6_1 = w_7_1;
        w_6_2 = w_7_2;
        w_6_3 = w_7_3;
        w_6_4 = w_7_5;
        w_6_5 = w_7_6;
        w_6_6 = w_7_7;
      end 
      else if (w_7_3 > w_7_2 && w_7_3 > w_7_1) begin
        sortNum7_o = w_7_3;
        w_6_1 = w_7_1;
        w_6_2 = w_7_2;
        w_6_3 = w_7_4;
        w_6_4 = w_7_5;
        w_6_5 = w_7_6;
        w_6_6 = w_7_7;
      end 
      else if (w_7_2 > w_7_1) begin
        sortNum7_o = w_7_2;
        w_6_1 = w_7_1;
        w_6_2 = w_7_3;
        w_6_3 = w_7_4;
        w_6_4 = w_7_5;
        w_6_5 = w_7_6;
        w_6_6 = w_7_7;
      end 
      else begin
        sortNum7_o = w_7_1;
        w_6_1 = w_7_2;
        w_6_2 = w_7_3;
        w_6_3 = w_7_4;
        w_6_4 = w_7_5;
        w_6_5 = w_7_6;
        w_6_6 = w_7_7;
      end

        //sortNum6_o
      if (w_6_6 > w_6_5 && w_6_6 > w_6_4 && w_6_6 > w_6_3 && w_6_6 > w_6_2 && w_6_6 > w_6_1) begin
        sortNum6_o = w_6_6;
        w_5_1 = w_6_1;
        w_5_2 = w_6_2;
        w_5_3 = w_6_3;
        w_5_4 = w_6_4;
        w_5_5 = w_6_5;
      end 
      else if (w_6_5 > w_6_4 && w_6_5 > w_6_3 && w_6_5 > w_6_2 && w_6_5 > w_6_1) begin
        sortNum6_o = w_6_5;
        w_5_1 = w_6_1;
        w_5_2 = w_6_2;
        w_5_3 = w_6_3;
        w_5_4 = w_6_4;
        w_5_5 = w_6_6;
      end 
      else if (w_6_4 > w_6_3 && w_6_4 > w_6_2 && w_6_4 > w_6_1) begin
        sortNum6_o = w_6_4;
        w_5_1 = w_6_1;
        w_5_2 = w_6_2;
        w_5_3 = w_6_3;
        w_5_4 = w_6_5;
        w_5_5 = w_6_6;
      end 
      else if (w_6_3 > w_6_2 && w_6_3 > w_6_1) begin
        sortNum6_o = w_6_3;
        w_5_1 = w_6_1;
        w_5_2 = w_6_2;
        w_5_3 = w_6_4;
        w_5_4 = w_6_5;
        w_5_5 = w_6_6;
      end 
      else if (w_6_2 > w_6_1) begin
        sortNum6_o = w_6_2;
        w_5_1 = w_6_1;
        w_5_2 = w_6_3;
        w_5_3 = w_6_4;
        w_5_4 = w_6_5;
        w_5_5 = w_6_6;
      end 
      else begin
        sortNum6_o = w_6_1;
        w_5_1 = w_6_2;
        w_5_2 = w_6_3;
        w_5_3 = w_6_4;
        w_5_4 = w_6_5;
        w_5_5 = w_6_6;
      end

        //sortNum5_o
      if (w_5_5 > w_5_4 && w_5_5 > w_5_3 && w_5_5 > w_5_2 && w_5_5 > w_5_1) begin
        sortNum5_o = w_5_5;
        w_4_1 = w_5_1;
        w_4_2 = w_5_2;
        w_4_3 = w_5_3;
        w_4_4 = w_5_4;
      end 
      else if (w_5_4 > w_5_3 && w_5_4 > w_5_2 && w_5_4 > w_5_1) begin
        sortNum5_o = w_5_4;
        w_4_1 = w_5_1;
        w_4_2 = w_5_2;
        w_4_3 = w_5_3;
        w_4_4 = w_5_5;
      end 
      else if (w_5_3 > w_5_2 && w_5_3 > w_5_1) begin
        sortNum5_o = w_5_3;
        w_4_1 = w_5_1;
        w_4_2 = w_5_2;
        w_4_3 = w_5_4;
        w_4_4 = w_5_5;
      end 
      else if (w_5_2 > w_5_1) begin
        sortNum5_o = w_5_2;
        w_4_1 = w_5_1;
        w_4_2 = w_5_3;
        w_4_3 = w_5_4;
        w_4_4 = w_5_5;
      end 
      else begin
        sortNum5_o = w_5_1;
        w_4_1 = w_5_2;
        w_4_2 = w_5_3;
        w_4_3 = w_5_4;
        w_4_4 = w_5_5;
      end

        //sortNum4_o
      if (w_4_4 > w_4_3 && w_4_4 > w_4_2 && w_4_4 > w_4_1) begin
        sortNum4_o = w_4_4;
        w_3_1 = w_4_1;
        w_3_2 = w_4_2;
        w_3_3 = w_4_3;
      end 
      else if (w_4_3 > w_4_2 && w_4_3 > w_4_1) begin
        sortNum4_o = w_4_3;
        w_3_1 = w_4_1;
        w_3_2 = w_4_2;
        w_3_3 = w_4_4;
      end 
      else if (w_4_2 > w_4_1) begin
        sortNum4_o = w_4_2;
        w_3_1 = w_4_1;
        w_3_2 = w_4_3;
        w_3_3 = w_4_4;
      end 
      else begin
        sortNum4_o = w_4_1;
        w_3_1 = w_4_2;
        w_3_2 = w_4_3;
        w_3_3 = w_4_4;
      end

        //sortNum3_o
      if (w_3_3 > w_3_2 && w_3_3 > w_3_1) begin
        sortNum3_o = w_3_3;
        w_2_1 = w_3_1;
        w_2_2 = w_3_2;
      end 
      else if (w_3_2 > w_3_1) begin
        sortNum3_o = w_3_2;
        w_2_1 = w_3_1;
        w_2_2 = w_3_3;
      end 
      else begin
        sortNum3_o = w_3_1;
        w_2_1 = w_3_2;
        w_2_2 = w_3_3;
      end

        //sortNum2_o sortNum1_o
      if (w_2_2 > w_2_1) begin
        sortNum2_o = w_2_2;
        sortNum1_o = w_2_1;
      end 
      else begin
        sortNum2_o = w_2_1;
        sortNum1_o = w_2_2;
      end
    end

    RESULT:begin 
      RAM_OUT_WE=1;
      RAM_OUT_A=r;
      RAM_OUT_D=sortNum5_o;  
      r=r+1;  
    end

    default:begin
    end 

  endcase  
end

endmodule
