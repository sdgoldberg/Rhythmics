//
//  HealthKitManager.swift
//  Rhythmics
//
//  Created by Sam Goldberg on 4/14/24.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    @Published var heartRate: Double = 0 // Use @Published for properties that can change
    @Published var hrv: Double = 0
    private var healthStore: HKHealthStore?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Make sure the healthStore is initialized and available.
        guard let healthStore = self.healthStore else {
            completion(false, NSError(domain: "com.example.HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available in this Device"]))
            return
        }
        
        // Define the types you want to read from HK Store
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        
        // Request Authorization
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // Add functions to start queries for heart rate and HRV data
    
}
