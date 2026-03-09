mask_filt_example_test_arduino_mcp2515 = "[Source Code Problem Snippet: \n"\
    "    void setup() {\n\
        mcp2515.setFilterMask(MCP2515::MASK0, false, 0x7FF)\n\
        mcp2515.setFilter(MCP2515::RXF0, false, 0x640);\n\
        mcp2515.setFilter(MCP2515::RXF1, false, 0x641);\n\
        mcp2515.setFilterMask(MCP2515::MASK1, false, 0x3FF); \n\
        mcp2515.setFilter(MCP2515::RXF2, false, 0x080); \n\
        mcp2515.setFilter(MCP2515::RXF3, false, 0x081); \n\
        mcp2515.setFilter(MCP2515::RXF4, false, 0x082); \n\
        mcp2515.setFilter(MCP2515::RXF5, false, 0x083); \n\
    }\n\
    void loop() {\n\
    if (mcp2515.readMessage(&canMsg) == MCP2515::ERROR_OK) \n\
    { \n\
        switch(canMsg.can_id)\n\
        {\n\
            case (0x640):\n\
                break;\n\
            case (0x082):\n\
                break;\n\
            case (0x083):\n\
                break;\n\
            case (0x084):\n\
                break;\n\
            default:\n\
                break;\n\
        }\n\
        if(canMsg.can_id == 0x081)\n\
        {\n\
            continue;\n\
        }]\n" \
    "    [Outputs for this example:\n"  \
    "    {Mask(s) set aren't applied across the full filter value. Is that intentional?\n\
    ['0x641', '0x080'] were setup in the filter but never explicitly used.\n\
    ['0x084'] was being checked but is excluded from the filter.}]\n"


print(mask_filt_example_test_arduino_mcp2515)