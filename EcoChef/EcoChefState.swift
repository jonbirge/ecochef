//
//  EcoChefState.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/30/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

class EcoChefState : NSObject, NSCoding {
    private let TambDefault: Float = 70
    private let desiredTempDefault: Float = 350
    var Tamb: Float
    var selectedModel: Int
    var desiredTemp: Float
    var notOnBoarded: Bool = true
    
    struct PropertyKeys {
        static let Tamb = "tamb"
        static let selectedModel = "selectedmodel"
        static let desiredTemp = "desiredtemp"
        static let notOnBoard = "notonboard"
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
    
    init(Tamb: Float, selectedModel: Int, desiredTemp: Float, notOnBoarded: Bool) {
        self.Tamb = Tamb
        self.selectedModel = selectedModel
        self.desiredTemp = desiredTemp
        self.notOnBoarded = notOnBoarded
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let Tamb = aDecoder.decodeFloat(forKey: PropertyKeys.Tamb)
        let selectedModel = aDecoder.decodeInteger(forKey: PropertyKeys.selectedModel)
        let desiredTemp = aDecoder.decodeFloat(forKey: PropertyKeys.desiredTemp)
        let notonboarded = aDecoder.decodeBool(forKey: PropertyKeys.notOnBoard)
        self.init(Tamb: Tamb, selectedModel: selectedModel, desiredTemp: desiredTemp, notOnBoarded: notonboarded)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Tamb, forKey: PropertyKeys.Tamb)
        aCoder.encode(selectedModel, forKey: PropertyKeys.selectedModel)
        aCoder.encode(desiredTemp, forKey: PropertyKeys.desiredTemp)
        aCoder.encode(notOnBoarded, forKey: PropertyKeys.notOnBoard)
    }
    
    func writeStateToDisk() {
        NSKeyedArchiver.archiveRootObject(self, toFile: EcoChefState.stateURL.path)
    }
}
