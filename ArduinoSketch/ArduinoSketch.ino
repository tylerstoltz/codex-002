/*
 * Arduino USB Controller Sketch
 *
 * This sketch allows an iPhone to control Arduino's digital pin 13
 * via USB serial communication.
 *
 * Commands:
 * - "ON" or "on" : Sets pin 13 HIGH
 * - "OFF" or "off" : Sets pin 13 LOW
 *
 * Hardware:
 * - Arduino board with USB capability (Uno, Leonardo, Mega, etc.)
 * - LED connected to pin 13 (or use built-in LED)
 * - USB cable to connect to iPhone
 */

const int LED_PIN = 13;  // Digital pin to control (built-in LED on most Arduinos)
String inputString = "";      // String to hold incoming data
boolean stringComplete = false;  // Whether the string is complete

void setup() {
  // Initialize serial communication at 9600 baud
  Serial.begin(9600);

  // Set LED pin as output
  pinMode(LED_PIN, OUTPUT);

  // Start with LED off
  digitalWrite(LED_PIN, LOW);

  // Reserve 200 bytes for the input string
  inputString.reserve(200);

  // Send ready message
  Serial.println("Arduino Ready");
  Serial.println("Waiting for commands...");
}

void loop() {
  // Check if a complete string has been received
  if (stringComplete) {
    // Trim whitespace
    inputString.trim();

    // Convert to uppercase for case-insensitive comparison
    inputString.toUpperCase();

    // Process the command
    if (inputString == "ON") {
      digitalWrite(LED_PIN, HIGH);
      Serial.println("OK: Pin 13 is now HIGH");
    }
    else if (inputString == "OFF") {
      digitalWrite(LED_PIN, LOW);
      Serial.println("OK: Pin 13 is now LOW");
    }
    else if (inputString == "STATUS") {
      // Status command to check current state
      int state = digitalRead(LED_PIN);
      Serial.print("Pin 13 state: ");
      Serial.println(state == HIGH ? "HIGH" : "LOW");
    }
    else if (inputString.length() > 0) {
      // Unknown command
      Serial.print("ERROR: Unknown command: ");
      Serial.println(inputString);
    }

    // Clear the string for next input
    inputString = "";
    stringComplete = false;
  }
}

/*
 * SerialEvent occurs whenever new data comes in the hardware serial RX.
 * This routine is run between each time loop() runs, so using delay inside
 * loop can delay response. Multiple bytes of data may be available.
 */
void serialEvent() {
  while (Serial.available()) {
    // Get the new byte
    char inChar = (char)Serial.read();

    // Add it to the inputString
    inputString += inChar;

    // If the incoming character is a newline, set flag
    if (inChar == '\n' || inChar == '\r') {
      stringComplete = true;
    }
  }
}
