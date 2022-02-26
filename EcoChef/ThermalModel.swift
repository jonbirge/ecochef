//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2022 Birge & Fuller. All rights reserved.
//

import Foundation

// MARK: - Data model

class ThermalModelData {
    var modelArray: [ThermalModelParams] = []
    var selectedIndex: Int = 1
    
    // The currently selected model
    // TODO: Refactor as selectedModel
    var selectedModelData: ThermalModelParams {
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
        var defaultModels : [ThermalModelParams] = []
        
        theparams = ThermalModelParams(name: "Electric (EnergyStar)")
        theparams.a *= 2
        theparams.note = "Bosch"
        defaultModels.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric (Fast)")
        theparams.a *= 1.5
        theparams.b = 700
        theparams.note = "Bosch; fast preheat setting"
        defaultModels.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection")
        theparams.a *= 1.1
        theparams.note = "Bosch; normal convection preheat"
        defaultModels.append(theparams)
        
        theparams = ThermalModelParams(name: "Speed Oven")
        theparams.a *= 1.0
        theparams.b = 500
        theparams.note = "Bosch speed oven; normal convection preheat"
        defaultModels.append(theparams)
        
        theparams = ThermalModelParams(name: "Gas Grill", a: 16.0, b: 640, note: "MHP grill")
        theparams.addDataPoint(HeatingDataPoint(time: 2.5, Tstart: 64, Tfinal: 155))
        theparams.addDataPoint(HeatingDataPoint(time: 4, Tstart: 64, Tfinal: 200))
        theparams.addDataPoint(HeatingDataPoint(time: 7.5, Tstart: 64, Tfinal: 300))
        theparams.addDataPoint(HeatingDataPoint(time: 5.5, Tstart: 64, Tfinal: 250))
        theparams.addDataPoint(HeatingDataPoint(time: 10, Tstart: 64, Tfinal: 365))
        theparams.addDataPoint(HeatingDataPoint(time: 12.25, Tstart: 64, Tfinal: 400))
        theparams.calibrated = true
        theparams.fitfromdata()
        defaultModels.append(theparams)
        
        return defaultModels
    }
}

class ThermalModelParams : NSObject, NSCoding {
    var name: String
    var a: Float
    var b: Float
    var note: String
    var mod: Date
    var measurements: HeatingDataSet
    var calibrated: Bool = false
    var fitter: ThermalModelFitter?
    
    struct Keys {
        static let name = "name"
        static let a = "a"
        static let b = "b"
        static let note = "note"
        static let mod = "mod"
        static let meas = "meas"
        static let cal = "cal"
    }
    
    convenience init(name: String) {
        self.init(name: name, a: 10, b: 500, note: "Default")
    }
    
    convenience init(name: String, a: Float, b: Float, note: String) {
        let newmeas = HeatingDataSet()
        self.init(name: name, a: a, b: b, note: note, mod: Date(), meas: newmeas)
    }
    
    convenience init(name: String, a: Float, b: Float, note: String, mod: Date) {
        let newmeas = HeatingDataSet()
        self.init(name: name, a: a, b: b, note: note, mod: mod, meas: newmeas)
    }
    
    init(name: String, a: Float, b: Float, note: String, mod: Date, meas: HeatingDataSet, cal: Bool = true) {
        self.name = name
        self.a = a
        self.b = b
        self.note = note
        self.mod = mod
        self.measurements = meas
        self.calibrated = cal
    }
    
    func addDataPoint(_ data: HeatingDataPoint) {
        measurements.addDataPoint(data)
    }
    
    func addDataPoint(time: Float, Tstart: Float, Tfinal: Float, Tamb: Float) {
        let measurement = HeatingDataPoint(time: time,
                                           Tstart: Tstart,
                                           Tfinal: Tfinal,
                                           Tamb: Tamb)
        measurements.addDataPoint(measurement)
    }
    
    func initFitter() {
        fitter = ThermalModelFitter(params: self)
    }
    
    // TODO: Rename
    func fitfromdata() {
        if fitter == nil {
            initFitter()
        }
        fitter?.fitfromdata()
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
        let meas = aDecoder.decodeObject(forKey: Keys.meas) as! HeatingDataSet
        let cal = aDecoder.decodeBool(forKey: Keys.cal)
        self.init(name: name, a: a, b: b, note: note, mod: mod, meas: meas, cal: cal)
    }
    
    override var description: String {
        return "ThermalModelParams(a: \(a), b: \(b))"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(a, forKey: Keys.a)
        aCoder.encode(b, forKey: Keys.b)
        aCoder.encode(note, forKey: Keys.note)
        aCoder.encode(mod, forKey: Keys.mod)
        aCoder.encode(measurements, forKey: Keys.meas)
        aCoder.encode(calibrated, forKey: Keys.cal)
    }
}

// MARK: - Measurements

class HeatingDataSet : NSObject, NSCoding {
    var measlist: [HeatingDataPoint] = []
    
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
    
    // Add new heating data to maintain sorted order
    func addDataPoint(_ datapoint: HeatingDataPoint) {
        measlist.append(datapoint)
        sort()
    }
    
