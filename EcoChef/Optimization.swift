//
//  Optimization.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/17/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

protocol Fittable {
    var fitnparams: Int { get }
    var fitnpoints: Int { get }
    var fitinitparams: [Double] { get }
    func fitresiduals(for params:[Double]) throws -> [Double]
}

enum OptimizationError: Error {
    case undefinedResidual
    case didNotConverge
}

class Fitter {
    var system: Fittable
    var initialparams: [Double]? = nil
    private let fdrel: Double = 0.0001
    
    init(with sys: Fittable) {
        self.system = sys
    }
    
    func fit() throws -> [Double] {
        return [0.0]
    }
    
    // Matrix with columns (vectors) representing points and rows (vector of vectors) representing parameters.
    func jacobian(at params:[Double]) throws -> [[Double]] {
        var J: [[Double]] = []
        for kp in 0..<params.count {
            let dp = params[kp] * fdrel
            var params1 = params
            params1[kp] = params1[kp] + dp
            let x0 = try residuals(at: params)
            let x1 = try residuals(at: params1)
            J.append((x1 - x0)/dp)
        }
        return J
    }
    
    func jacobian(at params:Matrix<Double>) throws -> Matrix<Double> {
        let Jdata = try jacobian(at: params[column:0])
        return Matrix<Double>(Jdata)
    }
    
    func residuals(at params:[Double]) throws -> [Double] {
        return try system.fitresiduals(for: params)
    }
    
    func residuals(at beta:Matrix<Double>) throws -> Matrix<Double> {
        let betarray = beta.grid
        let residarray: [Double] = try residuals(at: betarray)
        return Matrix<Double>(residarray)
    }
    
    func setInitial(params: [Double]) {
        initialparams = params
    }
}

class GaussNewtonFitter : Fitter {
    override func fit() throws -> [Double] {
        var beta: Matrix<Double>
        if let initialparams = initialparams {
            beta = Matrix<Double>(initialparams)
        } else {
            beta = Matrix<Double>(system.fitinitparams)
        }
        var fitting = true
        var iterations = 0
        while fitting {
            let Jt = try jacobian(at: beta)  // transpose
            let Jpi = inv(Jt * transpose(Jt)) * Jt  // pseudo-inverse
            let r = try residuals(at: beta)
            beta = beta - Jpi * r
            iterations += 1
            if iterations > 32 {
                fitting = false
            }
        }
        return beta[column:0]
    }
}
