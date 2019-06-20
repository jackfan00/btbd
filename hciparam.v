//
// 2019/04/26
// HCI configuration parameter : core5.1 Spec Part E Chapter 6
//
`define Scan_Enable 8'h00
`define Inquiry_Scan_Interval 16'h1000   //2.56s
`define Inquiry_Scan_Window 16'h0012   //11.25ms
`define Inquiry_Scan_Type 8'h00   //standard scan
`define Inquiry_Mode 8'h00   //Standard Inquiry Result event format
`define Page_Timeout 16'h2000   //5.12s

`define Connection_Accept_Timeout 16'h1f40 //5s
`define Page_Scan_Interval  16'h0800  //1.28s
`define Page_Scan_Window  16'h0012  //11.25ms
`define Page_Scan_Type 8'h00      //standard scan

//`define Voice_Setting 10'h00
//`define PIN_Type 8'h00

`define Authentication_Enable 8'h00 //Authentication not required
`define Hold_Mode_Activity  8'h00 // Maintain current Power State
`define Link_Policy_Settings 16'h0000 //Disable All LM Modes Default
`define Flush_Timeout 16'h0000 //No Automatic Flush
`define NUM_BROADCAST_RETRANSMISSIONS 8'h00 //NBC = NUM_BROADCAST_RETRANSMISSIONS + 1
`define Link_Supervision_Timeout 16'h7d00 //20s
`define Synchronous_Flow_Control_Enable 8'h00 //Synchronous Flow Control is disabled

//Local Name
//Extended Inquiry Response
`define Erroneous_Data_Reporting 8'h00 //Erroneous data reporting disabled
`define Class_of_Device 48'h000000 //Class of Device for the device

//Supported Commands , 64 bytes

`define GIAC_LAP  24'h0x9E8B33
//`define DIAC_LAP  0x9E8B00-0x9E8B3F
//`define DCI 0