    func sort() {
        measlist = measlist.sorted() { (pointA, pointB) -> Bool in
            return pointA.time < pointB.time
        }
    }
    
    subscript(index: Int) -> HeatingDataPoint {
        return measlist[index]
    }
    
    var count: Int {
        return measlist.count
    }
}

class HeatingDataPoint : NSObject, NSCoding {
    var Tamb : Float = 72
    var Tstart : Float = 72
    var Tfinal : Float = 350
    var time : Float = 10  // minutes (est. or actual)
    var date : Date = Date()
    
    struct Keys {
        static let tamb = "tamb"
        static let tstart = "tstart"
        static let tfinal = "tfinal"
        static let time = "time"
        static let date = "date"
    }
    
    init(time: Float, Tstart: Float, Tfinal: Float, Tamb: Float, date: Date) {
        self.Tamb = Tamb
        self.Tstart = Tstart
        self.Tfinal = Tfinal
        self.time = time
        self.date = date
    }
    
    override init() {
        super.init()
    }
    
    convenience init(copiedfrom source: HeatingDataPoint) {
        self.init(time: source.time,
                  Tstart: source.Tstart,
                  Tfinal: source.Tfinal,
                  Tamb: source.Tamb,
                  date: source.date)
    }
    
    convenience init(time: Float, Tstart: Float, Tfinal: Float) {
        self.init(time: time, Tstart: Tstart, Tfinal: Tfinal, Tamb: Tstart, date: Date())
    }
    
    convenience init(time: Float, Tstart: Float, Tfinal: Float, Tamb: Float) {
        self.init(time: time, Tstart: Tstart, Tfinal: Tfinal, Tamb: Tamb, date: Date())
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let Tamb = aDecoder.decodeFloat(forKey: Keys.tamb)
        let Tstart = aDecoder.decodeFloat(forKey: Keys.tstart)
        let Tfinal = aDecoder.decodeFloat(forKey: Keys.tfinal)
        let time = aDecoder.decodeFloat(forKey: Keys.time)
        var date = Date()
        if let dateread = aDecoder.decodeObject(forKey: Keys.date) as? Date {
            date = dateread
        }
        self.init(time: time, Tstart: Tstart, Tfinal: Tfinal, Tamb: Tamb, date: date)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Tamb, forKey: Keys.tamb)
        aCoder.encode(Tfinal, forKey: Keys.tfinal)
        aCoder.encode(Tstart, forKey: Keys.tstart)
        aCoder.encode(time, forKey: Keys.time)
    }
}

// MARK: - Model fitting

class ThermalModelFitter : Fittable {
    var verbose: Bool = false
    var fitmodel: ThermalModel
    var modelparams: ThermalModelParams
    private var fitter: GaussNewtonFitter!
    
    struct IndexKeys {
        static let a = 0
        static let b = 1
    }
    
    var fitnparams: Int {
        return 2
    }
    
    var fitnpoints: Int {
        return modelparams.measurements.count
    }
    
    var fitinitparams: [Double] {
        let p: [Double] =
            [Double(modelparams.a), Double(modelparams.b)]
        return p
    }
    
    var fittable: Bool {
        if fitnpoints > 2 {
            return true
        } else {
            return false
        }
    }
    
    func fitresiduals(for params: [Double]) throws -> [Double] {
        fitmodel.a = Float(params[IndexKeys.a])
        fitmodel.b = Float(params[IndexKeys.b])
        var res: [Double] = []
        for meas in modelparams.measurements.measlist {
            fitmodel.Tamb = meas.Tamb
            let Tmeas = meas.Tfinal
            let Tcomp = fitmodel.tempAfterHeating(time: meas.time,
                                                  fromtemp: meas.Tstart,
                                                  withamb: meas.Tamb)
            res.append(Double(Tcomp - Tmeas))
        }
        return res
    }
    
    convenience init(params: ThermalModelParams) {
        self.init(model: ThermalModel(), params: params)
    }
    
    init(model: ThermalModel, params: ThermalModelParams) {
        fitmodel = model
        modelparams = params
        setup()
    }
    
    func setup() {
        fitter = GaussNewtonFitter(with: self)
    }
    
    func fitfromdata() {
        if fittable {
            do {
                let p: [Double] = try fitter.fit()
                fitter.verbose = verbose
                modelparams.a = Float(round(10*p[IndexKeys.a])/10)
                modelparams.b = Float(round(p[IndexKeys.b]))
            } catch let err {
                print("ThermalModelFitter: failed with \(err)")
            }
        }
    }
}

// MARK: - Computational model

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
    
    func tempAfterHeating
        (time t:Float, fromtemp Tstart:Float, withamb Tamb:Float) -> Float {
        let Tinf = b + Tamb
        return Tinf - exp(-t/a)*(Tinf - Tstart)
    }
    
    func tempAfterCooling(time t:Float, fromtemp Tstart:Float) -> Float {
        return Tamb + exp(-t/a)*(Tstart - Tamb)
    }
}

// load from struct
extension ThermalModel {
    func setfrom(params:ThermalModelParams) {
        a = params.a
        b = params.b
    }
}
