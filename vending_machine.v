// ============================================================
//  FSM-Based Digital Vending Machine
//  Item Cost : Rs. 10
//  Accepted  : Rs. 5 coin, Rs. 10 coin
//  Outputs   : dispense (item), change (Rs. 5 back)
// ============================================================

module vending_machine (
    input  wire clk,        // Clock signal
    input  wire rst,        // Active-high synchronous reset
    input  wire coin5,      // Rs. 5  coin inserted
    input  wire coin10,     // Rs. 10 coin inserted
    output reg  dispense,   // HIGH → dispense item
    output reg  change      // HIGH → return Rs. 5 change
);

    // --------------------------------------------------------
    // State Encoding  (one-hot is fine too, but binary is
    // easier to read for beginners)
    // --------------------------------------------------------
    parameter IDLE     = 2'b00;   // Rs. 0  collected
    parameter GOT_5    = 2'b01;   // Rs. 5  collected
    parameter DISPENSE = 2'b10;   // Rs. 10 reached – dispense
    parameter CHANGE   = 2'b11;   // Rs. 15 reached – dispense + change

    reg [1:0] current_state, next_state;

    // --------------------------------------------------------
    // Sequential Block : state register
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // --------------------------------------------------------
    // Combinational Block : next-state logic
    // --------------------------------------------------------
    always @(*) begin
        // Default: stay in current state
        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (coin10)
                    next_state = DISPENSE;   // Rs.10 in one go
                else if (coin5)
                    next_state = GOT_5;      // First Rs.5
                // else stay IDLE
            end

            GOT_5: begin
                if (coin10)
                    next_state = CHANGE;     // Rs.5 + Rs.10 = Rs.15 → change
                else if (coin5)
                    next_state = DISPENSE;   // Rs.5 + Rs.5  = Rs.10 → dispense
                // else stay in GOT_5 (waiting)
            end

            DISPENSE: begin
                // Item dispensed; go back to IDLE next cycle
                next_state = IDLE;
            end

            CHANGE: begin
                // Item dispensed + change returned; go back to IDLE
                next_state = IDLE;
            end

            default: next_state = IDLE;

        endcase
    end

    // --------------------------------------------------------
    // Output Block : Moore machine outputs depend only on state
    // --------------------------------------------------------
    always @(*) begin
        // Defaults
        dispense = 1'b0;
        change   = 1'b0;

        case (current_state)
            DISPENSE: begin
                dispense = 1'b1;
                change   = 1'b0;
            end
            CHANGE: begin
                dispense = 1'b1;
                change   = 1'b1;
            end
            default: begin
                dispense = 1'b0;
                change   = 1'b0;
            end
        endcase
    end

endmodule
