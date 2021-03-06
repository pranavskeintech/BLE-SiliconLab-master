//
//  CBManagerDelegate.swift
//  Ble-SiliconLab
//
//  Created by Aminjoni Abdullozoda on 7/3/20.
//  Copyright © 2020 Aminjoni Abdullozoda. All rights reserved.
//

import Foundation
import CoreBluetooth

let Temperature = CBUUID(string: "0x2A6E")
let Digital = CBUUID(string: "0x2A56")
var indexcount = Int()
var vc = ViewController()

fileprivate var ledMask: UInt8    = 0
fileprivate let digitalBits = 2 // TODO: each digital uses two bits


extension ViewController :  CBCentralManagerDelegate
{
    
       func centralManagerDidUpdateState(_ central: CBCentralManager) {
           
           if central.state == .poweredOn {
               central.scanForPeripherals(withServices: nil, options: nil)
               print("Scanning...")
                indexcount += 1
                vc.makeAPhoneCall()
                var userdindex = UserDefaults.standard.integer(forKey: "index")
                userdindex += 1
                UserDefaults.standard.setValue(userdindex, forKey: "index")
                print("indexcount = \(indexcount)")
                print("userdefaults = \(UserDefaults.standard.integer(forKey: "index"))")
           }
       }
       
       func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
           guard peripheral.name != nil else {return}
            if peripheral.name! == "Thunder Sense #33549" {
               print("Sensor Found!")
               //stopScan
               cbCentralManager.stopScan()
               //connect
               cbCentralManager.connect(peripheral, options: nil)
               self.peripheral = peripheral
           }
       }
       
       func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
           print("Connected : \(peripheral.name ?? "No Name")")
          
           //it' discover all service
           //peripheral.discoverServices(nil)
           
           //discover EnvironmentalSensing,AutomationIO
           peripheral.discoverServices([AutomationIO,EnvironmentalSensing])
        
           peripheral.delegate = self
       }
       
       func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
           print("Disconnected : \(peripheral.name ?? "No Name")")
           cbCentralManager.scanForPeripherals(withServices: nil, options: nil)
       }
}


//MARK:- CBPeripheralDelegate
extension ViewController : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
 
        if let services = peripheral.services {
            //discover characteristics of services
            for service in services {
              peripheral.discoverCharacteristics(nil, for: service)
          }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let charac = service.characteristics {
            for characteristic in charac {
               
                //MARK:- Light Value
                if characteristic.uuid == Digital {
                      //write value
                    setDigitalOutput(1, on: true, characteristic: characteristic)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.setDigitalOutput(1, on: false, characteristic: characteristic)
                    })
                    
                }
                    
                //MARK:- Temperature Read Value
                else if characteristic.uuid == Temperature {
                    //read value
                    //peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
               
            }
        }
        
    }
    

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
          
        if characteristic.uuid == Temperature {
                           print("Temp : \(characteristic)")
                let temp = characteristic.tb_uint16Value()

                print(Double(temp!) / 100)
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("WRITE VALUE : \(characteristic)")
    }
    
    
    fileprivate func setDigitalOutput(_ index: Int, on: Bool, characteristic  :CBCharacteristic) {
           let shift = UInt(index) * UInt(digitalBits)
           var mask = ledMask
           
           if on {
               mask = mask | UInt8(1 << shift)
           }
           else {
               mask = mask & ~UInt8(1 << shift)
           }
           
           let data = Data(bytes: [mask])
            self.peripheral?.writeValue(data, for: characteristic, type: .withResponse)
           //self.bleDevice.writeValueForCharacteristic(CBUUID.Digital, value: data)
           
           // *** Note: sending notification optimistically ***
           // Since we're writing the full mask value, LILO applies here,
           // and we *should* end up consistent with the device. Waiting to
           // read back after write causes rubber-banding during fast write sequences. -tt
           ledMask = mask
          // notifyLedState()
       }
    
}

extension CBCharacteristic  {
   func tb_int16Value() -> Int16? {
        if let data = self.value {
            var value: Int16 = 0
            (data as NSData).getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
    func tb_uint16Value() -> UInt16? {
        if let data = self.value {
            var value: UInt16 = 0
            (data as NSData).getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
}
