//
//  EcoChefState.swift
//  EcoChef
//
//  Copyright © 2022 Birge & Fuller. All rights reserved.
//

import Foundation

class EcoChefState : NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    var Tamb: Float = 70  // deg F
    var selectedModel: Int = 0
    var desiredTemp: Float = 350  // deg F
    var useCelcius: Bool = false  // TODO: set by region or initial query
    var notOnBoarded: Bool = true
    struct PropertyKeys {
        static let Tamb = "tamb"
        static let selectedModel = "selectedmodel"
        static let desiredTemp = "desiredtemp"
        static let notOnBoard = "notonboard"
        static let useCelcius = "usecelcius"
    }
    
    static var stateURL: URL {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsURL.appendingPathComponent("state")
    }
    
    // We keep these URLs here in case we want to do a bit of load balancing in the app
    static var faqURL: String {
        return "https://ecochef-faq.birgefuller.com"
    }
    
    static var siteURL: String {
        return "https://www.birgefuller.com"
    }
    
    override init() {
        super.init()
    }
    
    init(Tamb: Float, selectedModel: Int, desiredTemp: Float, useCelcius: Bool, notOnBoarded: Bool) {
        self.Tamb = Tamb
        self.selectedModel = selectedModel
        self.desiredTemp = desiredTemp
        self.useCelcius = useCelcius
        self.notOnBoarded = notOnBoarded
        //self.notOnBoarded = true  // TEST
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let Tamb = aDecoder.decodeFloat(forKey: PropertyKeys.Tamb)
        let selectedModel = aDecoder.decodeInteger(forKey: PropertyKeys.selectedModel)
        let desiredTemp = aDecoder.decodeFloat(forKey: PropertyKeys.desiredTemp)
        let useCelcius = aDecoder.decodeBool(forKey: PropertyKeys.useCelcius)
        let notonboarded = aDecoder.decodeBool(forKey: PropertyKeys.notOnBoard)
        self.init(Tamb: Tamb, selectedModel: selectedModel, desiredTemp: desiredTemp, useCelcius: useCelcius, notOnBoarded: notonboarded)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Tamb, forKey: PropertyKeys.Tamb)
        aCoder.encode(selectedModel, forKey: PropertyKeys.selectedModel)
        aCoder.encode(desiredTemp, forKey: PropertyKeys.desiredTemp)
        aCoder.encode(useCelcius, forKey: PropertyKeys.useCelcius)
        aCoder.encode(notOnBoarded, forKey: PropertyKeys.notOnBoard)
    }
    
    func writeStateToDisk() {
        do {
            let theArchive = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
            try theArchive.write(to:EcoChefState.stateURL)
            print("EcoChefState: wrote to disk")
        }
        catch let err {
            print("EcoChefState: failed to write with error \(err)")
        }
    }
}
