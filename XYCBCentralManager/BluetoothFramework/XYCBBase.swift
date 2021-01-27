//
//  XYCBBase.swift
//  XYCBCentralManager
//
//  Created by macvivi on 2020/12/30.
//

import UIKit
import CoreBluetooth

class ScanInfo: NSObject {
    var peripheral: CBPeripheral
    var advertisementData: [String : Any]
    var rssi: NSNumber 
    init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }

    var peripheralName: String? {
        guard self.advertisementData["kCBAdvDataLocalName"] != nil else {
            return nil
        }
        return self.advertisementData["kCBAdvDataLocalName"] as! String
    }
    override func isEqual(_ object: Any?) -> Bool {
        let object: ScanInfo = object as! ScanInfo
       return self.peripheral.identifier == object.peripheral.identifier ? true : false
    }
}



class XYCBBase: NSObject {
    //创建单例
    static let shared = XYCBBase()
    override init() {
        super.init()
        xyCentralManager.delegate = self
        
    }
    
    var xyCentralManager: CBCentralManager = CBCentralManager()
    var scanInfoArr = NSMutableArray()
    //蓝牙是否可以
    var managerStateIsOn = false
    
    typealias FindPeripheral = (CBPeripheral) -> Void
    var findPeripheralClosure: FindPeripheral = {_ in }
    //MARK: 第一步: 搜索外设
    func startScan(findPeripheral: @escaping (CBPeripheral) -> Void) {
        scanInfoArr = NSMutableArray()
       findPeripheralClosure = findPeripheral
       xyCentralManager.scanForPeripherals(withServices: nil, options: nil)
        managerStateIsOn = xyCentralManager.state != CBManagerState.poweredOn ? false : true
        
    }
    
    func stopScan() {
        xyCentralManager.stopScan()
        scanInfoArr = NSMutableArray()
    }
    
    typealias Completion = (Bool,Error?) -> Void
    var connetCompletion: Completion?
    //MARK: 第二步: 连接外设
    func connect(peripheral: CBPeripheral, completion: @escaping (Bool,Error?) -> Void) {
        connetCompletion = completion
        xyCentralManager.connect(peripheral, options: nil)
    }
    
    //是否disConnect方法被调用了，如果被调用了就不会自动重连了
    var isDisConnect = false
    func disConnect(_ peripheral: CBPeripheral) {
        isDisConnect = true
        xyCentralManager.cancelPeripheralConnection(peripheral)
    }
    
    var notifyErrorClosure: ErrorClosure?
    var notifyClosure: DataClosure?
    
    //参数errorClosure:当errorClosure传回的参数为nil时表示订阅成功，否则Error参数会传回订阅失败的原因
    //参数notifyClosure: notifyClosure的参数会传回收到的数据Data,当收到通知时notifyClosure会被调用
    func subscribeNotify(peripheral: CBPeripheral, characteristic: CBCharacteristic, errorClosure: ErrorClosure?, notifyClosure: @escaping DataClosure){
        self.notifyClosure = notifyClosure
        self.notifyErrorClosure = errorClosure
        //characteristic的value变化时会收到通知
        peripheral.setNotifyValue(true, for: characteristic)
        
    }
    
    var readCallBack: DataClosure?
    //callBack会传回read到的数据
    func read(peripheral: CBPeripheral, characteristic: CBCharacteristic, callBack: @escaping DataClosure){
        readCallBack = callBack
        peripheral.readValue(for: characteristic)
    }

}

extension XYCBBase: CBCentralManagerDelegate {
    //MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if managerStateIsOn == false {
            xyCentralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == nil {
            return
        }
        let scanInfo = ScanInfo(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        //MARK: 第一步: 搜到了外设
        //先remove后add,去重，而且保证数组里的是最新的
        if scanInfoArr.contains(scanInfo) {
            scanInfoArr.remove(scanInfo)
        }
        scanInfoArr.add(scanInfo)
        
        findPeripheralClosure(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        printXY(#function, obj: self, line: #line)
        if isDisConnect {
            isDisConnect = false
            return
        }
        connect(peripheral: peripheral) { (bool, error) in
            if bool {
                printXY("重连成功", obj: self, line: #line)
            }else {
                print(error)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //MARK: 第二步: 连接外设成功
        printXY(#function, obj: self, line: #line)
        //MARK: 第三步: 搜索外设的服务
        peripheral.delegate = self
        //必须要搜索服务，搜到后peripheral.sevices数组中才会有值，否则是空的，搜到一个服务，才会多一个服务
        //在这里po peripheral.services为nil
        peripheral.discoverServices(nil)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let closure = connetCompletion {
            closure(false,error)
        }
    }
}

extension XYCBBase: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        print("发现外设的服务\(String(describing: peripheral.services))")
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            //MARK: 第四步: 搜索外设的特征
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        print("发现服务的特征\(String(describing: service.characteristics))")
        if peripheral.services?.last == service {
            printXY("发现了外设的所有特征，准备就绪", obj: self, line: #line)
            guard let closure = connetCompletion else {
                return
            }
            closure(true,nil)
        }
        guard let characteristics = service.characteristics else {
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        print(error)
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        print(#function)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print(#function)
    }
    
    //readValue
    //setNotifyValue
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        print(characteristic)
        if characteristic.isNotifying {
            if let closure = self.notifyClosure {
                closure(characteristic.value,error)
            }            
        }else {
            if let closure = self.readCallBack {
                closure(characteristic.value,error)
            }
        }
    }
    
    //setNotifyValue
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        if let closure = self.notifyErrorClosure {
            closure(error)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print(#function)
        print(invalidatedServices)
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print(peripheral.canSendWriteWithoutResponse)
        print(#function)
    }
    
    
}

extension CBCharacteristic {
    func dealCharacteristicProperties() -> String {
        var str = "属性："
        if self.properties.contains(.write) {
            str += "/可写"
        }
        if self.properties.contains(.read) {
            str += "/可读"
        }
        if self.properties.contains(.notify) {
            str += "/通知"
        }
        if self.properties.contains(.writeWithoutResponse) {
            str += "/写无回复"
        }
        print(properties.rawValue)
        print(self.uuid.uuidString)
        return str
    }
}
