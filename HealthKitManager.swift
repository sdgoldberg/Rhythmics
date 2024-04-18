import Foundation
import HealthKit
import WatchConnectivity

class HealthKitManager: NSObject, ObservableObject, HKWorkoutSessionDelegate, WCSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Handle errors that occur during the workout session
        print("Workout session failed with error: \(error.localizedDescription)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle the workout session state changes here
        print("Workout session moved from \(fromState) to \(toState)")
    }

    
    static let shared = HealthKitManager()
    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0

    private var healthStore: HKHealthStore?
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKWorkoutBuilder?
    private var heartRateQuery: HKQuery?
    private var hrvQuery: HKQuery?
    
    let heartRateBaseline = 80.0  // Example baseline for heart rate
    let hrvBaseline = 80.0        // Example baseline for HRV
    
    override init() {
        super.init()
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
        setupSession()
    }

    func setupSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = healthStore else {
            completion(false, NSError(domain: "com.example.HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this Device"]))
            return
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let typesToRead: Set<HKObjectType> = [heartRateType, hrvType]
        let typesToShare: Set<HKSampleType> = [HKObjectType.workoutType()]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other  // Adjust based on your app's focus
        configuration.locationType = .unknown

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore!, configuration: configuration)
            workoutSession?.delegate = self

            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            // There is no delegate to set for workoutBuilder, only for workoutSession

            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date()) { success, error in
                if success {
                    // Data collection started
                    self.startHeartRateMonitoring()
                    self.startHRVMonitoring()
                } else {
                    print("Failed to start data collection: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } catch {
            print("Failed to start workout: \(error.localizedDescription)")
        }
    }



    func endWorkout() {
        workoutBuilder?.endCollection(withEnd: Date()) { success, error in
            if success {
                self.workoutBuilder?.finishWorkout { workout, error in
                    if let workout = workout {
                        print("Workout finished: \(workout)")
                    } else {
                        print("Failed to finish workout: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("Failed to end collection: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        workoutSession?.end()
        stopMonitoring()
    }

    func startHeartRateMonitoring() {
        guard let healthStore = healthStore,
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            self.processHeartRate(samples: samples)
        }

        healthStore.execute(query)
        self.heartRateQuery = query
    }

    func startHRVMonitoring() {
        guard let healthStore = healthStore,
              let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }

        let query = HKAnchoredObjectQuery(type: hrvType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            self.processHRV(samples: samples)
        }

        healthStore.execute(query)
        self.hrvQuery = query
    }

    private func processHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample],
              let sample = heartRateSamples.last else { return }
        
        let newHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        DispatchQueue.main.async {
            self.heartRate = newHeartRate
            if newHeartRate > self.heartRateBaseline {
                self.sendMessageToiPhone()
            }
        }
    }

    private func processHRV(samples: [HKSample]?) {
        guard let hrvSamples = samples as? [HKQuantitySample],
              let sample = hrvSamples.last else { return }

        let newHRV = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
        DispatchQueue.main.async {
            self.hrv = newHRV
            if newHRV < self.hrvBaseline {
                self.sendMessageToiPhone()
            }
        }
    }

    private func stopMonitoring() {
        if let query = heartRateQuery {
            healthStore?.stop(query)
            heartRateQuery = nil
        }
        if let query = hrvQuery {
            healthStore?.stop(query)
            hrvQuery = nil
        }
    }

    private func sendMessageToiPhone() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["Alert": "Abnormality detected"], replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Session activation handling
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received messages from iPhone
    }
}

