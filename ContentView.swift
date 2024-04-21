import SwiftUI
import HealthKit
import WatchConnectivity
import CoreBluetooth

struct ContentView: View {
    @State private var isMonitoring = false
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var isAbnormalityTriggered = false // To track if abnormality is active

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

                Button(action: {
                    isMonitoring.toggle()
                    if isMonitoring {
                        // Request HealthKit Authorization
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
                    Text(isMonitoring ? "Stop Session" : "Start Session")
                        .foregroundColor(.white)
                        .padding()
                        .background(isMonitoring ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                if isMonitoring {
                    Button(action: {
                        isAbnormalityTriggered.toggle()  // Toggle the abnormality state
                        if isAbnormalityTriggered {
                            bluetoothManager.sendToArduino(data: "1")  // Trigger haptic feedback
                            print("1")
                        } else {
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
            .background(Color.blue.opacity(0.1)) // Calming background for the entire view
            .navigationBarTitle("Rhythmics", displayMode: .inline)
        }
    }
    // new code here
    
    
    
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
