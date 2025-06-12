`timescale 1ms / 1us                    // Time unit = 1ms, precision = 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Kieran Chew
// 
// Create Date: 18.03.2025 11:24:24
// Design Name: Traffic Light Controller
// Module Name: Traffic_Light
// Project Name: EE232 Coursework 1
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Traffic_Light(
    output reg [2:0] traffic_lights,     // Traffic Lights: [Red, Amber, Green]  
    output reg [1:0] pedestrian_lights,  // Pedestrian Lights: [Red, Green]
    input clk,                           // 1kHz Clock
    input button,                        // Pedestrian Button
    input nrst                           // Active Low Reset
    );

// FSM State Definitions
localparam S0_RED        = 3'b000;       // Traffic Red (30s)
localparam S1_RED_AMBER  = 3'b001;       // Traffic Red/Amber (3s)
localparam S2_GREEN      = 3'b010;       // Traffic Green (30s)
localparam S3_AMBER      = 3'b011;       // Traffic Amber (3s)
localparam S4_PED_GREEN  = 3'b100;       // Pedestrian Green (30s)

// FSM State Registers
reg [2:0] current_state, next_state;     // Registers for current and next state
reg [19:0] timer;                        // Timer for state durations (Each count = 1ms)
reg pedestrian_request;                  // Stores pedestrian request

// Next-State Logic
always @(*) begin
    case (current_state)
        S0_RED:      
            if (pedestrian_request)  
                next_state = S4_PED_GREEN;      // Transition to S4: PED_GREEN if button pressed
            else if (timer >= 30000)            // After 30s
                next_state = S1_RED_AMBER;      // Transition to S1: RED/AMBER (Normal Operation)

       S1_RED_AMBER: 
            if (pedestrian_request)  
                next_state = S4_PED_GREEN;      // Transition to S4: PED_GREEN if button pressed
            else if (timer >= 3000)             // After 30s
                next_state = S2_GREEN;          // Transition to S2: GREEN (Normal Operation)

        S2_GREEN:     
            if (pedestrian_request)  
                next_state = S3_AMBER;          // Transition to S3: AMBER if button pressed; Followed by S4: PED_GREEN after 3s
            else if (timer >= 30000)            // After 30s
                next_state = S3_AMBER;          // Transition to S3: AMBER (Normal Operation)

        S3_AMBER:     
            if (pedestrian_request)  
                next_state = S4_PED_GREEN;      // Transition to S4: PED_GREEN if button pressed
            else if (timer >= 3000)             // After 30s
                next_state = S0_RED;            // Transition to S0: RED (Normal Operation)

        S4_PED_GREEN: 
            if (timer >= 30000)                 // After 30s
                next_state = S1_RED_AMBER;      // Transition back to S1: RED/AMBER (Normal Operation)

        default:        
            next_state = S0_RED;                // Default to S0: RED   
    endcase
end

// Sequential Logic: FSM State Transitions (Triggered on Clock Edge or Reset)
always @(posedge clk or negedge nrst) begin
    // Upon Negative Reset (Active Low)  
    if (!nrst) begin  
        current_state <= S0_RED;                // Reset FSM to S0: RED (Default)
        timer <= 0;                             // Reset timer
        pedestrian_request <= 0;                // Clear Pedestrian Request
    end 
    else begin  
    
        // Register pedestrian button press only in valid states
        if (button && (current_state != S4_PED_GREEN)) begin  
            pedestrian_request <= 1;             // Store pedestrian request   
        end

        // Immediate transition to S4: PED_GREEN if in S0: RED and button pressed
        if (button && current_state == S0_RED) begin
            timer <= 0;                          // Reset timer    
            pedestrian_request <= 0;             // Clear Pedestrian Request to prevent repeated activations
            current_state <= S4_PED_GREEN;            
        end
        
        // If button is pressed in S2: GREEN , immediately transition to S3: AMBER!  After 3s, transition to S4: PED_GREEN 
        else if (button && current_state == S2_GREEN) begin
            timer <= 0;                          // Reset timer 
            current_state <= S3_AMBER;           // Set state to S3: AMBER 
        end  
        
        // If button is pressed in S3: AMBER, allow remaining of state to complete, then transition to S4: PED_GREEN (within 3s)
        else if (button && current_state == S3_AMBER && timer >= 3000) begin
            timer <= 0;                          // Reset timer 
            pedestrian_request <= 0;             // Clear Pedestrian Request to prevent repeated activations 
            current_state <= S4_PED_GREEN;       // Set state to S4: PED_GREEN
        end 
         
        // Ensure pedestrian flag resets BEFORE exiting S4_PED_GREEN
        else if (current_state == S4_PED_GREEN && timer >= 30000) begin  
            timer <= 0;
            pedestrian_request <= 0;             // Clear Pedestrian Request to prevent repeated activations
            current_state <= S1_RED_AMBER;       // Transition back to S1: RED_AMBER (Normal Operation)
        end  
        
        // Normal Operation based on timer
        else if ((current_state == S0_RED || current_state == S2_GREEN || current_state == S4_PED_GREEN) && timer >= 30000) begin
            current_state <= next_state;
            timer <= 0;
        end 
        else if ((current_state == S1_RED_AMBER || current_state == S3_AMBER) && timer >= 3000) begin
            current_state <= next_state;
            timer <= 0;
        end 
        
        // Increment timer (1 cycle = 1ms due to 1kHz clock)
        else begin  
            timer <= timer + 1; 
        end
    end  
end

// Output Logic: Traffic and Pedestrian Light Control
always @(*) begin
    case (current_state)
        S0_RED: begin
            traffic_lights = 3'b100;    // Traffic - Red
            pedestrian_lights = 2'b10;  // Pedestrian - Red
        end
        S1_RED_AMBER: begin
            traffic_lights = 3'b110;    // Traffic - Red/Amber
            pedestrian_lights = 2'b10;  // Pedestrian - Red
        end
        S2_GREEN: begin
            traffic_lights = 3'b001;    // Traffic - Green
            pedestrian_lights = 2'b10;  // Pedestrian - Red
        end
        S3_AMBER: begin
            traffic_lights = 3'b010;    // Traffic - Amber
            pedestrian_lights = 2'b10;  // Pedestrian - Red
        end
        S4_PED_GREEN: begin
            traffic_lights = 3'b100;    // Traffic - Red
            pedestrian_lights = 2'b01;  // Pedestrian Green
        end
        default: begin
            traffic_lights = 3'b100;    // Default to Traffic - Red
            pedestrian_lights = 2'b10;  // Default to Pedestrian - Red
        end
    endcase
end 

endmodule
