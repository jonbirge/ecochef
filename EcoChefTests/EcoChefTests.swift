//
//  EcoChefTests.swift
//  EcoChefTests
//
//  Created by Jonathan Birge on 7/8/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import XCTest

class ThermalModelTests: XCTestCase {
    var testModel = ThermalModel()
    var testCase = ThermalModelParams(name: "Test", a: 10, b: 500, note: "")
    var maxTemp: Float = 0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testModel.Tamb = 70
        testModel.setfrom(params: testCase)
        maxTemp = testModel.b + testModel.Tamb
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testZeroTime() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testTime = testModel.time(totemp: 100, fromtemp: 100)
        XCTAssertEqual(testTime, 0.0)
    }
    
    func testGeneralHeatTime() {
        let testTime = testModel.time(totemp: 450, fromtemp: 70)
        XCTAssertEqual(testTime, 10*log(25/6))
    }
    
    func testHeatTimeFromAmbient() {
        let testTime = testModel.time(totemp: 450)
        XCTAssertEqual(testTime, 10*log(25/6))
    }
    
    func testGeneralCoolTime() {
        let testTime = testModel.time(totemp: 100, fromtemp: 175)
        XCTAssertEqual(testTime, 10*log(7/2))
    }
    
    func testHeatTemp() {
        let testTemp = testModel.tempAfterHeating(time: 10, fromtemp: 100)
        XCTAssertEqual(testTemp, 570 - 470/exp(1))
    }
    
    func testCoolTemp() {
        let testTemp = testModel.tempAfterCooling(time: 10, fromtemp: 175)
        XCTAssertEqual(testTemp, 70 + 105/exp(1))
    }
    
    func testMaxTemp() {
        XCTAssertEqual(testModel.Tmax, maxTemp)
    }
    
    func testUndefinedHeating() {
        XCTAssertNil(testModel.time(totemp: maxTemp + 10))
    }
    
    func testUndefinedCooling() {
        let testCool = testModel.time(totemp: testModel.Tamb - 10)
        XCTAssertNil(testCool)
    }
    
    func testModelFitUpdate() {
        let testparams = ThermalModelParams(name: "Test", a: 16, b: 640, note: "-")
        let measdata = HeatingDataSet()
        measdata.addDataPoint(HeatingDataPoint(time: 2.5, Tstart: 64, Tfinal: 155))
        measdata.addDataPoint(HeatingDataPoint(time: 4, Tstart: 64, Tfinal: 200))
        measdata.addDataPoint(HeatingDataPoint(time: 7.5, Tstart: 64, Tfinal: 300))
        measdata.addDataPoint(HeatingDataPoint(time: 5.5, Tstart: 64, Tfinal: 250))
        measdata.addDataPoint(HeatingDataPoint(time: 10, Tstart: 64, Tfinal: 365))
        measdata.addDataPoint(HeatingDataPoint(time: 12.25, Tstart: 64, Tfinal: 400))
        testparams.measurements = measdata
        
        let a0 = testparams.a
        let b0 = testparams.b
        
        let fitter = ThermalModelFitter(params: testparams)
        
        fitter.fitfromdata()
        let a1 = testparams.a
        let b1 = testparams.b
        
        fitter.fitfromdata()
        let a2 = testparams.a
        let b2 = testparams.b
        
        XCTAssertNotEqual(a0, a1)
        XCTAssertEqual(a1, a2, accuracy: 0.1)
        XCTAssertNotEqual(b0, b1)
        XCTAssertEqual(b1, b2, accuracy: 1)
    }
    
    func testModelFitAccuracy() {
        let testparams = ThermalModelParams(name: "Test", a: 10, b: 500, note: "")
        let measdata = HeatingDataSet()
        measdata.addDataPoint(HeatingDataPoint(time: 2.5, Tstart: 64, Tfinal: 155))
        measdata.addDataPoint(HeatingDataPoint(time: 4, Tstart: 64, Tfinal: 200))
        measdata.addDataPoint(HeatingDataPoint(time: 7.5, Tstart: 64, Tfinal: 300))
        measdata.addDataPoint(HeatingDataPoint(time: 5.5, Tstart: 64, Tfinal: 250))
        measdata.addDataPoint(HeatingDataPoint(time: 10, Tstart: 64, Tfinal: 365))
        measdata.addDataPoint(HeatingDataPoint(time: 12.25, Tstart: 64, Tfinal: 400))
        testparams.measurements = measdata
        
        let fitter = ThermalModelFitter(params: testparams)
        
        fitter.verbose = false
        fitter.fitfromdata()
 
        let a = testparams.a
        let b = testparams.b
        
        XCTAssertEqual(a, 16, accuracy: 0.5)
        XCTAssertEqual(b, 645, accuracy: 5)
    }
    
    func testModelFitConvergence() {
        let m = 128
        let testparams = ThermalModelParams(name: "Test", a: 10, b: 500, note: "")
        let measdata = HeatingDataSet()
        measdata.addDataPoint(HeatingDataPoint(time: 2.5, Tstart: 64, Tfinal: 155))
        measdata.addDataPoint(HeatingDataPoint(time: 4, Tstart: 64, Tfinal: 200))
        measdata.addDataPoint(HeatingDataPoint(time: 7.5, Tstart: 64, Tfinal: 300))
        measdata.addDataPoint(HeatingDataPoint(time: 5.5, Tstart: 64, Tfinal: 250))
        measdata.addDataPoint(HeatingDataPoint(time: 10, Tstart: 64, Tfinal: 365))
        measdata.addDataPoint(HeatingDataPoint(time: 12.25, Tstart: 64, Tfinal: 400))
        testparams.measurements = measdata
        
        let fitter = ThermalModelFitter(params: testparams)
        
        self.measure {
            for k in 1...m {
                let f = Double(k)/Double(m)
                testparams.a = Float(f*20.0 + 5.0)
                testparams.b = Float(f*800.0 + 200.0)
                
                fitter.fitfromdata()
                
                let a = testparams.a
                let b = testparams.b
                
                XCTAssertEqual(a, 16, accuracy: 1)
                XCTAssertEqual(b, 645, accuracy: 5)
            }
        }
    }

}
