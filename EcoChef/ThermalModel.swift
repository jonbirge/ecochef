//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

class ThermalModelData {
    var modelArray: [ThermalModelParams] = []
    var selectedIndex: Int = 1
    
    var selectedModelData: ThermalModelParams {
        // TODO: should we use try?
        if selectedIndex < modelArray.count {
            return modelArray[selectedIndex]
        } else {
            return modelArray.first!
        }
    }
    
    func LoadDefaultModelData() {
        print("Loading default model data...")
        modelArray = ThermalModelData.DefaultModelList()
    }
    
    static func DefaultModelList() -> [ThermalModelParams] {
        var theparams : ThermalModelParams
        var defModelArray : [ThermalModelParams] = []
        
        theparams = ThermalModelParams(name: "Electric (EnergyStar)")
        theparams.a *= 1.5
        defModelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric (Fast Preheat)")
        theparams.a *= 1.25
        theparams.b = 700
        defModelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection (Large)")
        theparams.a *= 0.9
        defModelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection (Small)")
        theparams.a *= 0.8
        defModelArray.append(theparams)
        
        theparams = ThermalModelParams(name: "Gas Grill", a: 16.3, b: 644, note: "MHP")
        let measdata = HeatingDataSet()
        measdata.addDataPoint(HeatingDataPoint(time: 2.5, Tstart: 64, Tfinal: 155))
        measdata.addDataPoint(HeatingDataPoint(time: 4, Tstart: 64, Tfinal: 200))
        measdata.addDataPoint(HeatingDataPoint(time: 7.5, Tstart: 64, Tfinal: 300))
        measdata.addDataPoint(HeatingDataPoint(time: 5.5, Tstart: 64, Tfinal: 250))
        measdata.addDataPoint(HeatingDataPoint(time: 10, Tstart: 64, Tfinal: 365))
        measdata.addDataPoint(HeatingDataPoint(time: 12.25, Tstart: 64, Tfinal: 400))
        theparams.measurements = measdata
        defModelArray.append(theparams)
        
        return defModelArray
    }
}

// MARK: -

class HeatingDataSet : NSObject, NSCoding {
    private var measlist: [HeatingDataPoint] = []
    
    struct Keys {
        static let measlist = "measlist"
    }
    
    override init() {
        super.init()
    }
    
    private init(measlist: [HeatingDataPoint]) {
        self.measlist = measlist
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let measlistread = aDecoder.decodeObject(forKey: Keys.measlist) as! [HeatingDataPoint]
        self.init(measlist: measlistread)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(measlist, forKey: Keys.measlist)
    }
    
    // TODO: Fix sorting!
    // Add new heating data to maintain sorted order
    func addDataPoint(_ datapoint: HeatingDataPoint) {
        if measlist.count == 0 {
            measlist.append(datapoint)
        } else {
            var inserted = false  // assume end
            for k in 0...(measlist.count - 1) {
                if datapoint.time < measlist[k].time {
                    measlist.insert(datapoint, at: k)
                    inserted = true
                    break
                }
            }
            if !inserted {
                measlist.append(datapoint)
            }
        }
    }
    
    subscript(index: Int) -> HeatingDataPoint {
        return measlist[index]
    }
    
    var count: Int {
        return measlist.count
    }
    
    var measurementList: [HeatingDataPoint] {
        return measlist
    }
}

class HeatingDataPoint : NSObject, NSCoding {
    var Tamb : Float
    var Tstart : Float
    var Tfinal : Float
    var time : Float  // minutes
    
    struct Keys {
        static let tamb = "tamb"
        static let tstart = "tstart"
        static let tfinal = "tfinal"
        static let time = "time"
    }
    
    init(time: Float, Tstart: Float, Tfinal: Float, Tamb: Float) {
        self.Tamb = Tamb
        self.Tstart = Tstart
        self.Tfinal = Tfinal
        self.time = time
    }
    
