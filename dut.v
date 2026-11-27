module watchdog_timer (
    input clk, rst_n, enable, kick,
    input [15:0] ini_seed_time,
    output reg         timeout               
);          
    reg [15:0] counter;                   
    always @(posedge clk or negedge rst_n)  begin   
        if (!rst_n) begin 
            counter <= ini_seed_time;     
            timeout <= 1'b0;
        end else if (enable) begin      
            if (kick) begin     
                counter <= ini_seed_time;      
                timeout <= 1'b0;   
            end else if (counter == 16'd0) begin
                timeout <= 1'b1;        
            end else begin
                counter <= counter - 1'b1;    
            end   
        end else begin   
            counter <= ini_seed_time;
            timeout <= 1'b0;
        end    
    end
endmodule
