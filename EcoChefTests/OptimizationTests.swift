//
//  OptimizationTests.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/18/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import XCTest

class GenExponentialTest: Fittable {
    var x: [Double] = []
    var y: [Double] = []
    var n: Int
    
    var fitnparams: Int {
        return 2
    }
    
    var fitnpoints: Int {
        return x.count
    }
    
    var fitinitparams: [Double] {
        return [0.9, 0.9]
    }
    
    init(n: Int) {
        self.n = n
        for k in 0...n-1 {
            self.x.append(Double(k)/Double(n))
            self.y.append(evalfun(at:x[k], with:[1.0, 1.0]))
        }
    }
    
    func evalfun(at x: Double, with params: [Double]) -> Double {
        return params[0] * exp(-params[1] * x)
    }
    
    func fitresiduals(for params: [Double]) -> [Double] {
        var res: [Double] = []
        for k in 0...(x.count - 1) {
            res.append(evalfun(at:x[k], with:params) - y[k])
        }
        return res
    }
}

class ExponentialTest: GenExponentialTest {
    
    init() {
        let x0: [Double] = [0, 1, 2, 3, 4]
        let y0: [Double] = [1.047, 0.2864, 0.288, 0.07777, 0.121, -0.0001342]

        super.init(n: x0.count)

        self.x = x0
        self.y = y0
    }
    
}

class OptimizationTests: XCTestCase {
    var funtest = ExponentialTest()
    var gentest = GenExponentialTest(n: 128)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGaussNewtonFit() {
        let fitter = GaussNewtonFitter(with: funtest)
        var p: [Double] = fitter.fit()
        XCTAssertEqualWithAccuracy(p[0], 1.01869, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(p[1], 0.90268, accuracy: 0.01)
    }
    
    func testGaussNewtonPerformance() {
        let m = 200
        let fitter = GaussNewtonFitter(with: gentest)
        self.measure {
            var p: [Double]
            for k in 1...m {
                let tc0 = Double(k)/Double(m) + 0.5
                fitter.initialparams = [0.5, tc0]
                p = fitter.fit()
                XCTAssertEqualWithAccuracy(p[0], 1.0, accuracy: 0.01)
                XCTAssertEqualWithAccuracy(p[1], 1.0, accuracy: 0.01)
            }
        }
    }
    
}
