import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var isMonitoring = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject private var healthKitManager = HealthKitManager.shared

    var body: some View {
        VStack {
            Spacer()

            // Display for heart rate
            VStack(spacing: 8) {
                Text("Heart Rate")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(Int(healthKitManager.heartRate)) BPM")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(healthKitManager.heartRate > 100 ? .red : .green)
            }

            // Display for HRV
            VStack(spacing: 8) {
                Text("HRV")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(Int(healthKitManager.hrv)) ms")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(healthKitManager.hrv < healthKitManager.hrvBaseline ? .yellow : .green)
            }

            Spacer()

            // Button for toggling the workout session
            Button(action: toggleWorkoutSession) {
                Text(isMonitoring ? "End Focus Session" : "Start Focus Session")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 45)
                    .background(isMonitoring ? Color.red : Color.green)
                    .cornerRadius(22.5)
            }
            .buttonStyle(PlainButtonStyle())
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.1)) // Subtle background for a calm look
        .edgesIgnoringSafeArea(.all)
    }

    private func toggleWorkoutSession() {
        isMonitoring.toggle()
        if isMonitoring {
            // Request authorization and start the workout
            healthKitManager.requestAuthorization { authorized, error in
                if authorized {
                    healthKitManager.startWorkout()
                    playHaptic(type: .success)
                    alertMessage = "Workout session started successfully!"
                    showAlert = true
                } else {
                    // Handle authorization failure, e.g., show an alert
                    isMonitoring = false  // Reset monitoring state
                    playHaptic(type: .failure)
                    alertMessage = "Authorization failed: \(error?.localizedDescription ?? "Unknown error")"
                    showAlert = true
                }
            }
        } else {
            // End the workout session and stop monitoring
            healthKitManager.endWorkout()
            playHaptic(type: .stop)
            alertMessage = "Workout session ended."
            showAlert = true
        }
    }

    private func playHaptic(type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

