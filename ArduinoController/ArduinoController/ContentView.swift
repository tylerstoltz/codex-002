import SwiftUI

struct ContentView: View {
    @StateObject private var arduinoManager = ArduinoManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Connection Status
                VStack(spacing: 10) {
                    Image(systemName: arduinoManager.isConnected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 60))
                        .foregroundColor(arduinoManager.isConnected ? .green : .gray)

                    Text(arduinoManager.connectionStatus)
                        .font(.headline)
                        .foregroundColor(arduinoManager.isConnected ? .green : .secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 50)

                Spacer()

                // Pin Control Section
                VStack(spacing: 20) {
                    Text("Digital Pin Control")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Pin 13")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    // Toggle Button
                    Button(action: {
                        arduinoManager.togglePin()
                    }) {
                        ZStack {
                            Circle()
                                .fill(arduinoManager.pinState ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 150, height: 150)
                                .shadow(color: arduinoManager.pinState ? .green.opacity(0.5) : .clear, radius: 20)

                            VStack(spacing: 8) {
                                Image(systemName: arduinoManager.pinState ? "power" : "power")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)

                                Text(arduinoManager.pinState ? "ON" : "OFF")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(!arduinoManager.isConnected)
                    .animation(.spring(), value: arduinoManager.pinState)

                    // Status indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(arduinoManager.pinState ? Color.green : Color.red)
                            .frame(width: 12, height: 12)

                        Text(arduinoManager.pinState ? "Pin is HIGH" : "Pin is LOW")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Reconnect Button
                Button(action: {
                    arduinoManager.reconnect()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reconnect")
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                // Instructions
                VStack(spacing: 8) {
                    Text("Instructions:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text("1. Upload the Arduino sketch to your Arduino")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("2. Connect Arduino to iPhone via USB-C")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("3. Tap Reconnect if needed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Arduino Controller")
            .onAppear {
                arduinoManager.checkForConnectedAccessories()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
