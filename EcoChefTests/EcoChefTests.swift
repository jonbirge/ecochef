//
//  EcoChefTests.swift
//  EcoChefTests
//
//  Created by Jonathan Birge on 7/8/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import XCTest

class EcoChefTests: XCTestCase {
    var testModel: ThermalModel = ThermalModel()
    var maxTemp: Float = 0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testModel.a = 10
        testModel.b = 500
        testModel.Tamb = 70
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        var temp: Float = 0
        self.measure {
            for _ in 1...32 {
                for Tstart in 80...Int(floor(self.maxTemp)-1) {
                    for Tfinal in 80...Int(floor(self.maxTemp)-1) {
                        temp += self.testModel.time(totemp: Float(Tfinal), fromtemp: Float(Tstart))!
                        temp -= self.testModel.time(totemp: Float(Tstart), fromtemp: Float(Tfinal))!
                    }
                }
            }
        }
    }
    
}
