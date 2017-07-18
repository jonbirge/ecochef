//
//  Optimization.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/17/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

protocol Optimizable {
    var optdim: Int { get }
    func optmerit(for x:[Double]) -> Double
}

protocol Fittable {
    var fitdim: Int { get }
    func fiterrvector(for x:[Double]) -> [Double]
}

class Optimizer {
    var system: Optimizable
    
    init(with sys: Optimizable) {
        self.system = sys
    }
    
    func fdgrad() -> [Double] {
        return []
    }
    
    // func for line search?
    
    func optimize() {
        // abstract
    }
    
    // utility
    func merit(for x:[Double]) -> Double {
        return system.optmerit(for: x)
    }
}

class Fitter {
    var system: Fittable
    
    init(with sys: Fittable) {
        self.system = sys
    }
    
    func fit() {
        //abstract
    }
    
    func fd(for ksys:Int, kx:Int) -> Double {
        return 0
    }
    
    func jacobian() -> [[Double]] {
        return [[]]
    }
    
    func errvector(for x:[Double]) -> [Double] {
        return system.fiterrvector(for: x)
    }
}

class GaussNewtonFitter : Fitter {
    override func fit() {
        
    }
}
