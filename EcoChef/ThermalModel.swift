//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

class ThermalModel {
    var a : Double = -7.8427
    var b : Double = 0.002178
    var c : Double = 459.1
    var T0 : Double = 70
    
    // time in minutes
    func timefor(temp:Int, fromtemp:Int? = nil) -> Int {
        var timestart: Double
        if let tempstart = fromtemp {
            timestart = fractimefor(temp: tempstart)
        } else {
            timestart = 0
        }
        let timefrac = fractimefor(temp:temp) - timestart
        
        return Int(ceil(timefrac))
    }
    
    // time in fractional minutes
    func fractimefor(temp:Int) -> Double {
        let timefrac = a * log(b * (c + T0 - Double(temp)))
        return ceil(timefrac)
    }
}
