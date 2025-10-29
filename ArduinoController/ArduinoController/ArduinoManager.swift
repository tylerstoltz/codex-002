import Foundation
import ExternalAccessory

class ArduinoManager: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var connectionStatus = "Disconnected"
    @Published var pinState = false

    private var session: EASession?
    private var accessory: EAAccessory?
    private var readData = Data()

    // Protocol string - this should match what's defined in Info.plist
    // For generic USB CDC devices, we'll use a common protocol
    private let protocolString = "com.arduino.usb"

    override init() {
        super.init()
        setupNotifications()
        checkForConnectedAccessories()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        closeSession()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDidConnect),
            name: .EAAccessoryDidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDidDisconnect),
            name: .EAAccessoryDidDisconnect,
            object: nil
        )

        EAAccessoryManager.shared().registerForLocalNotifications()
    }

    @objc private func accessoryDidConnect(notification: Notification) {
        guard let accessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory else {
            return
        }

        print("Accessory connected: \(accessory.name)")
        print("Manufacturer: \(accessory.manufacturer)")
        print("Model: \(accessory.modelNumber)")
        print("Serial: \(accessory.serialNumber)")
        print("Protocols: \(accessory.protocolStrings)")

        connectToAccessory(accessory)
    }

    @objc private func accessoryDidDisconnect(notification: Notification) {
        guard let accessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory else {
            return
        }

        if accessory == self.accessory {
            closeSession()
            DispatchQueue.main.async {
                self.isConnected = false
                self.connectionStatus = "Disconnected"
            }
        }
    }

    func checkForConnectedAccessories() {
        let connectedAccessories = EAAccessoryManager.shared().connectedAccessories

        print("Found \(connectedAccessories.count) connected accessories")

        for accessory in connectedAccessories {
            print("Accessory: \(accessory.name)")
            print("  Manufacturer: \(accessory.manufacturer)")
            print("  Model: \(accessory.modelNumber)")
            print("  Protocols: \(accessory.protocolStrings)")

            // Try to connect to any accessory that supports our protocol
            if accessory.protocolStrings.contains(protocolString) {
                connectToAccessory(accessory)
                return
            }
        }

        // If no accessory with our specific protocol, try the first one
        if let firstAccessory = connectedAccessories.first {
            // Try with the first available protocol
            if let protocol = firstAccessory.protocolStrings.first {
                connectToAccessory(firstAccessory, protocol: protocol)
            }
        } else {
            DispatchQueue.main.async {
                self.connectionStatus = "No Arduino found. Please connect your Arduino."
            }
        }
    }

    private func connectToAccessory(_ accessory: EAAccessory, protocol: String? = nil) {
        let protocolToUse = protocol ?? protocolString

        guard accessory.protocolStrings.contains(protocolToUse) else {
            print("Accessory doesn't support protocol: \(protocolToUse)")
            return
        }

        self.accessory = accessory
        self.session = EASession(accessory: accessory, forProtocol: protocolToUse)

        guard let session = self.session else {
            print("Failed to create session")
            DispatchQueue.main.async {
                self.connectionStatus = "Failed to connect"
            }
            return
        }

        // Configure streams
        session.inputStream?.delegate = self
        session.inputStream?.schedule(in: .current, forMode: .default)
        session.inputStream?.open()

        session.outputStream?.schedule(in: .current, forMode: .default)
        session.outputStream?.open()

        DispatchQueue.main.async {
            self.isConnected = true
            self.connectionStatus = "Connected to \(accessory.name)"
        }

        print("Successfully connected to \(accessory.name)")
    }

    private func closeSession() {
        session?.inputStream?.close()
        session?.inputStream?.remove(from: .current, forMode: .default)
        session?.inputStream?.delegate = nil

        session?.outputStream?.close()
        session?.outputStream?.remove(from: .current, forMode: .default)

        session = nil
        accessory = nil
    }

    func togglePin() {
        pinState.toggle()
        sendCommand(pinState ? "ON" : "OFF")
    }

    func sendCommand(_ command: String) {
        guard let outputStream = session?.outputStream,
              outputStream.hasSpaceAvailable else {
            print("Output stream not available")
            return
        }

        let data = (command + "\n").data(using: .utf8)!
        let bytesWritten = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> Int in
            guard let pointer = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }
            return outputStream.write(pointer, maxLength: buffer.count)
        }

        if bytesWritten > 0 {
            print("Sent command: \(command)")
        } else {
            print("Failed to send command")
        }
    }

    func reconnect() {
        closeSession()
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionStatus = "Reconnecting..."
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkForConnectedAccessories()
        }
    }
}

extension ArduinoManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            print("Stream opened")

        case .hasBytesAvailable:
            if let inputStream = aStream as? InputStream {
                var buffer = [UInt8](repeating: 0, count: 1024)
                let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)

                if bytesRead > 0 {
                    let data = Data(bytes: buffer, count: bytesRead)
                    readData.append(data)

                    if let response = String(data: data, encoding: .utf8) {
                        print("Received: \(response)")
                    }
                }
            }

        case .hasSpaceAvailable:
            print("Stream has space available")

        case .errorOccurred:
            print("Stream error occurred")
            DispatchQueue.main.async {
                self.connectionStatus = "Connection error"
            }

        case .endEncountered:
            print("End of stream")
            closeSession()
            DispatchQueue.main.async {
                self.isConnected = false
                self.connectionStatus = "Connection closed"
            }

        default:
            break
        }
    }
}
