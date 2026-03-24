//One DLC issue, dlc set low
//1 DBP issues, can Msg1 works fine, canMsg2 has a dlc of 7 but packs 8 bytes of data

#include <SPI.h>
#include <mcp2515.h>

struct can_frame canMsg1;
struct can_frame canMsg2;
MCP2515 mcp2515(10);

void fillFrame(struct can_frame* msg) {
  msg.data[0] = 0x8E;
  msg.data[1] = 0x87;
  msg.data[2] = 0x32;
  msg.data[3] = 0xFA;
  msg.data[4] = 0x26;
  msg.data[5] = 0x8E;
  msg.data[6] = 0xBE;
  msg.data[7] = 0x86;
}


void setup() {
  canMsg1.can_id  = 0x0F6;
  canMsg1.can_dlc = 8;
  fillFrame(&canMsg1);

  canMsg2.can_id  = 0x036;
  canMsg2.can_dlc = 7;
  fillFrame(&canMsg2);
  
  while (!Serial);
  Serial.begin(115200);
  
  mcp2515.reset();
  mcp2515.setBitrate(CAN_125KBPS);
  mcp2515.setNormalMode();
  
  Serial.println("Example: Write to CAN");
}

void loop() {
  mcp2515.sendMessage(&canMsg1);
  mcp2515.sendMessage(&canMsg2);

  Serial.println("Messages sent");
  
  delay(100);
}