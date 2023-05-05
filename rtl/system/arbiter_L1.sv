// simple arbiter 
// not collision safe

module arbiter_l1 #(
    int NUMBER_HOSTS = 2
) (
    input logic [NUMBER_HOSTS-1:0] Host_req_valid_i,
    input logic [NUMBER_HOSTS-1:0] network_ready_i,
    output logic [NUMBER_HOSTS-1:0] Host_grant_o
) ; 
    assign Host_grant_o = network_ready_i & Host_req_valid_i;
endmodule