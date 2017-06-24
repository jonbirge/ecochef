//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

struct ThermalModelParams : CustomStringConvertible {
    let name : String
    var a : Float
    var b : Float
    
    var description: String {
        return name + "\(a, b)"
    }
    
    init(name: String) {
        self.name = name
        a = 10.0669
        b = 508.24
     }
}

// Computational logic
class ThermalModel {
    var a : Float = 10.0669  // time constant
    var b : Float = 508.24  // integration coefficient
    var Tamb : Float = 72.0  // T_ambient
    
    var description: String {
        return "ThermalModel: \((a, b)), Tambient = \(Tamb)"
    }
    
    // load from struct
    func setfrom(params:ThermalModelParams) {
        a = params.a
        b = params.b
    }
    
    func time(totemp:Float) -> Float {
        return time(totemp:totemp, fromtemp:Tamb)
    }
    
    func time(totemp:Float, fromtemp:Float) -> Float {
        if totemp > fromtemp {
            return a * log((b + Tamb - fromtemp)/(b + Tamb - totemp))
        } else {
            return a * log((Tamb - fromtemp)/(Tamb - totemp))
        }
    }
}
