//
//  XYCharacteristicVC.swift
//  XYCBCentralManager
//
//  Created by macvivi on 2021/1/16.
//

import UIKit
import CoreBluetooth

class XYCharacteristicVC: UIViewController {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!
    
    @IBAction func buttonClick(_ sender: UIButton) {
        if characteristic!.properties.contains(.writeWithoutResponse) {
            let vc: CollectionViewVC = XYHelper.getViewController(storyboardStr: nil, viewController: "CollectionViewVC") as! CollectionViewVC
            vc.backClosure = { backStr in
                self.textView.text = self.textView.text + "\n\n" + self.currentTime() + backStr
                guard  let data = backStr.hexadecimal() else {
                    return
                }
                XYCentralManager.shared.writeWithoutResponse(peripheral: self.peripheral!, characteristic: self.characteristic!, data: data)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        if characteristic!.properties.contains(.read) {
            XYCentralManager.shared.read(peripheral: peripheral!, characteristic: characteristic!) { (data, error) in
                if let data = data {
                    printXY(NSData(data: data), obj: self, line: #line)
                    self.textView.text = self.textView.text + "\n\n" + self.currentTime() + data.hexadecimal()
                }
            }
        }
        if characteristic!.properties.contains(.write) {
            let vc: CollectionViewVC = XYHelper.getViewController(storyboardStr: nil, viewController: "CollectionViewVC") as! CollectionViewVC
            vc.backClosure = { backStr in
                self.textView.text = self.textView.text + "\n\n" + self.currentTime() + backStr
                guard  let data = backStr.hexadecimal() else {
                    return
                }
                XYCentralManager.shared.write(peripheral: self.peripheral!, characteristic: self.characteristic!, data: data) { (error) in
                    if error != nil {
                        printXY(error, obj: self, line: #line)
                    }
   
                }
               
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func currentTime() -> String {
      getCurrentTimeWithDateFormatString("mm:ss.SSS   ")
    }
    
    var characteristic: CBCharacteristic?
    var peripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "特征"
//        printXY(self.peripheral?.maximumWriteValueLength(for: .withResponse), obj: self, line: #line)
//        printXY(self.peripheral?.maximumWriteValueLength(for: .withoutResponse), obj: self, line: #line)
        textView.inputView = UIView()
        label.text = characteristic!.uuid.uuidString + "  " + characteristic!.dealCharacteristicProperties()


        if characteristic!.properties.contains(.read) {
            button.setTitle("读数据", for: .normal)

        }
        if characteristic!.properties.contains(.notify) || characteristic!.properties.contains(.indicate){
            XYCentralManager.shared.subscribeNotify(peripheral: peripheral!, characteristic: characteristic!) { (error) in
                if error != nil {
                    printXY(error, obj: self, line: #line)
                }
            } notifyClosure: { (data, error) in
                if let data = data {
                    self.textView.text = self.textView.text + "\n\n" + self.currentTime() + data.hexadecimal()
//                    printXY(NSData(data: data), obj: self, line: #line)
                }
            }

            button.setTitle("已经订阅通知", for: .normal)
        }
        if characteristic!.properties.contains(.write) {
            button.setTitle("写数据", for: .normal)
        }
        if characteristic!.properties.contains(.writeWithoutResponse) {
            button.setTitle("写数据", for: .normal)
        }
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
