//
//  ContentView.swift
//  ArduinoController
//
//  Main view with Arduino control interface
//

import SwiftUI

struct ContentView: View {
    @StateObject private var arduinoManager = ArduinoManager()
    @State private var isPinHigh = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Connection status
                HStack {
                    Circle()
                        .fill(arduinoManager.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(arduinoManager.isConnected ? "Connected" : "Disconnected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()

                // Pin status display
                VStack(spacing: 10) {
                    Text("Digital Pin 13")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(isPinHigh ? "HIGH" : "LOW")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(isPinHigh ? .green : .red)
                        .padding()
                        .frame(width: 200, height: 200)
                        .background(
                            Circle()
                                .fill(isPinHigh ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        )
                }
                .padding()

                // Toggle button
                Button(action: {
                    isPinHigh.toggle()
                    arduinoManager.sendCommand(isPinHigh ? "HIGH" : "LOW")
                }) {
                    HStack {
                        Image(systemName: isPinHigh ? "lightbulb.fill" : "lightbulb")
                            .font(.title2)
                        Text(isPinHigh ? "Turn OFF" : "Turn ON")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(isPinHigh ? Color.red : Color.green)
                    .cornerRadius(12)
                }
                .disabled(!arduinoManager.isConnected)

                // Connection controls
                VStack(spacing: 15) {
                    if !arduinoManager.isConnected {
                        Button("Connect to Arduino") {
                            arduinoManager.connectToArduino()
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Disconnect") {
                            arduinoManager.disconnect()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding()

                Spacer()

                // Status messages
                if let message = arduinoManager.statusMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationTitle("Arduino Controller")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
