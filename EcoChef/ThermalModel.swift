//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

class ThermalModelData {
    var modelArray: [ThermalModelParams] = []
    var selectedIndex: Int = 1
    
    var selectedModelData: ThermalModelParams {
        return modelArray[selectedIndex]
    }
        
    func LoadDefaultModelData() {
        var theparams : ThermalModelParams
        
        theparams = ThermalModelParams(name: "Electric (EnergyStar)")
        theparams.a *= 1.2
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric (Fast Preheat)")
        theparams.a *= 1.2
        theparams.b = 700
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection")
        theparams.a *= 0.9
        modelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Gas Oven")
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
    var note: String
    var mod: Date
    
    struct Keys {
        static let name = "name"
        static let a = "a"
        static let b = "b"
        static let note = "note"
        static let mod = "mod"
    }
    
    convenience init(name: String) {
        self.init(name: name, a: 10, b: 500, note: "Default")
    }
    
    convenience init(name: String, a: Float, b: Float, note: String) {
        self.init(name: name, a: a, b: b, note: note, mod: Date())
    }
    
    init(name: String, a: Float, b: Float, note: String, mod: Date) {
        self.name = name
        self.a = a
        self.b = b
        self.note = note
        self.mod = mod
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: Keys.name) as! String
        let a = aDecoder.decodeFloat(forKey: Keys.a)
        let b = aDecoder.decodeFloat(forKey: Keys.b)
        var note: String
        if let noteread = aDecoder.decodeObject(forKey: Keys.note) as? String {
            note = noteread
        } else {
            note = ""
        }
        var mod: Date
        if let modread = aDecoder.decodeObject(forKey: Keys.mod) as? Date {
            mod = modread
        } else {
            mod = Date()
        }
        self.init(name: name, a: a, b: b, note: note, mod: mod)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(a, forKey: Keys.a)
        aCoder.encode(b, forKey: Keys.b)
        aCoder.encode(note, forKey: Keys.note)
        aCoder.encode(mod, forKey: Keys.mod)
    }
}

// Computational logic
class ThermalModel : CustomStringConvertible {
    var a: Float = 10.0  // RC time constant
    var b: Float = 500.0  // RH coefficient (s.s. temp above ambient)
    var Tamb: Float = 70.0  // T_ambient
    
    var description: String {
        return "ThermalModel: \((a, b)), Tamb = \(Tamb)"
    }
    
    var Tmax: Float {
        return b + Tamb
    }
    
    // load from struct
    func setfrom(params:ThermalModelParams) {
        a = params.a
        b = params.b
    }
    
    // time in fractional minutes
    func time(totemp:Float) -> Float? {
        return time(totemp:totemp, fromtemp:Tamb)
    }
    
    func time(totemp Tset:Float, fromtemp Tstart:Float) -> Float? {
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
