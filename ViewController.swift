//
//  ViewController.swift
//  Rhythmics
//
//  Created by Sam Goldberg on 4/14/24.
//
import UIKit
import HealthKit

class ViewController: UIViewController {
    let healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestHealthKitAuthorization()
    }

    func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { (success, error) in
            if success {
                // Permissions granted
                print("HealthKit permission granted.")
            } else {
                // Handle errors
                print("HealthKit permission denied. Error: \(String(describing: error))")
            }
        }
    }
}
