# Arduino iOS Controller - Setup Guide

This project allows you to control an Arduino's digital I/O pins from an iPhone via USB-C connection.

## Overview

The app provides a simple toggle button interface to control digital pin 13 (built-in LED) on your Arduino. You can easily modify the code to control any digital pin.

## Components

### iOS App
- **Language**: Swift
- **Framework**: SwiftUI
- **Communication**: External Accessory Framework
- **Minimum iOS**: iOS 14.0+

### Arduino Sketch
- **Board**: Any Arduino with USB capability (Uno, Mega, Leonardo, etc.)
- **Pin**: Digital pin 13 (configurable)
- **Baud Rate**: 9600

## Important Notes About USB-C Connections

### MFi (Made for iPhone) Considerations

Direct USB communication between iPhone and Arduino typically requires:

1. **MFi Certification**: Apple's External Accessory framework usually requires MFi-certified accessories
2. **Authentication Chip**: Most non-certified devices won't be recognized by iOS

### Recommended Solutions

#### Option 1: USB-C to USB Adapter (Recommended)
Use Apple's official Lightning to USB Camera Adapter or USB-C to USB adapter, which may allow some Arduino boards to communicate.

#### Option 2: Arduino with MFi Chip
Use an Arduino that includes an MFi authentication chip or an MFi-certified shield.

#### Option 3: Bluetooth Low Energy (Alternative)
If direct USB proves problematic, consider using BLE (Bluetooth Low Energy):
- Add an HM-10 or similar BLE module to Arduino
- Modify the iOS app to use CoreBluetooth instead of External Accessory
- This is often more reliable for Arduino-iPhone communication

#### Option 4: WiFi Connection (Alternative)
- Use an ESP32 or Arduino with WiFi capability
- Communicate via HTTP or WebSocket
- No USB cable required

## Setup Instructions

### 1. Arduino Setup

1. Open the Arduino IDE
2. Load the sketch: `Arduino/ArduinoController/ArduinoController.ino`
3. Connect your Arduino to your computer via USB
4. Select your board type: `Tools > Board`
5. Select the correct port: `Tools > Port`
6. Upload the sketch: Click the upload button or press `Cmd+U`

#### Verify Arduino is Working

1. Open Serial Monitor: `Tools > Serial Monitor`
2. Set baud rate to `9600`
3. You should see: `Arduino Ready` and `Controlling Pin: 13`
4. Type `HIGH` and press Enter - the built-in LED should turn on
5. Type `LOW` and press Enter - the built-in LED should turn off

### 2. iOS App Setup

#### Open in Xcode

1. Open Xcode
2. Select `File > Open`
3. Navigate to `ArduinoController/ArduinoController.xcodeproj`
4. Or manually create a new Xcode project and add the Swift files

#### Configure the Project

1. Select your project in the navigator
2. Under "Signing & Capabilities":
   - Select your development team
   - Ensure you have a unique bundle identifier
3. Add External Accessory capability:
   - Click `+ Capability`
   - Search for "External Accessory"
   - Add it to your project

#### Modify Info.plist (if needed)

The `Info.plist` is already configured with:
```xml
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>com.arduino.serial</string>
</array>
```

**Important**: The protocol string `com.arduino.serial` must match what your Arduino reports. For most standard Arduinos without MFi certification, this may need to be adjusted or the connection might not work.

### 3. Connecting iPhone to Arduino

1. Ensure Arduino is powered and running the sketch
2. Connect Arduino to iPhone using:
   - USB-C to USB adapter (if your iPhone has USB-C)
   - Lightning to USB Camera Adapter (for older iPhones)
3. Launch the app on your iPhone
4. The app should detect the Arduino and show "Connected"
5. Tap the toggle button to control pin 13

### 4. Troubleshooting

#### "No accessories found"
- Check physical connection
- Try a different cable or adapter
- Verify Arduino is powered on
- Check if your Arduino requires MFi certification

#### "Arduino not found"
- The protocol string may not match
- Your Arduino may not be recognized by iOS
- Consider using BLE or WiFi alternative

#### App builds but doesn't detect Arduino
- Enable Serial Monitor on Arduino IDE to verify the sketch is running
- Check that External Accessory capability is added
- Verify Info.plist contains the protocol string
- iOS may require MFi-certified accessories

#### Serial communication not working
- Verify baud rate matches (9600) in both Arduino and iOS code
- Check that Arduino Serial Monitor shows messages when typing commands
- Ensure no other application is using the serial port

### 5. Customizing the Pin

To control a different pin, modify the Arduino sketch:

```cpp
const int CONTROL_PIN = 7; // Change 13 to your desired pin number
```

Available pins depend on your Arduino model:
- **Arduino Uno**: Digital pins 0-13
- **Arduino Mega**: Digital pins 0-53
- **Arduino Leonardo**: Digital pins 0-13

Note: Avoid using pins 0 and 1 (RX/TX) as they're used for serial communication.

## Code Structure

### iOS App Files

- `ArduinoControllerApp.swift` - App entry point
- `ContentView.swift` - Main UI with toggle button
- `ArduinoManager.swift` - USB serial communication manager
- `Info.plist` - Configuration including External Accessory protocols

### Arduino Files

- `ArduinoController.ino` - Main Arduino sketch

## Commands

The Arduino accepts these commands via serial:

- `HIGH`, `ON`, `1` - Set pin HIGH (3.3V or 5V depending on Arduino)
- `LOW`, `OFF`, `0` - Set pin LOW (0V)

Commands are case-insensitive and newline-terminated.

## Alternative Implementation: Bluetooth Low Energy

If USB connection is problematic, here's a quick guide to using BLE instead:

### Arduino Side
1. Add an HM-10 or similar BLE module
2. Connect: VCC to 5V, GND to GND, TX to RX, RX to TX
3. Use SoftwareSerial to communicate with the BLE module

### iOS Side
1. Replace External Accessory framework with CoreBluetooth
2. Scan for BLE peripherals
3. Connect and discover services/characteristics
4. Write commands to the characteristic

BLE often provides a more reliable connection for Arduino-iPhone communication.

## Testing Without Hardware

To test the app without Arduino:
1. Modify `ArduinoManager.swift` to simulate connection
2. Set `isConnected = true` in `connectToArduino()`
3. Add mock responses in `sendCommand()`

## Support

For issues or questions:
- Check Arduino serial monitor output
- Review Xcode console for iOS errors
- Ensure all cables and connections are secure
- Consider BLE as a more reliable alternative

## License

This project is provided as-is for educational purposes.
