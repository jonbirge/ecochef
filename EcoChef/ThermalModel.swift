//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

struct ThermalModelData : CustomStringConvertible {
    var name : String = "None"
    var a : Float = 0
    var b : Float = 0
    var c : Float = 0
    
    var description: String {
        return "ThermalModelData\((a, b, c))"
    }
    
    init(name: String, a: Float, b: Float, c: Float) {
        self.name = name
        self.a = a
        self.b = b
        self.c = c
    }
}

class ThermalModel : CustomStringConvertible {
    var a : Float = -10.0669
    var b : Float = 1.96757
    var c : Float = 508.24
    var T0 : Float = 72
    
    var description: String {
        return "ThermalModel: \((a, b, c)), T0 = \(T0)"
    }
    
    // load from struct
    func readfrom(data:ThermalModelData) {
        a = data.a
        b = data.b
        c = data.c
    }
    
    // time from hot
    func timefor(temp:Int, fromtemp:Int? = nil) -> Float {
        var timestart: Float
        if let tempstart = fromtemp {
            timestart = coldtime(temp: tempstart)
        } else {
            timestart = 0
        }
        return coldtime(temp:temp) - timestart
    }
    
    // time from cold
    func coldtime(temp:Int) -> Float {
        let timefrac = a * log(b/1000 * (c + T0 - Float(temp)))
        return timefrac
    }
}
