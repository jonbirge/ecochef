//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

struct ThermalModelParams : CustomStringConvertible {
    let name: String
    var a: Float
    var b: Float
    
    var description: String {
        return name
    }
    
    init(name: String) {
        self.name = name
        a = 10.0
        b = 500.0
     }
}

// Computational logic
class ThermalModel {
    var a: Float = 10.0  // RC time constant
    var b: Float = 500.0  // RH coefficient (s.s. temp above ambient)
    var Tamb: Float = 72.0  // T_ambient
    
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
