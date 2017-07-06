//
//  EcoChefThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/5/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation
import UIKit

extension ThermalModelData {
    var modelURL: URL {
        let modelURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return modelURL.appendingPathComponent("models")
    }
    
    func LoadModelData() {
        if let models = NSKeyedUnarchiver.unarchiveObject(withFile: modelURL.path) as? [ThermalModelParams] {
            self.modelArray = models
        } else {
            LoadDefaultModelData()
        }
    }
    
    func WriteToDisk() {
        NSKeyedArchiver.archiveRootObject(modelArray, toFile: modelURL.path)
    }
}
