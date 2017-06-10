//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

class ThermalModel : CustomStringConvertible {
    var a : Float = -7.8427
    var b : Float = 2.178
    var c : Float = 459.1
    var T0 : Float = 70
    
    var description: String {
        return "ThermalModel: \((a,b,c)), T0 = \(T0)"
    }
    
    // time in minutes
    func timefor(temp:Int, fromtemp:Int? = nil) -> Int {
        var timestart: Float
        if let tempstart = fromtemp {
            timestart = fractimefor(temp: tempstart)
        } else {
            timestart = 0
        }
        let timefrac = fractimefor(temp:temp) - timestart
        
        return Int(ceil(timefrac))
    }
    
    // time in fractional minutes
    func fractimefor(temp:Int) -> Float {
        let timefrac = a * log(b/1000 * (c + T0 - Float(temp)))
        return ceil(timefrac)
    }
}
