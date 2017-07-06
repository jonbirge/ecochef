//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation
import UIKit

class ThermalModelData {
    var modelArray: [ThermalModelParams] = []
    var selectedIndex: Int = 1
    
    var selectedModelData: ThermalModelParams {
        return modelArray[selectedIndex]
    }
    
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
    
    private func LoadDefaultModelData() {
        var theparams : ThermalModelParams
        
        theparams = ThermalModelParams(name: "Electric (EnergyStar)")
        theparams.a *= 1.2
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric (Fast Preheat)")
        theparams.a *= 1.2
        theparams.b = 700
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric (Old)")
        theparams.a *= 1.5
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection (Large)")
        theparams.a *= 0.9
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection (Small)")
        theparams.a *= 0.8
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Gas")
        theparams.a *= 1.1
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Gas Grill")
        modelArray.append(theparams)
    }
    
}

class ThermalModelParams : NSObject, NSCoding {
    var name: String
    var a: Float
    var b: Float
    
    struct PropertyKeys {
        static let name = "name"
        static let a = "a"
        static let b = "b"
    }
    
    convenience init(name: String) {
        self.init(name: name, a: 10, b: 500)
    }
    
    init(name: String, a: Float, b: Float) {
        self.name = name
        self.a = a
        self.b = b
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKeys.name) as? String
        let a = aDecoder.decodeFloat(forKey: PropertyKeys.a)
        let b = aDecoder.decodeFloat(forKey: PropertyKeys.b)
        self.init(name: name!, a: a, b: b)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKeys.name)
        aCoder.encode(a, forKey: PropertyKeys.a)
        aCoder.encode(b, forKey: PropertyKeys.b)
    }
}

// Computational logic
class ThermalModel : CustomStringConvertible {
    var a: Float = 10.0  // RC time constant
    var b: Float = 500.0  // RH coefficient (s.s. temp above ambient)
    var Tamb: Float = 70.0  // T_ambient
    
    var description: String {
        return "ThermalModel: \((a, b)), Tambient = \(Tamb)"
    }
    
    // load from struct
    func setfrom(params:ThermalModelParams) {
        a = params.a
        b = params.b
    }
    
    // time in fractional minutes
    func time(totemp:Float) -> Float {
        return time(totemp:totemp, fromtemp:Tamb)
    }
    
    func time(totemp Tset:Float, fromtemp Tstart:Float) -> Float {
        if Tset > Tstart {
            return a * log((b + Tamb - Tstart)/(b + Tamb - Tset))
        } else {
            return a * log((Tamb - Tstart)/(Tamb - Tset))
        }
    }
    
    func tempAfterHeating(time t:Float, fromtemp Tstart:Float) -> Float {
        let Tinf = b + Tamb
        return Tinf - exp(-t/a)*(Tinf - Tstart)
    }
    
    func tempAfterCooling(time t:Float, fromtemp Tstart:Float) -> Float {
        return Tamb + exp(-t/a)*(Tstart - Tamb)
    }
}
