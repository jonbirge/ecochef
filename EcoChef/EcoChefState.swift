//
//  EcoChefState.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/30/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

class EcoChefState : NSObject, NSCoding {
    var Tamb: Float
    var selectedModel: Int
    
    struct PropertyKeys {
        static let Tamb = "tamb"
        static let selectedModel = "selectedmodel"
    }
    
    override init() {
        self.Tamb = 70
        self.selectedModel = 0
        super.init()
    }
    
    init(Tamb: Float, selectedModel: Int) {
        self.Tamb = Tamb
        self.selectedModel = selectedModel
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let Tamb = aDecoder.decodeFloat(forKey: PropertyKeys.Tamb)
        let selectedModel = aDecoder.decodeInteger(forKey: PropertyKeys.selectedModel)
        self.init(Tamb: Tamb, selectedModel: selectedModel)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Tamb, forKey: PropertyKeys.Tamb)
        aCoder.encode(selectedModel, forKey: PropertyKeys.selectedModel)
    }
}
