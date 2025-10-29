# Arduino iOS Controller

A Swift iOS application that allows you to control an Arduino's digital I/O pins via USB-C connection.

## Features

- Simple toggle button interface
- Real-time connection status
- Visual feedback (LED indicator on app)
- Controls Arduino digital pin 13 (configurable)
- USB-C communication using External Accessory Framework

## Project Structure

```
.
├── ArduinoController/          # iOS App (Swift/SwiftUI)
│   ├── ArduinoController/
│   │   ├── ArduinoControllerApp.swift    # App entry point
│   │   ├── ContentView.swift              # Main UI
│   │   ├── ArduinoManager.swift           # USB communication
│   │   └── Info.plist                     # Configuration
│   └── ArduinoController.xcodeproj        # Xcode project
│
├── Arduino/                    # Arduino Sketch
│   └── ArduinoController/
│       └── ArduinoController.ino          # Arduino code
│
├── SETUP.md                    # Detailed setup instructions
└── README.md                   # This file
```

## Quick Start

### Arduino Setup
1. Open `Arduino/ArduinoController/ArduinoController.ino` in Arduino IDE
2. Upload to your Arduino board
3. Verify it works using Serial Monitor (type `HIGH` or `LOW`)

### iOS App Setup
1. Open `ArduinoController/ArduinoController.xcodeproj` in Xcode
2. Select your development team
3. Build and run on your iPhone

### Connect
1. Connect Arduino to iPhone via USB-C adapter
2. Launch the app
3. Tap "Connect to Arduino"
4. Use the toggle button to control pin 13

## Important Notes

- **MFi Certification**: Direct USB communication may require MFi-certified Arduino or adapter
- **Alternative Solutions**: Consider Bluetooth Low Energy (BLE) or WiFi for more reliable connections
- **Pin Configuration**: Default is pin 13 (built-in LED), easily changeable in Arduino code

## Documentation

See [SETUP.md](SETUP.md) for:
- Detailed setup instructions
- Troubleshooting guide
- Alternative connection methods (BLE, WiFi)
- Pin customization
- MFi considerations

## Requirements

- **iOS**: iOS 14.0 or later
- **Arduino**: Any Arduino with USB capability (Uno, Mega, Leonardo, etc.)
- **Xcode**: Xcode 12.0 or later
- **Cable**: USB-C to USB adapter or Lightning to USB Camera Adapter

## Commands

The Arduino accepts these serial commands:
- `HIGH`, `ON`, `1` → Set pin HIGH
- `LOW`, `OFF`, `0` → Set pin LOW

## License

This project is provided as-is for educational purposes.