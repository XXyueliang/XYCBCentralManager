//
//  XYPeripheralInfoVC.swift
//  XYCBCentralManager
//
//  Created by macvivi on 2021/1/4.
//

import UIKit
import CoreBluetooth

class XYPeripheralInfoVC: UIViewController {
    
    var scanInfo: ScanInfo?
    var peripheral: CBPeripheral?
    
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var uuidLabel: UILabel!
    @IBOutlet var advLabel: UILabel!
    
    @IBOutlet var advHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var tableView: UITableView!
    
    var advIsHidden = true
    @IBAction func advBtnClick(_ sender: Any) {
        if advIsHidden {
            advIsHidden = false
            advHeightConstraint.priority = .fittingSizeLevel
        }else {
            advIsHidden = true
            advHeightConstraint.priority = .required
            advHeightConstraint.constant = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "服务"
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
    }
    
    func loadData(){
        nameLabel.text = "设备名：" + (scanInfo?.peripheral.name)!
        uuidLabel.text = "uuid:" + (scanInfo?.peripheral.identifier.uuidString)!

        advLabel.text = "\(String(describing: scanInfo?.advertisementData))"
        peripheral = scanInfo?.peripheral
        
    }
    
    deinit {
        XYCentralManager.shared.disConnect(peripheral: peripheral!)
    }
    


}



extension XYPeripheralInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let peripheral = peripheral {
            return peripheral.services?.count ?? 0
        }else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let services = peripheral?.services {
            let service: CBService = services[section]
            return  "service：" + service.uuid.uuidString
        }
        return ""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let services = peripheral?.services {
            let service: CBService = services[section]
            return service.characteristics?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let services = peripheral?.services {
            let service: CBService = services[indexPath.section]
            if let characteristics = service.characteristics {
                let characteristic: CBCharacteristic = characteristics[indexPath.row]
                cell.textLabel?.text = characteristic.uuid.uuidString
                cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
                cell.detailTextLabel?.text = characteristic.dealCharacteristicProperties()
            }
            }
        return cell
    }
    
    
}

extension XYPeripheralInfoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let view = view as! UITableViewHeaderFooterView
        view.textLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let services = peripheral?.services {
            let service: CBService = services[indexPath.section]
            if let characteristics = service.characteristics {
                let characteristic: CBCharacteristic = characteristics[indexPath.row]
                let vc: XYCharacteristicVC = XYHelper.getViewController(storyboardStr: nil, viewController: "XYCharacteristicVC") as! XYCharacteristicVC
                vc.characteristic = characteristic
                vc.peripheral = peripheral
                navigationController?.pushViewController(vc, animated: true)
            }
            }
    }
}
