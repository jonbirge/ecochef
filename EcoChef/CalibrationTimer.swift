//
//  CalibrationTimer.swift
//  EcoChef
//
//  Created by Jonathan Birge on 8/8/17.
//  Copyright © 2022 Birge & Fuller. All rights reserved.
//

import Foundation

class CalibrationTimer {
    var modelParams: ThermalModelParams
    var Tamb: Float = 0
    private var startTime: Date?
    private var localIsRunning: Bool = false
    
    var isRunning: Bool {
        return localIsRunning
    }
    
    var isNotRunning: Bool {
        return !localIsRunning
    }
    
    init(params: ThermalModelParams, tamb: Float) {
        modelParams = params
        Tamb = tamb
    }
    
    func mark(temp: Float) {
        print("mark! at \(minutesElapsed())")
        let elapsed = minutesElapsed()
        modelParams.addDataPoint(time: elapsed,
                                 Tstart: Tamb,
                                 Tfinal: temp,
                                 Tamb: Tamb)
        // TODO: write to disk here
    }

    func startTimer() {
        print("timer starting")
        startTime = Date()
        localIsRunning = true
    }
    
    func stopTimer() {
        print("timer stopping")
        localIsRunning = false
    }
    
    func secondsElapsed() -> Float {
        guard localIsRunning else { return 0 }
        let now = Date()
        var seconds: TimeInterval = 0
        if let then = startTime {
            seconds = now.timeIntervalSince(then)
        }
        return Float(seconds)
    }
    
    func minutesElapsed() -> Float {
        return secondsElapsed()/60.0
    }
}
