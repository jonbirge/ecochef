//
//  EcoChefState.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/30/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

class EcoChefState : NSObject, NSCoding {
    let TambDefault: Float = 70
    let desiredTempDefault: Float = 350
    var Tamb: Float
    var desiredTemp: Float
    
    struct PropertyKeys {
        static let Tamb = "tamb"
        static let desiredTemp = "desiredtemp"
    }
    
    override init() {
        self.Tamb = TambDefault
        self.desiredTemp = desiredTempDefault
        super.init()
    }
    
    init(Tamb: Float, desiredTemp: Float) {
        self.Tamb = Tamb
        self.desiredTemp = desiredTemp
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        var Tamb = aDecoder.decodeFloat(forKey: PropertyKeys.Tamb)
        if Tamb == 0 {
            Tamb = 70
        }
        var desiredTemp = aDecoder.decodeFloat(forKey: PropertyKeys.desiredTemp)
        if desiredTemp == 0 {
            desiredTemp = 350
        }
        self.init(Tamb: Tamb, desiredTemp: desiredTemp)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Tamb, forKey: PropertyKeys.Tamb)
        aCoder.encode(desiredTemp, forKey: PropertyKeys.desiredTemp)
    }
}
