/*
Applicable for all single tile versions
Author: Duy Vuong and Jeffery Xu
*/

`timescale 1ns/10ps
module SHA256_testbench();
    logic clk, reset, matched_o;
    logic [511:0] d_i;
    logic [7:0] num_zero_i;
    logic [255:0] d_o;
    logic [511:0] original_o; // output plain text

    SHA256_top dut(.*);

    parameter CLOCK_PERIOD = 10;
    integer f, i;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end // initial

    initial begin
        `ifdef POST_SYN
        $sdf_annotate("./SHA256_top.syn.sdf", dut);
        `endif

        `ifdef POST_APR
        $sdf_annotate("./SHA256_top.apr.sdf", dut);
        `endif
        
        $vcdpluson;
        reset <= 1'b1; @(posedge clk);
        f = $fopen("Output.txt", "w");
        @(posedge clk);
        reset <= 1'b0;
        num_zero_i <= 8'd3;
        // Plain Text: A
        d_i <= 512'h41800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: B
        d_i <= 512'h42800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:df7e70e5021544f4834bbee64a9e3789febc4be81470df629cad6ddb03320a5c
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: C
        d_i <= 512'h43800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:6b23c0d5f35d1b11f9b683f0b0a617355deb11277d91ae091d399c655b87940d
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: D
        d_i <= 512'h44800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:3f39d5c348e5b79d06e842c114e6cc571583bbf44e4b0ebfda1a01ec05745d43
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: E
        d_i <= 512'h45800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:a9f51566bd6705f7ea6ad54bb9deb449f795582d6529a0e22207b8981233ec58
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: F
        d_i <= 512'h46800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:f67ab10ad4e4c53121b6a5fe4da9c10ddee905b978d3788d2723d7bfacbe28a9
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: G
        d_i <= 512'h47800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:333e0a1e27815d0ceee55c473fe3dc93d56c63e3bee2b3b4aee8eed6d70191a3
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: H
        d_i <= 512'h48800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:44bd7ae60f478fae1061e11a7739f4b94d1daf917982d33b6fc8a01a63f89c21
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: I
        d_i <= 512'h49800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:a83dd0ccbffe39d071cc317ddf6e97f5c6b1c87af91919271f9fa140b0508c6c
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: J
        d_i <= 512'h4a800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:6da43b944e494e885e69af021f93c6d9331c78aa228084711429160a5bbd15b5
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: K
        d_i <= 512'h4b800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:86be9a55762d316a3026c2836d044f5fc76e34da10e1b45feee5f18be7edb177
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: L
        d_i <= 512'h4c800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:72dfcfb0c470ac255cde83fb8fe38de8a128188e03ea5ba5b2a93adbea1062fa
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: M
        d_i <= 512'h4d800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:08f271887ce94707da822d5263bae19d5519cb3614e0daedc4c7ce5dab7473f1
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: N
        d_i <= 512'h4e800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:8ce86a6ae65d3692e7305e2c58ac62eebd97d3d943e093f577da25c36988246b
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: O
        d_i <= 512'h4f800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:c4694f2e93d5c4e7d51f9c5deb75e6cc8be5e1114178c6a45b6fc2c566a0aa8c
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: P
        d_i <= 512'h50800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:5c62e091b8c0565f1bafad0dad5934276143ae2ccef7a5381e8ada5b1a8d26d2
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: Q
        d_i <= 512'h51800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:4ae81572f06e1b88fd5ced7a1a000945432e83e1551e6f721ee9c00b8cc33260
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: R
        d_i <= 512'h52800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:8c2574892063f995fdf756bce07f46c1a5193e54cd52837ed91e32008ccf41ac
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: S
        d_i <= 512'h53800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:8de0b3c47f112c59745f717a626932264c422a7563954872e237b223af4ad643
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: T
        d_i <= 512'h54800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:e632b7095b0bf32c260fa4c539e9fd7b852d0de454e9be26f24d0d6f91d069d3
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: U
        d_i <= 512'h55800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:a25513c7e0f6eaa80a3337ee18081b9e2ed09e00af8531c8f7bb2542764027e7
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: V
        d_i <= 512'h56800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:de5a6f78116eca62d7fc5ce159d23ae6b889b365a1739ad2cf36f925a140d0cc
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: W
        d_i <= 512'h57800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:fcb5f40df9be6bae66c1d77a6c15968866a9e6cbd7314ca432b019d17392f6f4
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: X
        d_i <= 512'h58800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:4b68ab3847feda7d6c62c1fbcbeebfa35eab7351ed5e78f4ddadea5df64b8015
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: Y
        d_i <= 512'h59800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:18f5384d58bcb1bba0bcd9e6a6781d1a6ac2cc280c330ecbab6cb7931b721552
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        // Plain Text: Z
        d_i <= 512'h5a800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008;
        // Expect Output:bbeebd879e1dff6918546dc0c179fdde505f2a21591c9a9c96e36b054ec5af83
        $fwrite(f, "%h\n", d_o);
        $fwrite(f, "matched_o: %b\n", matched_o);
        @(posedge clk);

        for (i = 0; i < 100; i++) begin
            $fwrite(f, "%h\n", d_o); 
            $fwrite(f, "matched_o: %b\n", matched_o);
            @(posedge clk); 
        end

        $fclose(f);
        $finish;
        //$stop;
    end
    
endmodule
