import SwiftUI
import HealthKit
import WatchConnectivity
import CoreBluetooth

struct ContentView: View {
    @State private var isMonitoring = false
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var isAbnormalityTriggered = false // To track if abnormality is active
    //  @State private var spotifyDelegate = SpotifyDelegate()
      @State private var isPlaying = false // To track play/pause state
    @State private var isPulsating = false // New state variable for pulsating effect
    var body: some View {
        NavigationView {
            VStack {
                Text(bluetoothManager.isArduinoConnected ? "Arduino Connected" : "Arduino Not Connected")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)  // Aligning to the top-left corner
                
                Text("Rhythmics")
                    .font(.largeTitle)
                    .padding()
                
                GraphView(heartRateData: [70, 73, 78, 65, 80], hrvData: [60, 65, 68, 63, 70])
                    .frame(height: 200)
                    .padding()
                
                Spacer()
                if !isMonitoring {
                    Text(isMonitoring ? "" : "Previous Session")
                        .font(.headline) // Bold text for the heading
                        .frame(maxWidth: .infinity, alignment: .center) // Center-align the text
                    
                    VStack(spacing: 15) { // Group for the text fields
                        Text("Average Heart Rate: 64 BPM")
                            .font(.body) // Regular body font
                            .frame(maxWidth: .infinity, alignment: .center) // Center-align
                        
                        Text("Average HRV: 80 BPM")
                            .font(.body) // Regular body font
                            .frame(maxWidth: .infinity, alignment: .center) // Center-align
                    }
                }
                Spacer()
                Button(action: {
                    isMonitoring.toggle()
                    if isMonitoring {
                        // Request HealthKit Authorization
                        //   spotifyDelegate.connect()
                        //spotifyDelegate.appRemote.playerAPI?.play("spotify:playlist:37i9dQZF1DWXe9gFZP0gtP?si=TPgVgHAgR1K4tNIZdP78kw&pi=u-4BvE70lvSv68")
                        healthKitManager.requestAuthorization { authorized, error in
                            DispatchQueue.main.async {
                                if authorized {
                                    // Proceed with starting the session
                                    // Start querying for heart rate data, etc.
                                    bluetoothManager.startScanning()  // Start Bluetooth scanning
                                    
                                } else {
                                    // Handle the error or lack of authorization
                                    print("Authorization denied: \(error?.localizedDescription ?? "Unknown error")")
                                    // It might be a good idea to update the UI to reflect that the session //couldn't start
                                    isMonitoring = false
                                }
                            }
                        }
                    } else {
                        // Handle stopping the session
                        bluetoothManager.centralManager.stopScan()
                        print("Stopped Session")
                    }
                }){
                    //TestView()
                    Text(isMonitoring ? "Stop Session" : "Start Session")
                        .foregroundColor(.white)
                        .padding()
                        .background(isMonitoring ? Color.red : Color.blue)
                        .cornerRadius(10)
                        .scaleEffect(isPulsating ? 1.1 : 1.0) // Scale effect for pulsating
                        .animation(
                            Animation.easeInOut(duration: 1.0) // Smooth animation
                                .repeatForever(autoreverses: true), // Repeats with auto-reverse
                            value: isPulsating
                        )
                }
                .onAppear {
                    // Start the pulsating effect when the view appears
                    isPulsating = true
                }
                .onDisappear {
                    // Stop the pulsating effect when the view disappears
                    isPulsating = false
                }
                
                if isMonitoring {
                    HStack {
                        // Previous Track Button
                        Button(action: {
                            print("previous")
                            //        spotifyDelegate.appRemote.playerAPI?.skip(toPrevious: nil) // Go back to the previous track
                        }) {
                            Image(systemName: "backward.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Play/Pause Button
                        Button(action: {
                            if isPlaying {
                            print("playing")
                            //        spotifyDelegate.appRemote.playerAPI?.resume() // Resume playback
                        } else {
                            print("pause")
                            //       spotifyDelegate.appRemote.playerAPI?.pause() // Pause playback
                        }
                               }) {
                            Image(systemName: isPlaying ? "play.fill" : "pause.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Next Track Button
                        Button(action: {
                            print("next")
                            // spotifyDelegate.appRemote.playerAPI?.skip(toNext: nil) // Skip to the next track
                        }) {
                            Image(systemName: "forward.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isAbnormalityTriggered.toggle()  // Toggle the abnormality state
                        if isAbnormalityTriggered {
                            //       spotifyDelegate.playCalmingMusic()
                            bluetoothManager.sendToArduino(data: "1")  // Trigger haptic feedback
                            print("1")
                        } else {
                            //  $spotifyDelegate.onTriggerNormality
                            bluetoothManager.sendToArduino(data: "0")  // Stop haptic feedback
                            print("0")
                        }
                    }) {
                        Text(isAbnormalityTriggered ? "Trigger Normality" : "Trigger Abnormality")
                            .foregroundColor(.white)
                            .padding()
                            .background(isAbnormalityTriggered ? Color.green : Color.orange)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            }
            .padding()
            .background(SoothingGradientBackground()) // Calming background for the entire view
            .navigationBarTitle("Rhythmics", displayMode: .inline)
        }
        
    }
}
struct GraphView: View {
    var heartRateData: [Double]
    var hrvData: [Double]
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.blue.opacity(0.1) // Calming background color
                
                // Heart Rate Path
                Path { path in
                    for (index, dataPoint) in heartRateData.enumerated() {
                        let xPosition = geometry.size.width / CGFloat(heartRateData.count) * CGFloat(index)
                        let yPosition = (1 - dataPoint / 200) * geometry.size.height // Normalize data point
                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                .stroke(Color.red, lineWidth: 2)
                
                // HRV Path
                Path { path in
                    for (index, dataPoint) in hrvData.enumerated() {
                        let xPosition = geometry.size.width / CGFloat(hrvData.count) * CGFloat(index)
                        let yPosition = (1 - dataPoint / 200) * geometry.size.height // Normalize data point
                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                .stroke(Color.green, lineWidth: 2)
                
                // Adding Labels
                VStack {
                    HStack {
                        Text("HRV")
                            .foregroundColor(.green)
                            .offset(x: 5, y: 0)
                        Spacer()
                        Text("Heart Rate")
                            .foregroundColor(.red)
                            .offset(x: -5, y: 0)
                    }
                    Spacer()
                    Text("Time →")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
            }
        }
    }
}

// Reusable gradient background
struct SoothingGradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(red: 0.6, green: 0.85, blue: 1.0), // Soft blue
                    Color(red: 0.8, green: 1.0, blue: 0.8)  // Soft green
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all) // Cover the whole screen
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
