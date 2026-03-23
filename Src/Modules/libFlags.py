import enum

class LibFlags(enum.Flag):
    UNKNOWN = 0
    SEEED_ARDUINO_CAN = enum.auto()
    arduino_mcp_2515 = enum.auto()
    MCP_CAN_lib = enum.auto()
    CAN_Library = enum.auto()