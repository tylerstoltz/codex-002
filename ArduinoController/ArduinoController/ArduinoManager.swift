//
//  ArduinoManager.swift
//  ArduinoController
//
//  Manages USB serial communication with Arduino
//

import Foundation
import ExternalAccessory

class ArduinoManager: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var statusMessage: String?

    private var session: EASession?
    private var accessory: EAAccessory?
    private let protocolString = "com.arduino.serial" // This needs to match your Arduino's protocol

    private var inputStream: InputStream?
    private var outputStream: OutputStream?

    override init() {
        super.init()
        setupNotifications()
        checkForConnectedAccessories()
    }

    // MARK: - Setup

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryConnected),
            name: .EAAccessoryDidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDisconnected),
            name: .EAAccessoryDidDisconnect,
            object: nil
        )

        EAAccessoryManager.shared().registerForLocalNotifications()
    }

    // MARK: - Connection Management

    func connectToArduino() {
        checkForConnectedAccessories()
    }

    private func checkForConnectedAccessories() {
        let accessories = EAAccessoryManager.shared().connectedAccessories

        guard !accessories.isEmpty else {
            statusMessage = "No accessories found. Please connect your Arduino via USB-C."
            isConnected = false
            return
        }

        // Find Arduino accessory
        for accessory in accessories {
            if accessory.protocolStrings.contains(protocolString) {
                self.accessory = accessory
                openSession()
                return
            }
        }

        statusMessage = "Arduino not found. Available accessories: \(accessories.map { $0.name }.joined(separator: ", "))"
        isConnected = false
    }

    private func openSession() {
        guard let accessory = accessory else { return }

        session = EASession(accessory: accessory, forProtocol: protocolString)

        guard let session = session else {
            statusMessage = "Failed to create session"
            isConnected = false
            return
        }

        inputStream = session.inputStream
        outputStream = session.outputStream

        inputStream?.delegate = self
        outputStream?.delegate = self

        inputStream?.schedule(in: .current, forMode: .default)
        outputStream?.schedule(in: .current, forMode: .default)

        inputStream?.open()
        outputStream?.open()

        isConnected = true
        statusMessage = "Connected to \(accessory.name)"
    }

    func disconnect() {
        inputStream?.close()
        outputStream?.close()

        inputStream?.remove(from: .current, forMode: .default)
        outputStream?.remove(from: .current, forMode: .default)

        session = nil
        accessory = nil
        isConnected = false
        statusMessage = "Disconnected"
    }

    // MARK: - Communication

    func sendCommand(_ command: String) {
        guard let outputStream = outputStream,
              outputStream.hasSpaceAvailable else {
            statusMessage = "Cannot send data - stream not available"
            return
        }

        let commandData = "\(command)\n"
        let data = commandData.data(using: .utf8)!
        let bytesWritten = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> Int in
            guard let pointer = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }
            return outputStream.write(pointer, maxLength: buffer.count)
        }

        if bytesWritten > 0 {
            statusMessage = "Sent: \(command)"
        } else {
            statusMessage = "Failed to send command"
        }
    }

    // MARK: - Notifications

    @objc private func accessoryConnected(_ notification: Notification) {
        statusMessage = "Accessory connected"
        connectToArduino()
    }

    @objc private func accessoryDisconnected(_ notification: Notification) {
        statusMessage = "Accessory disconnected"
        disconnect()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        disconnect()
    }
}

// MARK: - Stream Delegate

extension ArduinoManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            if aStream == outputStream {
                statusMessage = "Ready to send commands"
            }

        case .hasSpaceAvailable:
            break

        case .hasBytesAvailable:
            if aStream == inputStream {
                readData()
            }

        case .errorOccurred:
            statusMessage = "Stream error occurred"
            isConnected = false

        case .endEncountered:
            statusMessage = "Stream ended"
            disconnect()

        default:
            break
        }
    }

    private func readData() {
        guard let inputStream = inputStream else { return }

        let bufferSize = 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)

        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(&buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                if let response = String(bytes: buffer[0..<bytesRead], encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.statusMessage = "Arduino: \(response.trimmingCharacters(in: .whitespacesAndNewlines))"
                    }
                }
            }
        }
    }
}
