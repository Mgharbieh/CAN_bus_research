#include <SPI.h>
#include <mcp2515.h>

MCP2515 mcp2515(10);

// Function to create a CAN message
struct can_frame createCANMessage(uint32_t id, bool extended, uint8_t dlc, uint8_t data[8]) {
  struct can_frame msg;

  if (extended) {
    msg.can_id = id | CAN_EFF_FLAG;
  } else {
    msg.can_id = id;
  }

  msg.can_dlc = dlc;

  for (int i = 0; i < dlc; i++) {
    msg.data[i] = data[i];
  }

  return msg;
}

// Optional: update ID
void setCANId(struct can_frame &msg, uint32_t id, bool extended) {
  msg.can_id = extended ? (id | CAN_EFF_FLAG) : id;
}

// Optional: update DLC
void setDLC(struct can_frame &msg, uint8_t dlc) {
  msg.can_dlc = dlc;
}

// Define messages
struct can_frame canMsg1;
struct can_frame canMsg2;

void setup() {
  Serial.begin(115200);
  while (!Serial);

  uint8_t data1[8] = {0x8E, 0x87, 0x32, 0xFA, 0x26, 0x8E, 0xBE, 0x86};
  uint8_t data2[8] = {0x0E, 0x00, 0x00, 0x08, 0x01, 0x00, 0x00, 0xA0};

  canMsg1 = createCANMessage(0x0F6, false, 8, data1);
  canMsg2 = createCANMessage(0x12345678, true, 8, data2);

  mcp2515.reset();
  mcp2515.setBitrate(CAN_125KBPS);
  mcp2515.setNormalMode();

  Serial.println("Refactored CAN Sender Ready");
}

void loop() {
  mcp2515.sendMessage(&canMsg1);
  mcp2515.sendMessage(&canMsg2);

  Serial.println("Messages sent");

  delay(100);
}