    convenience init(time: Float, Tstart: Float, Tfinal: Float) {
        self.init(time: time, Tstart: Tstart, Tfinal: Tfinal, Tamb: Tstart)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let Tamb = aDecoder.decodeFloat(forKey: Keys.tamb)
        let Tstart = aDecoder.decodeFloat(forKey: Keys.tstart)
        let Tfinal = aDecoder.decodeFloat(forKey: Keys.tfinal)
        let time = aDecoder.decodeFloat(forKey: Keys.time)
        self.init(time: time, Tstart: Tstart, Tfinal: Tfinal, Tamb: Tamb)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Tamb, forKey: Keys.tamb)
        aCoder.encode(Tfinal, forKey: Keys.tfinal)
        aCoder.encode(Tstart, forKey: Keys.tstart)
        aCoder.encode(time, forKey: Keys.time)
    }
}

// MARK: -

class ThermalModelParams : NSObject, NSCoding {
    var name: String
    var a: Float
    var b: Float
    var note: String
    var mod: Date
    var measurements: HeatingDataSet?
    
    struct Keys {
        static let name = "name"
        static let a = "a"
        static let b = "b"
        static let note = "note"
        static let mod = "mod"
        static let meas = "meas"
    }
    
    convenience init(name: String) {
        self.init(name: name, a: 10, b: 500, note: "Default")
    }
    
    convenience init(name: String, a: Float, b: Float, note: String) {
        self.init(name: name, a: a, b: b, note: note, mod: Date(), meas: nil)
    }
    
    init(name: String, a: Float, b: Float, note: String, mod: Date, meas: HeatingDataSet?) {
        self.name = name
        self.a = a
        self.b = b
        self.note = note
        self.mod = mod
        self.measurements = meas
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: Keys.name) as! String
        let a = aDecoder.decodeFloat(forKey: Keys.a)
        let b = aDecoder.decodeFloat(forKey: Keys.b)
        var note: String
        if let noteread = aDecoder.decodeObject(forKey: Keys.note) as? String {
            note = noteread
        } else {
            note = ""
        }
        var mod: Date
        if let modread = aDecoder.decodeObject(forKey: Keys.mod) as? Date {
            mod = modread
        } else {
            mod = Date()
        }
//        var measurements: [HeatingDataPoint]?
//        if let measread = aDecoder.decodeObject(forKey: Keys.meas) as? [HeatingDataPoint] {
//            measurements = measread
//        } else {
//            measurements = nil
//        }
        let measurements = aDecoder.decodeObject(forKey: Keys.meas) as? HeatingDataSet
        self.init(name: name, a: a, b: b, note: note, mod: mod, meas: measurements)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(a, forKey: Keys.a)
        aCoder.encode(b, forKey: Keys.b)
        aCoder.encode(note, forKey: Keys.note)
        aCoder.encode(mod, forKey: Keys.mod)
        aCoder.encode(measurements, forKey: Keys.meas)
    }
}

// MARK: - Computational logic

class ThermalModel : CustomStringConvertible {
    var a: Float = 12.0  // RC time constant
    var b: Float = 600.0  // RH coefficient (s.s. temp above ambient)
    var Tamb: Float = 70.0  // T_ambient
    
    var description: String {
        return "ThermalModel: \((a, b)), Tamb = \(Tamb)"
    }
    
    var Tmax: Float {
        return b + Tamb
    }
    
    // load from struct
    func setfrom(params:ThermalModelParams) {
        a = params.a
        b = params.b
    }
    
    // time in fractional minutes
    func time(totemp:Float) -> Float? {
        return time(totemp:totemp, fromtemp:Tamb)
    }
    
    func time(totemp Tset:Float, fromtemp Tstart:Float) -> Float? {
        if Tset > Tstart {  // heating
            if Tset >= Tmax {
                return nil
            } else {
                return a * log((b + Tamb - Tstart)/(b + Tamb - Tset))
            }
        } else {  // cooling
            if Tset < Tamb  {
                return nil
            } else {
                return a * log((Tamb - Tstart)/(Tamb - Tset))
            }
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
