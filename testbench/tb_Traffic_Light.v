`timescale 1ms / 1us

module tb_Traffic_Light();

   // Testbench Signals
    reg clk;
    reg button;
    reg nrst;
    wire [2:0] traffic_lights;
    wire [1:0] pedestrian_lights;

    // Instantiate the DUT (Device Under Test)
    Traffic_Light uut (
        .traffic_lights(traffic_lights),
        .pedestrian_lights(pedestrian_lights),
        .clk(clk),
        .button(button),
        .nrst(nrst)
    );

    // Generate 1kHz Clock (1ms period), toggles every 0.5ms
    always #0.5 clk = ~clk;

    // Monitor FSM State Changes
    always @(traffic_lights, pedestrian_lights) begin
        case (traffic_lights)
            3'b100: $display("Traffic Light: RED | Pedestrian Light: %s", (pedestrian_lights == 2'b01) ? "GREEN" : "RED");
            3'b110: $display("Traffic Light: RED/AMBER | Pedestrian Light: RED");
            3'b001: $display("Traffic Light: GREEN | Pedestrian Light: RED");
            3'b010: $display("Traffic Light: AMBER | Pedestrian Light: RED");
        endcase
    end
    
    // PLEASE ENSURE YOU PRESS THE RUN ALL (F3) B\button during Simulation
    initial begin
        // Initialize Signals
        clk = 0;
        nrst = 0;
        button = 0;

        // Reset the system
        $display("Applying Reset...");
        #5;         // 5ms delay
        nrst = 1;
        #5;         // 5ms delay

        // Normal Operation Cycle
        $display("Starting Normal Operation...");
        #30000;     // S0: RED (30s)
        #3000;      // S1: RED/AMBER (3s)
        #30000;     // S2: GREEN (30s)
        #3000;      // S3: AMBER (3s)
        $display("Normal Operation Test COMPLETED!");

        // --------------- TESTING PEDESTRIAN BUTTON PRESS ---------------

        // Test 1: Press button in S0 (Red)
        $display("Testing Button Press at S0 (Red)...");
        #15000;     // 15s into S0: RED
        button = 1;
        $display("Button Pressed");
        #10 button = 0;
        #30000;     // Wait for S4: PED_GREEN completion
        
        // Test 2: Press button in S1 (Red/Amber)
        $display("Testing Button Press at S1 (Red/Amber)...");
        #1500;      // 1.5s into S1: RED/AMBER
        button = 1;
        $display("Button Pressed");
        #10 button = 0;
        #30000;     // Wait for S4: PED_GREEN completion
        
        // Test 3: Press button in S2 (Green)
        $display("Testing Button Press at S2 (Green)...");
        #3000;      // S1: RED/AMBER (3s)
        #15000;     // 15s into S2: GREEN
        button = 1;
        $display("Button Pressed");
        #10 button = 0;
        #3000;      // S3: AMBER (3s)
        #30000;     // Wait for S4: PED_GREEN completion
        
        // Test 4: Press button in S3 (Amber)
        $display("Testing Button Press at S3 (Amber)...");
        #3000;      // S1: RED/AMBER (3s)
        #30000;     // S2: GREEN (30s)
        #1500;      // 1.5s into S3: AMBER 
        button = 1;
        $display("Button Pressed");
        #10 button = 0;
        #1500;      // 1.5s into S3: AMBER
        #30000;     // Wait for S4: PED_GREEN completion
        
        // Normal Operation Cycle
        $display("Starting Normal Operation...");
        #3000;      // S1: RED/AMBER (3s)
        #30000;     // S2: GREEN (30s)
        #3000;      // S3: AMBER (3s)
        #30000;     // S0: RED (30s)
        
        $display("Pedestrian Button Test COMPLETED!.");
        
        // --------------- EXTREME EDGE CASE TESTING ---------------
        
        // Test 5: Press button at the last moment before transition from Green to Amber
        $display("Testing Button Press at Last Moment in S2 (Green)...");
        #3000;      // S3: AMBER (3s)
        #29990;     // 10ms before Green transitions to Amber
        button = 1;
        $display("Button Pressed at the last moment in S2");
        #10 button = 0;
        #3000;      // S3: AMBER (3s)
        #30000;     // Wait for S4: PED_GREEN completion
        
        // Test 6: Rapid Button Presses in S0 (Red)
        $display("Testing Rapid Button Presses in S0 (Red)...");
        #3000;      // S1: RED/AMBER (3s)
        #30000;     // S2: GREEN (30s)
        #3000;      // S3: AMBER (3s)
        #10000;     // 10s into S0: RED
        button = 1;
        #5 button = 0;  // Quick release
        #5 button = 1;
        $display("Multiple Rapid Button Presses in S0");
        #5 button = 0;  // Another quick release
        #15000;         // 15s into S4: PED_GREEN completion
        
        // Test 7: Button Press in S4 (Pedestrian Green) - Should be ignored
        $display("Testing Button Press in S4 (Pedestrian Green)...");
        #5000;     // 20s into S4: PED_GREEN
        button = 1;
        $display("Button Pressed in S4 - Should be ignored");
        #10 button = 0;
        #10000;    // Complete S4: PED_GREEN duration
        #100;      // Extra 0.1s into S1: RED_AMBER
        if (pedestrian_lights == 2'b10)
        $display("S4: PED_GREEN did not repeat, SUCCESS!"); 
        else if (pedestrian_lights == 2'b01)
        $display("S4: PED_GREEN repeated, ERROR!");
        
        $display("Extreme Edge Case Testing COMPLETED!.");
        $stop;     // Stop simulation
        
    end

endmodule