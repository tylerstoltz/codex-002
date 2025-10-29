# Arduino iOS USB Controller

An iOS application that allows you to control an Arduino's digital pins directly from your iPhone via USB-C connection.

## Features

- Simple, intuitive SwiftUI interface
- Real-time USB communication with Arduino
- Toggle Arduino digital pin 13 ON/OFF with a button
- Connection status indicator
- Works with iPhone 15 and newer (with USB-C port)

## Project Structure

```
.
├── ArduinoController/               # iOS App
│   ├── ArduinoController/
│   │   ├── ArduinoControllerApp.swift    # Main app entry point
│   │   ├── ContentView.swift              # SwiftUI UI
│   │   ├── ArduinoManager.swift           # USB communication manager
│   │   ├── Info.plist                     # App configuration
│   │   └── Assets.xcassets/               # App assets
│   └── ArduinoController.xcodeproj/       # Xcode project
└── ArduinoSketch/
    └── ArduinoSketch.ino            # Arduino firmware
```

## Requirements

### iOS App
- Xcode 15.0 or later
- iOS 16.0 or later
- iPhone with USB-C port (iPhone 15 or newer)
- Apple Developer account (for device deployment)

### Arduino
- Arduino board with USB capability:
  - Arduino Uno
  - Arduino Leonardo
  - Arduino Mega 2560
  - Arduino Nano
  - Or any compatible board
- USB cable (appropriate for your Arduino)
- USB-C to USB adapter (if your Arduino doesn't have USB-C)

## Setup Instructions

### Step 1: Upload Arduino Sketch

1. Open the Arduino IDE
2. Connect your Arduino to your computer via USB
3. Open `ArduinoSketch/ArduinoSketch.ino`
4. Select your Arduino board: **Tools > Board**
5. Select the correct port: **Tools > Port**
6. Click **Upload** (or press Cmd+U)
7. Wait for the upload to complete
8. Open Serial Monitor (Tools > Serial Monitor) to verify it's working
   - You should see "Arduino Ready" and "Waiting for commands..."

### Step 2: Configure the iOS App

1. Open `ArduinoController/ArduinoController.xcodeproj` in Xcode
2. Select the project in the Project Navigator
3. Under **Signing & Capabilities**:
   - Select your development team
   - Ensure "Automatically manage signing" is checked
4. Change the Bundle Identifier if needed (e.g., `com.yourname.ArduinoController`)

### Step 3: Build and Deploy to iPhone

1. Connect your iPhone to your Mac
2. Select your iPhone as the build target in Xcode
3. Click **Run** (or press Cmd+R)
4. If prompted, trust the developer certificate on your iPhone:
   - Go to **Settings > General > VPN & Device Management**
   - Tap your developer account and trust it

### Step 4: Connect Arduino to iPhone

1. Disconnect the Arduino from your computer
2. Connect the Arduino to your iPhone using:
   - USB-C cable (if Arduino has USB-C)
   - USB-C to USB adapter + USB cable
3. You may see a prompt to allow the connection - tap **Allow**

### Step 5: Use the App

1. Launch the **Arduino Controller** app on your iPhone
2. The app should automatically detect the Arduino
3. If not connected, tap the **Reconnect** button
4. Once connected, tap the large circular button to toggle pin 13 ON/OFF
5. The LED on your Arduino (pin 13) should turn on and off accordingly

## How It Works

### iOS App Architecture

- **ArduinoControllerApp.swift**: Main app entry point using SwiftUI App lifecycle
- **ContentView.swift**: User interface with connection status and control button
- **ArduinoManager.swift**: Handles USB communication using ExternalAccessory framework
  - Manages connection lifecycle
  - Sends commands to Arduino
  - Receives responses from Arduino

### Arduino Sketch

- Listens for serial commands over USB
- Accepts commands:
  - `ON` - Sets pin 13 HIGH
  - `OFF` - Sets pin 13 LOW
  - `STATUS` - Returns current pin state
- Sends confirmation messages back to iPhone
- Uses built-in `serialEvent()` for efficient command parsing

### Communication Protocol

1. iPhone sends text commands over USB serial
2. Commands are terminated with newline character (`\n`)
3. Arduino processes commands and responds
4. Baud rate: 9600

## Troubleshooting

### Arduino Not Detected

1. Check USB cable and connections
2. Ensure Arduino sketch is uploaded correctly
3. Try tapping **Reconnect** in the app
4. Restart the Arduino (disconnect and reconnect power)
5. Force quit and relaunch the iOS app

### Permission Issues

- If the app doesn't request USB permission:
  1. Check `Info.plist` has `UISupportedExternalAccessoryProtocols`
  2. Delete app from iPhone and reinstall
  3. Ensure your Arduino supports USB CDC (most modern ones do)

### Connection Established but Commands Don't Work

1. Open Arduino IDE Serial Monitor
2. Type `ON` and `OFF` commands manually
3. Verify Arduino responds correctly
4. Check baud rate matches (9600) in both Arduino and iOS code

### Building Issues in Xcode

- Ensure deployment target is iOS 16.0 or later
- Check that all files are included in the target
- Clean build folder: **Product > Clean Build Folder**
- Restart Xcode if needed

## Customization

### Change the Controlled Pin

In `ArduinoSketch.ino`, modify:
```cpp
const int LED_PIN = 13;  // Change to your desired pin number
```

### Add More Commands

1. In Arduino sketch, add new command handlers in `loop()`
2. In iOS app, add new methods to `ArduinoManager` to send commands
3. Update UI in `ContentView.swift` to trigger new commands

### Multiple Pin Control

Extend the protocol to support multiple pins:
- Arduino: `PIN13:ON`, `PIN12:OFF`, etc.
- Update both Arduino sketch and iOS app accordingly

## Technical Notes

### ExternalAccessory Framework

- Used for USB communication on iOS
- Requires protocol strings in Info.plist
- No MFi certification needed for CDC devices
- Alternative to GameController or other frameworks

### USB CDC Support

- Most modern Arduinos support USB CDC (Communications Device Class)
- Appears as a serial port to the iPhone
- Native USB boards (Leonardo, Micro) have better support
- Uno/Nano work through USB-Serial chip

### Limitations

- Requires physical USB connection (no wireless)
- iPhone must support USB host mode (USB-C models)
- App must be in foreground for reliable communication
- Background mode support is limited

## Future Enhancements

- [ ] Support for multiple pins
- [ ] PWM control for analog outputs
- [ ] Read sensor data from Arduino
- [ ] Save/load pin configurations
- [ ] Multiple Arduino support
- [ ] Logging and debugging console
- [ ] Support for different baud rates
- [ ] Bluetooth communication option

## License

This project is provided as-is for educational and personal use.

## Support

For issues or questions:
1. Check the Arduino Serial Monitor for errors
2. Check Xcode console for iOS app logs
3. Verify USB connections and permissions
4. Test Arduino separately with Arduino IDE Serial Monitor

## References

- [Apple ExternalAccessory Framework Documentation](https://developer.apple.com/documentation/externalaccessory)
- [Arduino Serial Communication](https://www.arduino.cc/reference/en/language/functions/communication/serial/)
- [iOS USB Accessory Development](https://developer.apple.com/accessories/)

---

Built with Swift, SwiftUI, and Arduino
