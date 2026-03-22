`timescale 1ns/1ps
module vending_machine_tb;

    reg  clk, rst, coin5, coin10;
    wire dispense, change;

    vending_machine uut (
        .clk(clk), .rst(rst),
        .coin5(coin5), .coin10(coin10),
        .dispense(dispense), .change(change)
    );

    always #5 clk = ~clk;

    // Apply coin, wait for posedge (state latches), then sample outputs
    task apply_coin;
        input c5, c10;
        begin
            coin5  = c5;
            coin10 = c10;
            @(posedge clk);
            #1;
            coin5  = 0;
            coin10 = 0;
        end
    endtask

    initial begin
        clk=0; rst=1; coin5=0; coin10=0;
        repeat(2) @(posedge clk); #1;
        rst=0;

        $display("\n====== Vending Machine FSM Simulation ======\n");

        // TEST 1: Rs.10
        $display("--- Test 1: Insert Rs.10 ---");
        apply_coin(0,1);
        $display("  dispense=%b  change=%b  (EXPECTED: 1 0)", dispense, change);
        @(posedge clk); #1;
        $display("  [IDLE] dispense=%b change=%b\n", dispense, change);

        // TEST 2: Rs.5 + Rs.5
        $display("--- Test 2: Rs.5 + Rs.5 ---");
        apply_coin(1,0);
        $display("  1st Rs.5 -> dispense=%b change=%b  (EXPECTED: 0 0)", dispense, change);
        apply_coin(1,0);
        $display("  2nd Rs.5 -> dispense=%b change=%b  (EXPECTED: 1 0)", dispense, change);
        @(posedge clk); #1;
        $display("  [IDLE] dispense=%b change=%b\n", dispense, change);

        // TEST 3: Rs.5 + Rs.10
        $display("--- Test 3: Rs.5 + Rs.10 (overpay / change) ---");
        apply_coin(1,0);
        $display("  Rs.5    -> dispense=%b change=%b  (EXPECTED: 0 0)", dispense, change);
        apply_coin(0,1);
        $display("  Rs.10   -> dispense=%b change=%b  (EXPECTED: 1 1)", dispense, change);
        @(posedge clk); #1;
        $display("  [IDLE] dispense=%b change=%b\n", dispense, change);

        // TEST 4: Reset mid-transaction
        $display("--- Test 4: Reset mid-transaction ---");
        apply_coin(1,0);
        $display("  GOT_5  -> dispense=%b change=%b", dispense, change);
        rst=1; @(posedge clk); #1; rst=0;
        $display("  RESET  -> dispense=%b change=%b  (EXPECTED: 0 0)", dispense, change);

        $display("\n====== Simulation Complete ======\n");
        $finish;
    end

    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);
    end
endmodule
