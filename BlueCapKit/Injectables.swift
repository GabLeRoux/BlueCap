//
//  Injectables.swift
//  BlueCapKit
//
//  Created by Troy Stribling on 4/20/16.
//  Copyright © 2016 Troy Stribling. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - CBCentralManagerInjectable -
public protocol CBCentralManagerInjectable {
    var state : CBManagerState { get }
    var delegate: CBCentralManagerDelegate? { get set }
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    func stopScan()
    func connect(_ peripheral: CBPeripheralInjectable, options: [String : Any]?)
    func cancelPeripheralConnection(_ peripheral: CBPeripheralInjectable)
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralInjectable]
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralInjectable]
}

extension CBCentralManager : CBCentralManagerInjectable {

    public func connect(_ peripheral: CBPeripheralInjectable, options: [String : Any]?) {
        self.connect(peripheral as! CBPeripheral, options: options)
    }

    public func cancelPeripheralConnection(_ peripheral: CBPeripheralInjectable) {
        self.cancelPeripheralConnection(peripheral as! CBPeripheral)
    }

    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheralInjectable] {
        let peripherals = self.retrieveConnectedPeripherals(withServices: serviceUUIDs) as [CBPeripheral]
        return  peripherals.map { $0 as CBPeripheralInjectable }
    }

    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheralInjectable] {
        let peripherals = self.retrievePeripherals(withIdentifiers: identifiers) as [CBPeripheral]
        return  peripherals.map { $0 as CBPeripheralInjectable }
    }
}

// MARK: - CBPeripheralInjectable -
public protocol CBPeripheralInjectable {
    var name: String? { get }
    var state: CBPeripheralState { get }
    var identifier: UUID { get }
    var delegate: CBPeripheralDelegate? { get set }

    func readRSSI()
    func discoverServices(_ services: [CBUUID]?)
    func discoverCharacteristics(_ characteristics: [CBUUID]?, forService service: CBServiceInjectable)
    func setNotifyValue(_ enabled:Bool, forCharacteristic characteristic: CBCharacteristicInjectable)
    func readValueForCharacteristic(_ characteristic: CBCharacteristicInjectable)
    func writeValue(_ data:Data, forCharacteristic characteristic: CBCharacteristicInjectable, type: CBCharacteristicWriteType)

    func getServices() -> [CBServiceInjectable]?
}

extension CBPeripheral : CBPeripheralInjectable {

    public func discoverCharacteristics(_ characteristics:[CBUUID]?, forService service: CBServiceInjectable) {
        self.discoverCharacteristics(characteristics, for: service as! CBService)
    }

    public func setNotifyValue(_ enabled: Bool, forCharacteristic characteristic: CBCharacteristicInjectable) {
        self.setNotifyValue(enabled, for: characteristic as! CBCharacteristic)
    }

    public func readValueForCharacteristic(_ characteristic: CBCharacteristicInjectable) {
        self.readValue(for: characteristic as! CBCharacteristic)
    }

    public func writeValue(_ data: Data, forCharacteristic characteristic: CBCharacteristicInjectable, type: CBCharacteristicWriteType) {
        self.writeValue(data, for: characteristic as! CBCharacteristic, type: type)
    }

    public func getServices() -> [CBServiceInjectable]? {
        guard let services = self.services else { return nil }
        return services.map{ $0 as CBServiceInjectable }
    }
    
}

// MARK: - CBServiceInjectable -
public protocol CBServiceInjectable {
    var UUID: CBUUID { get }
    func getCharacteristics() -> [CBCharacteristicInjectable]?
}

extension CBService : CBServiceInjectable {
    public func getCharacteristics() -> [CBCharacteristicInjectable]? {
        guard let characteristics = self.characteristics else { return nil }
        return characteristics.map{ $0 as CBCharacteristicInjectable }
    }
}

// MARK: - CBCharacteristicInjectable -
public protocol CBCharacteristicInjectable {
    var UUID: CBUUID { get }
    var value: Data? { get }
    var properties: CBCharacteristicProperties { get }
    var isNotifying: Bool { get }
}

extension CBCharacteristic : CBCharacteristicInjectable {}

// MARK: - CBPeripheralManagerInjectable -
public protocol CBPeripheralManagerInjectable {
    var delegate: CBPeripheralManagerDelegate? { get set }
    var isAdvertising: Bool { get }
    var state: CBManagerState { get }
    func startAdvertising(_ advertisementData : [String : Any]?)
    func stopAdvertising()
    func add(_ service: CBMutableServiceInjectable)
    func remove(_ service: CBMutableServiceInjectable)
    func removeAllServices()
    func respondToRequest(_ request: CBATTRequestInjectable, withResult result: CBATTError.Code)
    func updateValue(_ value: Data, forCharacteristic characteristic: CBMutableCharacteristicInjectable, onSubscribedCentrals centrals: [CBCentralInjectable]?) -> Bool
}

extension CBPeripheralManager: CBPeripheralManagerInjectable {

    open func add(_ service: CBMutableServiceInjectable) {
        self.add(service as! CBMutableService)
    }

    open func remove(_ service: CBMutableServiceInjectable) {
        self.remove(service as! CBMutableService)
    }

    open func respondToRequest(_ request: CBATTRequestInjectable, withResult result: CBATTError.Code) {
        self.respond(to: request as! CBATTRequest, withResult: result)
    }

    open func updateValue(_ value: Data, forCharacteristic characteristic: CBMutableCharacteristicInjectable, onSubscribedCentrals centrals: [CBCentralInjectable]?) -> Bool {
        return self.updateValue(value, for: characteristic as! CBMutableCharacteristic, onSubscribedCentrals: centrals as! [CBCentral]?)
    }

}

// MARK: - CBMutableServiceInjectable -
public protocol CBMutableServiceInjectable : CBServiceInjectable {
    func setCharacteristics(_ characteristics: [CBCharacteristicInjectable]?)
}

extension CBMutableService : CBMutableServiceInjectable {
    public func setCharacteristics(_ characteristics: [CBCharacteristicInjectable]?) {
        self.characteristics = characteristics?.map { $0 as! CBCharacteristic }
    }
}

// MARK: - CBMutableCharacteristicInjectable -
public protocol CBMutableCharacteristicInjectable : CBCharacteristicInjectable {
    var permissions: CBAttributePermissions { get }
}

extension CBMutableCharacteristic : CBMutableCharacteristicInjectable {}


// MARK: - CBATTRequestInjectable -
public protocol CBATTRequestInjectable {
    var offset: Int { get }
    var value: Data? { get set }
    func getCharacteristic() -> CBCharacteristicInjectable
}

extension CBATTRequest: CBATTRequestInjectable {
    public func getCharacteristic() -> CBCharacteristicInjectable {
        return self.characteristic
    }
}

// MARK: - CBCentralInjectable -
public protocol CBCentralInjectable {
    var identifier: UUID { get }
    var maximumUpdateValueLength: Int { get }
}

extension CBCentral: CBCentralInjectable {}

