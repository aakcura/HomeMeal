//
//  DeviceAndAppInfo.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

struct DeviceAndAppInfo{
    var deviceOSName:String //iOS
    var deviceOSVersionName:String //11.4
    var deviceModel:String //iPhone or iPad
    var deviceName:String // iPhone 7 or Batuhan's iPhone
    var applicationVersionNumber:String? // 1.0.4
    var securityID:String?
    
    init(){
        let device = UIDevice.current
        self.deviceOSName = device.systemName
        self.deviceOSVersionName = device.systemVersion
        self.deviceModel = device.model
        self.deviceName = device.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "UnknownAppleDevice"
        
        if let infoDictionary = Bundle.main.infoDictionary{
            if let appVersionNumber = infoDictionary["CFBundleShortVersionString"] as? String {
                self.applicationVersionNumber = appVersionNumber
            }else{
                self.applicationVersionNumber = "nil"
            }
        }else{
            self.applicationVersionNumber = "nil"
        }
        self.securityID = device.identifierForVendor?.uuidString ?? ""
    }
}
