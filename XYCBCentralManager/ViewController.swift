//
//  ViewController.swift
//  XYCBCentralManager
//
//  Created by macvivi on 2020/12/30.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    
    var scanInfoArr: [ScanInfo] = []
    
    @IBAction func rightBarBtnClick(_ sender: Any) {
        startScan()
    }
    
    @IBAction func leftBarBtnClick(_ sender: Any) {
        XYCentralManager.shared.stopScan()
        syncData()
    }
    
    func startScan(){
        XYCentralManager.shared.startScan { (peripheral) in
            self.syncData()
        }
    }
    
    func syncData() {
        self.scanInfoArr = XYCentralManager.shared.scanInfoArray
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        startScan()
    }
    


}

extension ViewController:  UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scanInfoArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let scanInfo: ScanInfo = scanInfoArr[indexPath.row]
        cell.textLabel?.text = scanInfo.peripheralName != nil ? scanInfo.peripheralName : scanInfo.peripheral.name
        cell.detailTextLabel?.text = scanInfo.peripheral.identifier.uuidString
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral: CBPeripheral = scanInfoArr[indexPath.row].peripheral
        XYCentralManager.shared.connect(peripheral: peripheral) { (isConnect, error) in
            if(isConnect){
//                printXY("连接成功", obj: self, line: #line)
                let vc: XYPeripheralInfoVC = XYHelper.getViewController(storyboardStr: nil, viewController: "XYPeripheralInfoVC") as! XYPeripheralInfoVC
                vc.scanInfo = self.scanInfoArr[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                print("连接失败")
            }
        }
    }
}
