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
    var selectedModel: Int
    var desiredTemp: Float
    
    struct PropertyKeys {
        static let Tamb = "tamb"
        static let selectedModel = "selectedmodel"
        static let desiredTemp = "desiredtemp"
    }
    
    static var stateURL: URL {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsURL.appendingPathComponent("state")
    }
    
    override init() {
        self.selectedModel = 0
        self.Tamb = TambDefault
        self.desiredTemp = desiredTempDefault
        super.init()
    }
    
    init(Tamb: Float, selectedModel: Int, desiredTemp: Float) {
        self.Tamb = Tamb
        self.selectedModel = selectedModel
        self.desiredTemp = desiredTemp
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        var Tamb = aDecoder.decodeFloat(forKey: PropertyKeys.Tamb)
        if Tamb == 0 {
            Tamb = 70
        }
        let selectedModel = aDecoder.decodeInteger(forKey: PropertyKeys.selectedModel)
        var desiredTemp = aDecoder.decodeFloat(forKey: PropertyKeys.desiredTemp)
        if desiredTemp == 0 {
            desiredTemp = 350
        }
        self.init(Tamb: Tamb, selectedModel: selectedModel, desiredTemp: desiredTemp)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Tamb, forKey: PropertyKeys.Tamb)
        aCoder.encode(selectedModel, forKey: PropertyKeys.selectedModel)
        aCoder.encode(desiredTemp, forKey: PropertyKeys.desiredTemp)
    }
    
    func writeStateToDisk() {
        NSKeyedArchiver.archiveRootObject(self, toFile: EcoChefState.stateURL.path)
    }
}
