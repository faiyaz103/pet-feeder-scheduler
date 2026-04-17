`timescale 1ns / 1ps

module tb_pet_feeder;

    // Inputs
    reg clk;
    reg reset;
    reg btnC;
    reg [3:0] sw;

    // Outputs
    wire [6:0] seg;
    wire [3:0] an;
    wire motor_en;
    wire led_status;

    // Instantiate the Unit Under Test (UUT)
    // Use small divisors for faster simulation
    pet_feeder_top #(
        .DIV_1HZ(19),    // 20 clock cycles = 1 Hz tick
        .DIV_1KHZ(4)     // 5 clock cycles = 1 kHz tick
    ) uut (
        .clk(clk),
        .reset(reset),
        .btnC(btnC),
        .sw(sw),
        .seg(seg),
        .an(an),
        .motor_en(motor_en),
        .led_status(led_status)
    );

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        btnC = 0;
        sw = 0;

        // Wait 100 ns for global reset
        #100;
        reset = 0;
        
        // --- Test Case 1: Manual Override ---
        #50;
        btnC = 1;
        #20; // Hold for a bit
        btnC = 0;
        
        // Wait for feeding cycle (10 seconds = 10 * 20 * 10ns = 2000ns)
        #2500;
        
        // --- Test Case 2: Scheduled Trigger (08:00) ---
        // Fast-forward time using hierarchical access for simulation
        // Setting time to 07:59:58
        uut.timekeeper.hours = 7;
        uut.timekeeper.minutes = 59;
        uut.timekeeper.seconds = 58;
        
        sw = 4'b0001; // Enable 08:00 slot
        
        // Wait for 2 ticks to reach 08:00:00
        // Each tick is 200ns
        #500;
        
        // At this point motor_en should be HIGH
        #2500; // Wait for feeding finish
        
        // --- Test Case 3: Rollover Check ---
        uut.timekeeper.hours = 23;
        uut.timekeeper.minutes = 59;
        uut.timekeeper.seconds = 59;
        
        #300; // Wait for rollover to 00:00:00
        
        #100;
        $display("Simulation Finished");
        $stop;
    end
      
endmodule
