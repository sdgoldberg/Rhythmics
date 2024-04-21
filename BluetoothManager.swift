//
//  BluetoothManager.swift
//  Rhythmics
//
//  Created by Sam Goldberg on 4/21/24.
//

import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isBluetoothAvailable = false
    @Published var isArduinoConnected = false
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var txCharacteristic: CBCharacteristic?
    var rxCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() -> Void {
        // Start Scanning
        centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
        
    }
    
    func sendToArduino(data: String) {
        if let peripheral = discoveredPeripheral {
            // Find the characteristic to write data to
            for service in peripheral.services ?? [] {
                for characteristic in service.characteristics ?? [] {
                    print(characteristic.uuid)
                    if characteristic.uuid == CBUUIDs.BLE_Characteristic_uuid_Rx {
                        // Write data to the characteristic
                        peripheral.writeValue(data.data(using: .utf8)!, for: characteristic, type: .withResponse)
                        return
                    }
                }
            }
        }
    }
    
        
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            
            switch central.state {
            case .poweredOff:
                isBluetoothAvailable = false
                print("Is Powered Off.")
            case .poweredOn:
                print("Is Powered On.")
                isBluetoothAvailable = true
                startScanning()
            case .unsupported:
                isBluetoothAvailable = false
                print("Is Unsupported.")
            case .unauthorized:
                isBluetoothAvailable = false
                print("Is Unauthorized.")
            case .unknown:
                isBluetoothAvailable = false
                print("Unknown")
            case .resetting:
                isBluetoothAvailable = false
                print("Resetting")
            @unknown default:
                print("Error")
            }
        }
    
    
        // CBPeripheralDelegate method
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        for service in peripheral.services ?? [] {
            print("Discovered service \(service.uuid)")
            // Optionally, start discovering characteristics here
            peripheral.discoverCharacteristics(nil, for: service) // Pass nil to discover all characteristics of the service
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == CBUUIDs.BLE_Characteristic_uuid_Rx {
                txCharacteristic = characteristic
            } else if characteristic.uuid == CBUUIDs.BLE_Characteristic_uuid_Tx {
                rxCharacteristic = characteristic
                // Subscribe to notifications for the receiving characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
            return
        }
        
        if characteristic.uuid == CBUUIDs.BLE_Characteristic_uuid_Tx {
            if let value = characteristic.value {
                let data = String(data: value, encoding: .utf8)
                print("Received data: \(data ?? "")")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Basic details
        print("Discovered \(peripheral.name ?? "unknown") at \(RSSI) dBm")
        
        // More detailed advertisement data
        for (key, value) in advertisementData {
            print("\(key): \(value)")
        }
        
        centralManager.stopScan()
        discoveredPeripheral = peripheral
        
        central.connect(peripheral, options: nil)
        // Example: Optionally connect to the peripheral here
        // central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isArduinoConnected = true
        print("Connected to \(peripheral.name ?? "unknown")")
        
        // Optionally, start discovering services here or set the peripheral delegate
        // Set the peripheral delegate
        peripheral.delegate = self
        // Discover services and characteristics
        peripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
    
    // Handle connection failures
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isArduinoConnected = false
        print("Failed to connect to \(peripheral.name ?? "unknown") with error: \(error?.localizedDescription ?? "no error")")
        
        // Clean up
    }
    
    // Handle disconnections
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isArduinoConnected = false
        print("Disconnected from \(peripheral.name ?? "unknown") with error: \(error?.localizedDescription ?? "no error")")
        
        // Optionally, you may want to reconnect or clean up resources here
    }
    
}

