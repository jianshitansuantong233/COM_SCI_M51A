// Code your design here
// Code your design here
`timescale 1ns / 1ps
`define X_TILE 1'b1
`define O_TILE 1'b0
/*
* define statements for game status ascii output
 */
`define ASCII_X 8'b01011000
`define ASCII_O 8'b01001111
`define ASCII_C 8'b01000011
`define ASCII_E 8'b01000101
`define ASCII_NONE 8'b01101110
/* 
* Optional: (you may use if you want)
* Game states 
 */
`define GAME_ST_START 4'b0000 
`define GAME_ST_TURN_X 4'b0001 
`define GAME_ST_ERR_X 4'b0010
`define GAME_ST_CHKV_X 4'b0011
`define GAME_ST_CHKW_X 4'b0100
`define GAME_ST_WIN_X 4'b0101
`define GAME_ST_TURN_O 4'b0110
`define GAME_ST_ERR_O 4'b0111
`define GAME_ST_CHKV_O 4'b1000
`define GAME_ST_CHKW_O 4'b1001
`define GAME_ST_WIN_O 4'b1010
`define GAME_ST_CATS 4'b1011
/* Suggestions
* Create a module to check for a validity of a move
* Create modules to check for a victory in the treys
   */
module tictactoe(turnX, turnO, occ_pos, occ_square, occ_player, game_st_ascii, reset, clk, flash_clk, sel_pos, buttonX, buttonO);

    output turnX;
    output turnO;
    output [8:0] occ_pos, occ_square, occ_player;
    output [7:0] game_st_ascii;

    input reset, clk, flash_clk;
    input [8:0] sel_pos;
    input buttonX, buttonO;

/* 
* occ_square states if there's a tile in this square or not 
* occ_player states which type of tile is in the square 
* game_state is the 4 bit curent state;
* occ_pos is the board with flashing 
   */
    reg[1:0] fl_counter;
    reg[8:0] sel;
    reg [8:0] occ_square;
    reg [8:0] occ_player;
    reg [3:0] game_state;
    reg turnX;
    reg turnO;
    reg [7:0] game_st_ascii;
    reg [8:0] occ_pos;
    reg [2:0] w;
    reg [3:0] nx_game_state;
    integer i;
