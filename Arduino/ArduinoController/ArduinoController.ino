/*
 * ArduinoController.ino
 *
 * Arduino sketch for iPhone USB-C control
 * Controls digital pin 13 (built-in LED) based on serial commands
 *
 * Commands:
 * - "HIGH" or "ON" or "1" -> Set pin HIGH
 * - "LOW" or "OFF" or "0" -> Set pin LOW
 */

const int CONTROL_PIN = 13; // Using built-in LED pin (change to any digital pin)
const int BAUD_RATE = 9600;

String inputString = "";
bool stringComplete = false;

void setup() {
  // Initialize serial communication
  Serial.begin(BAUD_RATE);

  // Set the control pin as output
  pinMode(CONTROL_PIN, OUTPUT);

  // Start with pin LOW
  digitalWrite(CONTROL_PIN, LOW);

  // Reserve 200 bytes for the input string
  inputString.reserve(200);

  // Send ready message
  Serial.println("Arduino Ready");
  Serial.print("Controlling Pin: ");
  Serial.println(CONTROL_PIN);
}

void loop() {
  // Check if a complete command has been received
  if (stringComplete) {
    processCommand(inputString);

    // Clear the string for next command
    inputString = "";
    stringComplete = false;
  }
}

/*
 * SerialEvent occurs whenever new data comes in the hardware serial RX.
 * This routine is run between each time loop() runs.
 */
void serialEvent() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();

    // Add character to input string
    inputString += inChar;

    // If newline character, set flag to process command
    if (inChar == '\n' || inChar == '\r') {
      stringComplete = true;
    }
  }
}

/*
 * Process the received command and control the pin
 */
void processCommand(String command) {
  // Remove whitespace and convert to uppercase
  command.trim();
  command.toUpperCase();

  // Check command and set pin accordingly
  if (command == "HIGH" || command == "ON" || command == "1") {
    digitalWrite(CONTROL_PIN, HIGH);
    Serial.println("Pin set to HIGH");
  }
  else if (command == "LOW" || command == "OFF" || command == "0") {
    digitalWrite(CONTROL_PIN, LOW);
    Serial.println("Pin set to LOW");
  }
  else if (command.length() > 0) {
    Serial.print("Unknown command: ");
    Serial.println(command);
  }
}

/*
 * Alternative: If you want to control a different pin, you can use:
 *
 * For example, to control pin 7:
 * const int CONTROL_PIN = 7;
 *
 * Or to control multiple pins, modify the processCommand function:
 *
 * void processCommand(String command) {
 *   command.trim();
 *   command.toUpperCase();
 *
 *   // Format: "PIN:STATE" e.g., "7:HIGH" or "13:LOW"
 *   int colonIndex = command.indexOf(':');
 *   if (colonIndex > 0) {
 *     int pin = command.substring(0, colonIndex).toInt();
 *     String state = command.substring(colonIndex + 1);
 *
 *     pinMode(pin, OUTPUT);
 *
 *     if (state == "HIGH" || state == "ON" || state == "1") {
 *       digitalWrite(pin, HIGH);
 *       Serial.print("Pin ");
 *       Serial.print(pin);
 *       Serial.println(" set to HIGH");
 *     } else if (state == "LOW" || state == "OFF" || state == "0") {
 *       digitalWrite(pin, LOW);
 *       Serial.print("Pin ");
 *       Serial.print(pin);
 *       Serial.println(" set to LOW");
 *     }
 *   }
 * }
 */
