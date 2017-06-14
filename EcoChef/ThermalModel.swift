//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

struct ThermalModelData : CustomStringConvertible {
    var name : String = "Model"
    var a : Float = 0
    var b : Float = 0
    var T0fit : Float = 0
    
    var description: String {
        return "ThermalModelData\((a, b))"
    }
    
    init(name: String, a: Float, b: Float) {
        self.name = name
        self.a = a
        self.b = b
    }
}

class ThermalModel : CustomStringConvertible {
    var a : Float = 10.0669
    var b : Float = 508.24
    var T0 : Float = 72
    
    var description: String {
        return "ThermalModel: \((a, b)), T0 = \(T0)"
    }
    
    // load from struct
    func setfrom(data:ThermalModelData) {
        a = data.a
        b = data.b
    }
    
    func time(totemp:Float) -> Float {
        return time(totemp:totemp, fromtemp:T0)
    }
    
    func time(totemp:Float, fromtemp:Float) -> Float {
        if totemp > fromtemp {
            return a * log((b + T0 - fromtemp)/(b + T0 - totemp))
        } else {
            return a * log((T0 - fromtemp)/(T0 - totemp))
        }
    }
}