/*
* Registers
*  -- game_state register is provided to get you started
   */ 
    always @(posedge clk or reset) begin
        $display("{{{");
        if(reset) game_state<=`GAME_ST_START;
        else game_state <= nx_game_state;
    end
    always @(*) begin
        case(game_state)
            `GAME_ST_START:begin
                nx_game_state= `GAME_ST_TURN_X;
                turnX=1'b 0;
                turnO=1'b 0;
                occ_pos=9'b 000000000; 
                occ_square=9'b 000000000;
                occ_player=9'b 000000000;
                game_st_ascii=`ASCII_NONE;
            end
            
            `GAME_ST_TURN_X:begin
                sel=sel_pos;
                $display("((");
                turnX=1'b 1;
                turnO=1'b 0;
                if(buttonO) begin
                    $display("**");
                    game_st_ascii=`ASCII_E;
                    nx_game_state=`GAME_ST_ERR_X;
                end else if(buttonX) begin
                    game_st_ascii=`ASCII_NONE;
                    nx_game_state=`GAME_ST_CHKV_X;
                end else begin
                    game_st_ascii=`ASCII_NONE;
                    nx_game_state=`GAME_ST_TURN_X;
                end
                
            end

            `GAME_ST_CHKV_X: begin 
                $display("))");
                turnX=1'b 0;
                turnO=1'b 0;
                i=8;
                while(i>=0) begin
                    if(sel[i]&&occ_square[i]||game_st_ascii==`ASCII_E) begin
                        $display(i);
                        $display(i);
                        game_st_ascii=`ASCII_E;
                        nx_game_state=`GAME_ST_ERR_X;
                    end
                    i=i-1;
                end
                if(game_st_ascii!=`ASCII_E) game_st_ascii=`ASCII_NONE;
                i=8;
                while(i>=0&&game_st_ascii!=`ASCII_E) begin
                    if(sel_pos[i]==1'b 1) begin
                        occ_square[i]=1'b 1;
                        occ_player[i]=1'b 1;
                        occ_pos[i]=1'b 1;
                    end
                    i=i-1;
                end
                assign w[2]=(game_st_ascii!=`ASCII_E)&&
                      ((occ_player[8]&&occ_square[8]&&occ_player[5]&&occ_square[5]&&occ_square[2]&&occ_player[2])||
                       (occ_player[7]&&occ_square[7]&&occ_player[4]&&occ_square[4]&&occ_square[1]&&occ_player[1])||
                       (occ_player[6]&&occ_square[6]&&occ_player[3]&&occ_square[3]&&occ_square[0]&&occ_player[0])||
                       (occ_player[8]&&occ_square[8]&&occ_player[7]&&occ_square[7]&&occ_square[6]&&occ_player[6])||
                       (occ_player[5]&&occ_square[5]&&occ_player[4]&&occ_square[4]&&occ_square[3]&&occ_player[3])||
                       (occ_player[2]&&occ_square[2]&&occ_player[1]&&occ_square[1]&&occ_square[0]&&occ_player[0])||
                       (occ_player[8]&&occ_square[8]&&occ_player[4]&&occ_square[4]&&occ_square[0]&&occ_player[0])||
                       (occ_player[6]&&occ_square[6]&&occ_player[4]&&occ_square[4]&&occ_square[2]&&occ_player[2]));
                assign w[0]=(game_st_ascii!=`ASCII_E)&&(!w[1]&&!w[2])&&occ_square[0]&&occ_square[1]&&occ_square[2]
                        &&occ_square[3]&&occ_square[4]&&occ_square[5]&&occ_square[6]&&occ_square[7]&&occ_square[8];
                if(w[2]) begin
                    turnX=1'b 1;
                    turnO=1'b 0;
                    nx_game_state=`GAME_ST_WIN_X;
                    game_st_ascii=`ASCII_X;
                end else if (w[0])begin
                    turnX=1'b 1;
                    turnO=1'b 0;
                    nx_game_state=`GAME_ST_CATS;
                    game_st_ascii=`ASCII_C;
                end else if(game_st_ascii==`ASCII_E)begin
                    turnX=1'b 1;
                    turnO=1'b 0;
                    game_state=`GAME_ST_ERR_X;
                end else begin
                    nx_game_state=`GAME_ST_TURN_O;
                    game_st_ascii=`ASCII_NONE;
                end
                sel=9'b 000000000;
            end
            `GAME_ST_ERR_X: begin
                $display("EX");
                game_st_ascii=`ASCII_E;
                if(buttonX&&turnX) begin
                    nx_game_state=`GAME_ST_CHKV_X;
                    game_st_ascii=`ASCII_NONE;
                    sel=sel_pos;
                end else nx_game_state=`GAME_ST_ERR_X;
            end
            `GAME_ST_WIN_X:begin
            $display("WX");
                nx_game_state=`GAME_ST_WIN_X;
                game_st_ascii=`ASCII_X;
            end

            `GAME_ST_TURN_O:begin
                sel=sel_pos;
                $display("[[");
                turnX=1'b0;
                turnO=1'b1;
                if(buttonX) begin
                    $display("OO");
                    game_st_ascii=`ASCII_E;
                    nx_game_state=`GAME_ST_ERR_O;
                end else if(buttonO) begin
                    game_st_ascii=`ASCII_NONE;
                    nx_game_state=`GAME_ST_CHKV_O;
                end else begin
                    game_st_ascii=`ASCII_NONE;
                    nx_game_state=`GAME_ST_TURN_O;
                end
            end

            `GAME_ST_CHKV_O:begin
                turnX=1'b 0;
                turnO=1'b 0;
                $display("]]");
                i=8;
                while(i>=0) begin
                    if(sel[i]&&occ_square[i]||game_st_ascii==`ASCII_E) begin
                        game_st_ascii=`ASCII_E;
                        turnX=1'b 0;
                        turnO=1'b 1;
                        nx_game_state=`GAME_ST_ERR_O;
                    end
                    i=i-1;
                end
                if(game_st_ascii!=`ASCII_E) game_st_ascii=`ASCII_NONE;
                    i=8;
                    if(game_st_ascii!=`ASCII_E) begin
                        while(i>=0) begin
                           if(sel_pos[i]==1) begin
                               occ_square[i]=1;
                               occ_player[i]=0;
                               //occ_pos[i]=occ_pos[i];
                           end
                           i=i-1;
                        end
                    end
                    assign w[1]=(game_st_ascii!=`ASCII_E)&&
                      ((!occ_player[8]&&occ_square[8]&&!occ_player[5]&&occ_square[5]&&occ_square[2]&&!occ_player[2])||
                      (!occ_player[7]&&occ_square[7]&&!occ_player[4]&&occ_square[4]&&occ_square[1]&&!occ_player[1])||
                      (!occ_player[6]&&occ_square[6]&&!occ_player[3]&&occ_square[3]&&occ_square[0]&&!occ_player[0])||
                      (!occ_player[8]&&occ_square[8]&&!occ_player[7]&&occ_square[7]&&occ_square[6]&&!occ_player[6])||
                      (!occ_player[5]&&occ_square[5]&&!occ_player[4]&&occ_square[4]&&occ_square[3]&&!occ_player[3])||
                      (!occ_player[2]&&occ_square[2]&&!occ_player[1]&&occ_square[1]&&occ_square[0]&&!occ_player[0])||
                      (!occ_player[8]&&occ_square[8]&&!occ_player[4]&&occ_square[4]&&occ_square[0]&&!occ_player[0])||
                      (!occ_player[6]&&occ_square[6]&&!occ_player[4]&&occ_square[4]&&occ_square[2]&&!occ_player[2]));
                    assign w[0]=(game_st_ascii!=`ASCII_E)&&(!w[1]&&!w[2])&&occ_square[0]&&occ_square[1]&&occ_square[2]
                        &&occ_square[3]&&occ_square[4]&&occ_square[5]&&occ_square[6]&&occ_square[7]&&occ_square[8];
                    if(w[1]) begin
                        turnX=1'b 0;
                        turnO=1'b 1;
                        nx_game_state=`GAME_ST_WIN_O;
                        game_st_ascii=`ASCII_O;
                    end else if (w[0])begin
                        turnX=1'b 0;
                        turnO=1'b 1;
                        nx_game_state=`GAME_ST_CATS;
                        game_st_ascii=`ASCII_C;
                    end else if(game_st_ascii==`ASCII_E)begin
                        $display("OO");
                        turnX=1'b 0;
                        turnO=1'b 1;
                        nx_game_state=`GAME_ST_ERR_O;
                    end else begin
                        nx_game_state=`GAME_ST_TURN_X;
                        game_st_ascii=`ASCII_NONE;
                    end
                    sel=9'b 000000000;
                end
                `GAME_ST_ERR_O:begin
                $display("EO");
                    game_st_ascii=`ASCII_E;
                    if(buttonO&&turnO) begin
                        nx_game_state=`GAME_ST_CHKV_O;
                        game_st_ascii=`ASCII_NONE;
                        sel=sel_pos;
                    end else nx_game_state=`GAME_ST_ERR_O;
                end
                `GAME_ST_WIN_O:begin
                $display("WO");
                    nx_game_state=`GAME_ST_WIN_O;
                    game_st_ascii=`ASCII_O;
                end
                `GAME_ST_CATS: begin
                    game_st_ascii=`ASCII_C;
                end
            endcase
        end
        always@(posedge flash_clk)begin
            case(game_state)
                `GAME_ST_WIN_X:begin
                    nx_game_state=`GAME_ST_WIN_X;
                    game_st_ascii=`ASCII_X;
                    if((occ_player[8]&&occ_square[8]&&occ_player[5]&&occ_square[5]&&occ_square[2]&&occ_player[2])) begin
                        occ_pos[8]=!occ_pos[8];
                        occ_pos[5]=!occ_pos[5];
                        occ_pos[2]=!occ_pos[2];
                    end else if(occ_player[7]&&occ_square[7]&&occ_player[4]&&occ_square[4]&&occ_square[1]&&occ_player[1]) begin
                        occ_pos[7]=!occ_pos[7];
                        occ_pos[4]=!occ_pos[4];
                        occ_pos[1]=!occ_pos[1];
                    end else if(occ_player[6]&&occ_square[6]&&occ_player[3]&&occ_square[3]&&occ_square[0]&&occ_player[0]) begin
                        occ_pos[6]=!occ_pos[6];
                        occ_pos[3]=~occ_pos[3];
                        occ_pos[0]=~occ_pos[0];
                    end else if(occ_player[8]&&occ_square[8]&&occ_player[7]&&occ_square[7]&&occ_square[6]&&occ_player[6]) begin
                        occ_pos[8]=~occ_pos[8];
                        occ_pos[7]=~occ_pos[7];
                        occ_pos[6]=~occ_pos[6];
                    end else if(occ_player[5]&&occ_square[5]&&occ_player[4]&&occ_square[4]&&occ_square[3]&&occ_player[3]) begin
                        occ_pos[5]=~occ_pos[5];
                        occ_pos[4]=~occ_pos[4];
                        occ_pos[3]=~occ_pos[3];
                    end else if(occ_player[2]&&occ_square[2]&&occ_player[1]&&occ_square[1]&&occ_square[0]&&occ_player[0]) begin
                        occ_pos[2]=~occ_pos[2];
                        occ_pos[1]=~occ_pos[1];
                        occ_pos[0]=~occ_pos[0];
                    end else if(occ_player[8]&&occ_square[8]&&occ_player[4]&&occ_square[4]&&occ_square[0]&&occ_player[0]) begin
                        occ_pos[8]=~occ_pos[8];
                        occ_pos[4]=~occ_pos[4];
                        occ_pos[0]=~occ_pos[0];
                    end else begin
                        occ_pos[6]=~occ_pos[6];
                        occ_pos[4]=~occ_pos[4];
                        occ_pos[2]=~occ_pos[2];
                    end
                    i=8;
                    while(i>=0) begin
                        if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                           occ_pos[i]=~occ_pos[i];
                       end
                       i=i-1;
                   end
                   if(fl_counter[1]) fl_counter=2'b 00;
                   else fl_counter=fl_counter+1;
                end
                
                `GAME_ST_ERR_O:begin 
                    i=8;
                    while(i>=0) begin
                        if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                            occ_pos[i]=~occ_pos[i];
                        end
                        i=i-1;
                    end
                    if(fl_counter[1]) fl_counter=2'b 00;
                    else fl_counter=fl_counter+1;
                end
                `GAME_ST_TURN_X:begin 
                    i=8;
                    while(i>=0) begin
                        if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                            occ_pos[i]=~occ_pos[i];
                        end
                        i=i-1;
                    end
                    if(fl_counter[1]) fl_counter=2'b 00;
                    else fl_counter=fl_counter+1;
                end
                `GAME_ST_TURN_O:begin 
                    i=8;
                    while(i>=0) begin
                        if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                            occ_pos[i]=~occ_pos[i];
                        end
                        i=i-1;
                    end
                    if(fl_counter[1]) fl_counter=2'b 00;
                    else fl_counter=fl_counter+1;
                end
                `GAME_ST_ERR_X:begin
                    i=8;
                    while(i>=0) begin
                        if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                            occ_pos[i]=~occ_pos[i];
                        end
                        i=i-1;
                    end
                    if(fl_counter[1]) fl_counter=2'b 00;
                    else fl_counter=fl_counter+1;
                end
                `GAME_ST_CHKV_O:begin
                    i=8;
                    while(i>=0) begin
                        if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                            occ_pos[i]=~occ_pos[i];
                        end
                        i=i-1;
                    end
                    if(fl_counter[1]) fl_counter=2'b 00;
                    else fl_counter=fl_counter+1;
                end
                `GAME_ST_CHKV_X:begin
                    i=8;
                    while(i>=0) begin
                        if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                            occ_pos[i]=~occ_pos[i];
                        end
                        i=i-1;
                    end
                    if(fl_counter[1]) fl_counter=2'b 00;
                    else fl_counter=fl_counter+1;
                end
                `GAME_ST_WIN_O:begin
                    nx_game_state=`GAME_ST_WIN_O;
                    game_st_ascii=`ASCII_O;
                    if((!occ_player[8]&&occ_square[8]&&!occ_player[5]&&occ_square[5]&&occ_square[2]&&!occ_player[2])) begin
                        occ_pos[8]=~occ_pos[8];
                        occ_pos[5]=~occ_pos[5];
                        occ_pos[2]=~occ_pos[2];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&&i!=8&&i!=5&&i!=2&&fl_counter[1]) begin
                               occ_pos[i]=~occ_pos[i];
                           end
                           i=i-1;
                       end
                       if(fl_counter[1]) fl_counter=2'b 00;
                       else fl_counter=fl_counter+1;
                    end else if(!occ_player[7]&&occ_square[7]&&!occ_player[4]&&occ_square[4]&&occ_square[1]&&!occ_player[1]) begin
                        occ_pos[7]=~occ_pos[7];
                        occ_pos[4]=~occ_pos[4];
                        occ_pos[1]=~occ_pos[1];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&&i!=7&&i!=4&&i!=1&&fl_counter[1]) begin
                                occ_pos[i]=~occ_pos[i];
                            end
                            i=i-1;
                        end
                        if(fl_counter[1]) fl_counter=2'b 00;
                        else fl_counter=fl_counter+1;
                    end else if(!occ_player[6]&&occ_square[6]&&!occ_player[3]&&occ_square[3]&&occ_square[0]&&!occ_player[0]) begin
                        occ_pos[6]=~occ_pos[6];
                        occ_pos[3]=~occ_pos[3];
                        occ_pos[0]=~occ_pos[0];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&i!=6&&i!=3&&i!=0&&fl_counter[1]) begin
                                occ_pos[i]=~occ_pos[i];
                            end
                            i=i-1;
                        end
                        if(fl_counter[1]) fl_counter=2'b 00;
                        else fl_counter=fl_counter+1;
                    end else if(!occ_player[8]&&occ_square[8]&&!occ_player[7]&&occ_square[7]&&occ_square[6]&&!occ_player[6]) begin
                        occ_pos[8]=~occ_pos[8];
                        occ_pos[7]=~occ_pos[7];
                        occ_pos[6]=~occ_pos[6];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&&i!=8&&i!=7&&i!=6&&fl_counter[1]) begin
                                occ_pos[i]=~occ_pos[i];
                            end
                            i=i-1;
                        end
                        if(fl_counter[1]) fl_counter=2'b 00;
                        else fl_counter=fl_counter+1;
                    end else if(!occ_player[5]&&occ_square[5]&&!occ_player[4]&&occ_square[4]&&occ_square[3]&&!occ_player[3]) begin
                        occ_pos[5]=~occ_pos[5];
                        occ_pos[4]=~occ_pos[4];
                        occ_pos[3]=~occ_pos[3];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&&i!=5&&i!=4&&i!=3&&fl_counter[1]) begin
                                occ_pos[i]=~occ_pos[i];
                            end
                            i=i-1;
                        end
                        if(fl_counter[1]) fl_counter=2'b 00;
                        else fl_counter=fl_counter+1;
                    end else if(!occ_player[2]&&occ_square[2]&&!occ_player[1]&&occ_square[1]&&occ_square[0]&&!occ_player[0]) begin
                        occ_pos[2]=~occ_pos[2];
                        occ_pos[1]=~occ_pos[1];
                        occ_pos[0]=~occ_pos[0];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&&i!=2&&i!=1&&i!=0&&fl_counter[1]) begin
                                occ_pos[i]=~occ_pos[i];
                            end
                            i=i-1;
                        end
                        if(fl_counter[1]) fl_counter=2'b 00;
                        else fl_counter=fl_counter+1;
                    end else if(!occ_player[8]&&occ_square[8]&&!occ_player[4]&&occ_square[4]&&occ_square[0]&&!occ_player[0]) begin
                        occ_pos[8]=~occ_pos[8];
                        occ_pos[4]=~occ_pos[4];
                        occ_pos[0]=~occ_pos[0];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&&i!=8&&i!=4&&i!=0&&fl_counter[1]) begin
                                occ_pos[i]=~occ_pos[i];
                            end
                            i=i-1;
                        end
                        if(fl_counter[1]) fl_counter=2'b 00;
                        else fl_counter=fl_counter+1;
                    end else begin
                        occ_pos[6]=~occ_pos[6];
                        occ_pos[4]=~occ_pos[4];
                        occ_pos[2]=~occ_pos[2];
                        i=8;
                        while(i>=0) begin
                            if(occ_square[i]==1&&occ_player[i]==0&&i!=6&&i!=4&&i!=2&&fl_counter[1]) begin
                                occ_pos[i]=~occ_pos[i];
                            end
                            i=i-1;
                        end
                        if(fl_counter[1]) fl_counter=2'b 00;
                        else fl_counter=fl_counter+1;
                    end
                end
                `GAME_ST_CATS:begin
                i=8;
                while(i>=0) begin
                    if(occ_square[i]==1&&occ_player[i]==0&&fl_counter[1]) begin
                       occ_pos[i]=~occ_pos[i];
                   end
                   i=i-1;
               end
               if(fl_counter[1]) fl_counter=2'b 00;
               else fl_counter=fl_counter+1;
            end
        endcase
    end
endmodule
                                                                                                                                                                                                                                                                                                 
