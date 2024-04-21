//
//  CBUUIDS.swift
//  Rhythmics
//
//  Created by Sam Goldberg on 4/18/24.
//

import Foundation
import CoreBluetooth

struct CBUUIDs{
    
    
    static let kBLEService_UUID = "12345678-1234-5678-1234-56612abcdef5"
    static let kBLE_Characteristic_uuid_Tx = "12345678-1234-5678-1234-56612abcdef6"
    static let kBLE_Characteristic_uuid_Rx = "12345678-1234-5678-1234-56612abcdef7"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    // READING FROM ARDUINO
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
    //SENDING TO ARDUINO
}

