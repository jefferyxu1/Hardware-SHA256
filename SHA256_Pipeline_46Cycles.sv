/*
A core of SHA-256
Input: clk, reset, d_i, num_zero_i
Output: d_o, original_o, matched_o
Authors: Duy Vuong & Jeffery Xu
*/

`timescale 1ps/1ps
module SHA256_top (clk, reset, d_i, num_zero_i, d_o, original_o, matched_o);
    input logic clk, reset;
    input logic [511:0] d_i;
    input logic [7:0] num_zero_i;
    output logic [255:0] d_o;
    output logic [511:0] original_o; // output plain text
    output logic matched_o;

    parameter [7:0][31:0] h = {
        32'h5be0cd19, 32'h1f83d9ab, 32'h9b05688c, 32'h510e527f,
        32'ha54ff53a, 32'h3c6ef372, 32'hbb67ae85, 32'h6a09e667};

    parameter [63:0][31:0] k = {
        32'hc67178f2, 32'hbef9a3f7, 32'ha4506ceb, 32'h90befffa, 
        32'h8cc70208, 32'h84c87814, 32'h78a5636f, 32'h748f82ee, 
        32'h682e6ff3, 32'h5b9cca4f, 32'h4ed8aa4a, 32'h391c0cb3, 
        32'h34b0bcb5, 32'h2748774c, 32'h1e376c08, 32'h19a4c116, 
        32'h106aa070, 32'hf40e3585, 32'hd6990624, 32'hd192e819, 
        32'hc76c51a3, 32'hc24b8b70, 32'ha81a664b, 32'ha2bfe8a1, 
        32'h92722c85, 32'h81c2c92e, 32'h766a0abb, 32'h650a7354, 
        32'h53380d13, 32'h4d2c6dfc, 32'h2e1b2138, 32'h27b70a85, 
        32'h14292967, 32'h06ca6351, 32'hd5a79147, 32'hc6e00bf3, 
        32'hbf597fc7, 32'hb00327c8, 32'ha831c66d, 32'h983e5152, 
        32'h76f988da, 32'h5cb0a9dc, 32'h4a7484aa, 32'h2de92c6f, 
        32'h240ca1cc, 32'h0fc19dc6, 32'hefbe4786, 32'he49b69c1, 
        32'hc19bf174, 32'h9bdc06a7, 32'h80deb1fe, 32'h72be5d74, 
        32'h550c7dc3, 32'h243185be, 32'h12835b01, 32'hd807aa98, 
        32'hab1c5ed5, 32'h923f82a4, 32'h59f111f1, 32'h3956c25b, 
        32'he9b5dba5, 32'hb5c0fbcf, 32'h71374491, 32'h428a2f98 
    };

    logic [511:0] d_i_buffer;
    logic [12:0][63:0][31:0] w_interconnect;
    logic [31:0][63:0][31:0] w_history_for_compression;
    logic [7:0][31:0] compression_interconnect [31:0];
    logic [31:0] h_final [7:0];
    
    logic [7:0] num_zero_i_buffer;
    logic [7:0] processed_num_zero;
    logic [43:0][7:0] num_zero_interconnect;
    logic [43:0][511:0] original_interconnect;

    logic [255:0] hash_value;
    
    // ---------------------------------------------------------------------------------------------------------------
    // Pre processing
    D_FF #(.WIDTH(512)) d_i_ff (.clk(clk), .reset(reset), .d(d_i), .q(d_i_buffer));
    D_FF #(.WIDTH(8)) num_zero_i_ff (.clk(clk), .reset(reset), .d(num_zero_i), .q(num_zero_i_buffer));
    rippleAdder8 ripple_adder (.A(8'b0), .B(num_zero_i_buffer), .result(processed_num_zero), .sub(1'b1));

    //  --------------------------------------------------------------------------------------------------------------
    // Extension and Compression
    genvar i;

    generate
        for (i = 0; i < 16; i++) begin: eachW16
            assign w_interconnect[0][i] = d_i_buffer[511-i*32:511-i*32-31];
        end
    endgenerate

    generate
        for (i = 16; i < 64; i++) begin: eachW48
            assign w_interconnect[0][i] = 32'b0;
        end
    endgenerate

    extension #(.N(16)) first_extender (.clk(clk), .reset(reset), .w_i(w_interconnect[0][63:0]), .w_o(w_interconnect[1][63:0]), 
                                        .num_zero_i(processed_num_zero), .num_zero_o(num_zero_interconnect[0]), .original_i(d_i_buffer), .original_o(original_interconnect[0]));

    generate
        for (i = 20; i < 64; i+=4) begin: eachExtender
            extension #(.N(i)) extender (.clk(clk), .reset(reset), .w_i(w_interconnect[(i-16)/4][63:0]), .w_o(w_interconnect[(i-16)/4+1][63:0]), 
                                        .num_zero_i(num_zero_interconnect[(i-20)/4]), .num_zero_o(num_zero_interconnect[(i-16)/4]), .original_i(original_interconnect[(i-20)/4]), .original_o(original_interconnect[(i-16)/4]));
        end
    endgenerate

    // Compression
    compression #(.N(0)) first_compressor (.clk(clk), .reset(reset), .in(h), .out_o(compression_interconnect[0]), .k(k[0]), .k1(k[1]), 
                                            .w_i(w_interconnect[12][63:0]), .w_o(w_history_for_compression[0][63:0]),
                                            .num_zero_i(num_zero_interconnect[11]), .num_zero_o(num_zero_interconnect[12]), .original_i(original_interconnect[11]), .original_o(original_interconnect[12]));

    generate
        for (i = 2; i < 64; i+=2) begin: eachCompressor
            compression #(.N(i)) compressor (.clk(clk), .reset(reset), .in(compression_interconnect[i/2-1]), .out_o(compression_interconnect[i/2]), .k(k[i]), .k1(k[i+1]),
                                            .w_i(w_history_for_compression[i/2-1][63:0]), .w_o(w_history_for_compression[i/2][63:0]),
                                            .num_zero_i(num_zero_interconnect[i/2+11]), .num_zero_o(num_zero_interconnect[i/2+12]), .original_i(original_interconnect[i/2+11]), .original_o(original_interconnect[i/2+12]));
        end
    endgenerate
    

    // --------------------------------------------------------------------------------------------------------------
    // Post Processing
    logic matched_q_i;

    generate
        for (i = 0; i < 8; i++) begin: eachFinalSum
            adder final_addition (.a(h[i]), .b(compression_interconnect[31][i]), .sum(h_final[i]));
        end
    endgenerate

    assign hash_value = {h_final[0], h_final[1], h_final[2], h_final[3], h_final[4], h_final[5], h_final[6], h_final[7]};

    compare find_match (.hash_value(hash_value), .shamt(num_zero_interconnect[43]), .matched(matched_q_i));

    D_FF #(.WIDTH(256)) d_o_ff (.clk(clk), .reset(reset), .d(hash_value), .q(d_o));
    D_FF #(.WIDTH(1)) matched_o_ff (.clk(clk), .reset(reset), .d(matched_q_i), .q(matched_o));
    D_FF #(.WIDTH(512)) original_o_ff (.clk(clk), .reset(reset), .d(original_interconnect[43]), .q(original_o));
    
endmodule


module extension #(parameter N = 16) (clk, reset, w_i, w_o, num_zero_i, num_zero_o, original_i, original_o);
    input logic clk, reset;
    input logic [63:0][31:0] w_i;
    input logic [511:0] original_i;
    input logic [7:0] num_zero_i;
    output logic [63:0][31:0] w_o;
    output logic [511:0] original_o;
    output logic [7:0] num_zero_o;

    logic [31:0] s0, s1, temp1, temp2;
    logic [63:0][31:0] w_q_i;

    assign s0 = {w_i[N-15][6:0], w_i[N-15][31:7]} ^ {w_i[N-15][17:0], w_i[N-15][31:18]} ^ {3'b000, w_i[N-15][31:3]};
    assign s1 = {w_i[N-2][16:0], w_i[N-2][31:17]} ^ {w_i[N-2][18:0], w_i[N-2][31:19]} ^ {10'b0000000000, w_i[N-2][31:10]};

    adder Layer1_1 (.a(w_i[N-16]), .b(w_i[N-7]), .sum(temp1));
    adder Layer1_2 (.a(s0), .b(s1), .sum(temp2));
    adder Layer2_1 (.a(temp1), .b(temp2), .sum(w_q_i[N]));

    // Loop Unroll ************************************************

    logic [31:0] s2, s3, temp3, temp4;

    assign s2 = {w_i[N-14][6:0], w_i[N-14][31:7]} ^ {w_i[N-14][17:0], w_i[N-14][31:18]} ^ {3'b000, w_i[N-14][31:3]};
    assign s3 = {w_i[N-1][16:0], w_i[N-1][31:17]} ^ {w_i[N-1][18:0], w_i[N-1][31:19]} ^ {10'b0000000000, w_i[N-1][31:10]};

    adder Layer1_1_unroll (.a(w_i[N-15]), .b(w_i[N-6]), .sum(temp3));
    adder Layer1_2_unroll (.a(s2), .b(s3), .sum(temp4));
    adder Layer2_1_unroll (.a(temp3), .b(temp4), .sum(w_q_i[N+1]));

    // Loop Unroll Done *******************************************

    // Second Round
    logic [31:0] s0_1, s1_1, temp1_1, temp2_1;

    assign s0_1 = {w_i[N-13][6:0], w_i[N-13][31:7]} ^ {w_i[N-13][17:0], w_i[N-13][31:18]} ^ {3'b000, w_i[N-13][31:3]};
    assign s1_1 = {w_q_i[N][16:0], w_q_i[N][31:17]} ^ {w_q_i[N][18:0], w_q_i[N][31:19]} ^ {10'b0000000000, w_q_i[N][31:10]};

    adder Layer1_1_1 (.a(w_i[N-14]), .b(w_i[N-5]), .sum(temp1_1));
    adder Layer1_2_1 (.a(s0_1), .b(s1_1), .sum(temp2_1));
    adder Layer2_1_1 (.a(temp1_1), .b(temp2_1), .sum(w_q_i[N+2]));

    // Loop Unroll ************************************************

    logic [31:0] s2_1, s3_1, temp3_1, temp4_1;

    assign s2_1 = {w_i[N-12][6:0], w_i[N-12][31:7]} ^ {w_i[N-12][17:0], w_i[N-12][31:18]} ^ {3'b000, w_i[N-12][31:3]};
    assign s3_1 = {w_q_i[N+1][16:0], w_q_i[N+1][31:17]} ^ {w_q_i[N+1][18:0], w_q_i[N+1][31:19]} ^ {10'b0000000000, w_q_i[N+1][31:10]};

    adder Layer1_1_unroll_1 (.a(w_i[N-13]), .b(w_i[N-4]), .sum(temp3_1));
    adder Layer1_2_unroll_1 (.a(s2_1), .b(s3_1), .sum(temp4_1));
    adder Layer2_1_unroll_1 (.a(temp3_1), .b(temp4_1), .sum(w_q_i[N+3]));

    // Loop Unroll Done *******************************************

    genvar i;
    generate
        for(i = 0; i < N; i++) begin: eachFirstHalf
            assign w_q_i[i] = w_i[i];
        end
    endgenerate

    generate
        for(i = N + 4; i < 64; i++) begin: eachSecondHalf
            assign w_q_i[i] = w_i[i];
        end
    endgenerate

    always_ff @(posedge clk) begin
        integer i;
        if (reset) begin
            for (i = 0; i < 64; i++) w_o[i] <= 32'b0;
        end
        else begin
            for (i = 0; i < 64; i++) begin 
                w_o[i] <= w_q_i[i];
            end
        end
    end

    D_FF #(.WIDTH(8)) num_of_zero (.clk(clk), .reset(reset), .d(num_zero_i), .q(num_zero_o));
    D_FF #(.WIDTH(512)) plain_text (.clk(clk), .reset(reset), .d(original_i), .q(original_o));
        

endmodule

module compression_noDFF(in, out, k, w_i);
input logic [7:0][31:0] in;
    input logic [31:0] k;
    input logic [31:0] w_i;
    output logic [7:0][31:0] out;

    logic [31:0] s1, ch, temp1, s0, major, temp2;
    logic [31:0] t1, t2, t3;

    assign s1 = {in[4][5:0], in[4][31:6]} ^ {in[4][10:0], in[4][31:11]} ^ {in[4][24:0], in[4][31:25]};
    assign ch = (in[4] & in[5]) ^ ((~in[4]) & in[6]);
    //assign temp1 = in[7] + s1 + ch + k + w_i[N];
    assign s0 = {in[0][1:0], in[0][31:2]} ^ {in[0][12:0], in[0][31:13]} ^ {in[0][21:0], in[0][31:22]};
    assign major = (in[0] & in[1]) ^ (in[0] & in[2]) ^ (in[1] & in[2]);
    //assign temp2 = s0 + major;
  
    adder Layer1_1 (.a(s1), .b(ch), .sum(t1));
    adder Layer1_2 (.a(k), .b(w_i), .sum(t2));
    adder Layer2_1 (.a(t1), .b(t2), .sum(t3));
    adder Layer3_1 (.a(t3), .b(in[7]), .sum(temp1));
    adder Layer1_3 (.a(s0), .b(major), .sum(temp2));
    adder Layer4_1 (.a(temp1), .b(temp2), .sum(out[0]));
    adder Layer4_2 (.a(temp1), .b(in[3]), .sum(out[4]));


    assign out[7] = in[6];
    assign out[6] = in[5];
    assign out[5] = in[4];
    assign out[3] = in[2];
    assign out[2] = in[1];
    assign out[1] = in[0];

endmodule
// index of in[]: 0 = a, 1 = b, 2 = c, 3 = d, 4 = e, 5 = f, 6 = g, 7 = h
module compression #(parameter N = 0) (clk, reset, in, out_o, k, k1, w_i, w_o, num_zero_i, num_zero_o, original_i, original_o);
    input logic clk, reset;
    input logic [7:0][31:0] in;
    input logic [31:0] k, k1;
    input logic [63:0][31:0] w_i;
    input logic [511:0] original_i;
    input logic [7:0] num_zero_i;
    output logic [63:0][31:0] w_o;
    output logic [7:0][31:0] out_o;
    output logic [511:0] original_o;
    output logic [7:0] num_zero_o;
    
    logic [7:0][31:0] in2;
    compression_noDFF perform_compression (.in(in), .out(in2), .k(k), .w_i(w_i[N]));

    logic [31:0] s1, ch, temp1, s0, major, temp2;
    logic [7:0][31:0] out;
    logic [31:0] t1, t2, t3;

    assign s1 = {in2[4][5:0], in2[4][31:6]} ^ {in2[4][10:0], in2[4][31:11]} ^ {in2[4][24:0], in2[4][31:25]};
    assign ch = (in2[4] & in2[5]) ^ ((~in2[4]) & in2[6]);
    //assign temp1 = in[7] + s1 + ch + k + w_i[N];
    assign s0 = {in2[0][1:0], in2[0][31:2]} ^ {in2[0][12:0], in2[0][31:13]} ^ {in2[0][21:0], in2[0][31:22]};
    assign major = (in2[0] & in2[1]) ^ (in2[0] & in2[2]) ^ (in2[1] & in2[2]);
    //assign temp2 = s0 + major;
  
    adder Layer1_1 (.a(s1), .b(ch), .sum(t1));
    adder Layer1_2 (.a(k1), .b(w_i[N+1]), .sum(t2));
    adder Layer2_1 (.a(t1), .b(t2), .sum(t3));
    adder Layer3_1 (.a(t3), .b(in2[7]), .sum(temp1));
    adder Layer1_3 (.a(s0), .b(major), .sum(temp2));
    adder Layer4_1 (.a(temp1), .b(temp2), .sum(out[0]));
    adder Layer4_2 (.a(temp1), .b(in2[3]), .sum(out[4]));


    assign out[7] = in2[6];
    assign out[6] = in2[5];
    assign out[5] = in2[4];
    assign out[3] = in2[2];
    assign out[2] = in2[1];
    assign out[1] = in2[0];

    always_ff @(posedge clk) begin
        integer i;
        if (reset) begin
            for (i = 0; i < 8; i++) out_o[i] <= 32'b0;
            for (i = 0; i < 64; i++) w_o[i] <= 32'b0;
        end
        else begin
            for (i = 0; i < 8; i++) out_o[i] <= out[i];
            for (i = 0; i < 64; i++) w_o[i] <= w_i[i];
        end
    end

    D_FF #(.WIDTH(8)) num_of_zero (.clk(clk), .reset(reset), .d(num_zero_i), .q(num_zero_o));
    D_FF #(.WIDTH(512)) plain_text (.clk(clk), .reset(reset), .d(original_i), .q(original_o));

endmodule


module adder (a, b, sum);
    input logic [31:0] a, b;
    output logic [31:0] sum;

    // ksa_top kogge_stone (.a(a), .b(b), .sum(sum));
    assign sum = a + b;
endmodule


module D_FF #(parameter WIDTH = 1) (clk, reset, d, q);
    input logic clk, reset;
    input logic [WIDTH-1:0] d;
    output logic [WIDTH-1:0] q;

    always_ff @(posedge clk) begin
        if (reset) 
            q <= {WIDTH{1'b0}};
        else 
            q <= d;
    end

endmodule

module bitAddSub(a, b, out, Cin, Cout, sub);
    input logic a, b, Cin, sub;
    output logic out, Cout;
    logic notB, muxOut, xor1, and1, and2;

    parameter delay = 0;

    not #delay n1 (notB, b);
    xor #delay x1 (xor1, a, muxOut);
    xor #delay x2 (out, xor1, Cin);
    and #delay a1 (and1, Cin, xor1);
    and #delay a2 (and2, a, muxOut);
    or #delay o1 (Cout, and1, and2);
    mux2_1 mux (.out(muxOut), .in({notB, b}), .sel(sub));
endmodule

module mux2_1(out, in, sel);
    output logic out;
    input logic [1:0] in;
    input logic sel;
    parameter delay = 0;
    logic i1, i2, i3;

    not #delay n1 (i1, sel);
    and #delay a1 (i2, in[0], i1);
    and #delay a2 (i3, in[1], sel);
    or #delay o1 (out, i2, i3);
endmodule

module rippleAdder8 (A, B, result, sub);
    input logic [7:0] A, B;
    input logic sub;
    output logic [7:0] result;
    logic [7:0] Cout_all;
    
    bitAddSub firstBit (.a(A[0]), .b(B[0]), .out(result[0]), .Cin(sub), .Cout(Cout_all[0]), .sub(sub));
    
    genvar i;
    generate
        for (i = 1; i < 8; i++) begin : eachAddSub
            bitAddSub AddSub (.a(A[i]), .b(B[i]), .out(result[i]), .Cin(Cout_all[i-1]), .Cout(Cout_all[i]), .sub(sub));
        end
    endgenerate
endmodule

module compare (hash_value, shamt, matched);
    input logic [255:0] hash_value;
    input logic [7:0] shamt;
    output logic matched;

    logic [255:0] shifted;
    assign shifted = hash_value >> shamt;
    assign matched = (shifted == 256'd0);

endmodule
