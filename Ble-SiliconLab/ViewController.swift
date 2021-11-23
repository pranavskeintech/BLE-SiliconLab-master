//
//  ViewController.swift
//  Ble-SiliconLab
//
//  Created by Aminjoni Abdullozoda on 7/3/20.
//  Copyright © 2020 Aminjoni Abdullozoda. All rights reserved.
//

/// Environmental Sensing (org.bluetooth.service.environmental_sensing)
let EnvironmentalSensing = CBUUID(string: "0x181A")
let AutomationIO = CBUUID(string: "0x1815")

import UIKit
import CoreBluetooth
class ViewController: UIViewController {
    
    //MARK:-UI Elements
    @IBOutlet weak var batteryImage : UIImageView!
    @IBOutlet weak var lightSwitch : UISwitch!
    
    
    //MARK:- CBluetooth
    var cbCentralManager : CBCentralManager!
    var peripheral : CBPeripheral?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //Start manager
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
                
    }
    
    @IBAction func button_Clicked(_ sender: Any)
    {
       // makeAPhoneCall()
        dialNumber(number: "+921111111222")

    }
    func makeAPhoneCall()  {
        let url: NSURL = URL(string: "TEL://1234567890")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    func dialNumber(number : String) {

     if let url = URL(string: "tel://\(number)"),
       UIApplication.shared.canOpenURL(url) {
          if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
           } else {
               UIApplication.shared.openURL(url)
           }
       } else {
                // add error message here
       }
    }
    
}


