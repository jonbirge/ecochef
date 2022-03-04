//
//  EcoChefThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/5/17.
//  Copyright © 2022 Birge & Fuller. All rights reserved.
//

import Foundation
import UIKit

// Extension for reading and writing using UIKit API
extension ThermalModelData {
    var modelURL: URL {
        let modelURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return modelURL.appendingPathComponent("models")
    }
    
    func LoadModelData() {
        do {
            print("ThermalModelDataExt: decoding...")
            let rawData = try Data(contentsOf: modelURL)
            if let models = try
                NSKeyedUnarchiver.unarchivedObject(
                    ofClasses: [NSArray.self, ThermalModelParams.self, NSString.self, NSDate.self, HeatingDataSet.self, HeatingDataPoint.self],
                    from: rawData) as? [ThermalModelParams]
            {
                self.modelArray = models
            }
            else
            {
                print("ThermalModelDataExt: error decoding!")
                LoadDefaultModelData()
            }
        } catch let err {
            print("ThermalModelDataExt: unable to read/decode data: \(err)")
            LoadDefaultModelData()
        }
    }
    
    func WriteToDisk() {
        do {
            let rawData = try NSKeyedArchiver.archivedData(withRootObject: modelArray, requiringSecureCoding: true)
            try rawData.write(to: modelURL)
            print("ThermalModelDataExt: wrote to file...") }
        catch let err {
            print("ThermalModelData: error encoding data: \(err)")
            return
        }
    }
}
