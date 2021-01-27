//
//  XYCentralManager.swift
//  XYCBCentralManager
//
//  Created by macvivi on 2020/12/30.
//

import UIKit
import CoreBluetooth

typealias ErrorClosure = (Error?)->Void
typealias DataClosure = (Data?,Error?)->Void

class XYCentralManager: NSObject {

    //创建单例
    static let shared = XYCentralManager()
    
    //调用startScan方法后，己经搜索到的信息通过这个属性可以获得
    var scanInfoArray: [ScanInfo] {
        XYCBBase.shared.scanInfoArr as! [ScanInfo]
    }
    
    func startScan(findPeripheral: @escaping (CBPeripheral) -> Void) {
        XYCBBase.shared.startScan { (peripheral) in
            findPeripheral(peripheral)
        }
    }
    
    func stopScan() {
        XYCBBase.shared.stopScan()
    }
    
    //在连接成功，并且发现了外设的所有特征后才给出连接成功的回调
    //连接成功后如果断开，会自动重连。除非调用disConnect方法，调用disConnect方法后不会自动重连了
    func connect(peripheral: CBPeripheral, completions: @escaping (Bool,Error?) -> Void) {
        XYCBBase.shared.connect(peripheral: peripheral) { (isConnect, error) in
            completions(isConnect,error)
        }
    }
    
    func disConnect(peripheral: CBPeripheral) {
        XYCBBase.shared.disConnect(peripheral)
    }
    

    //参数errorClosure:当errorClosure传回的参数为nil时表示订阅成功，否则Error参数会传回订阅失败的原因
    //参数notifyClosure: notifyClosure的参数会传回收到的数据Data,当收到通知时notifyClosure会被调用
    func subscribeNotify(peripheral: CBPeripheral, characteristic: CBCharacteristic, errorClosure: ErrorClosure?, notifyClosure: @escaping DataClosure){
        XYCBBase.shared.subscribeNotify(peripheral: peripheral, characteristic: characteristic, errorClosure: errorClosure, notifyClosure: notifyClosure)
    }
    
    //callBack会传回read到的数据
    func read(peripheral: CBPeripheral, characteristic: CBCharacteristic, callBack: @escaping DataClosure){
        XYCBBase.shared.read(peripheral: peripheral, characteristic: characteristic, callBack: callBack)
    }

}
