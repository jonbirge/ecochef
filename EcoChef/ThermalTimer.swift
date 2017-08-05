//
//  ThermalTimer.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/27/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

// Timer model
class ThermalTimer {
    var thermalModel: ThermalModel?
    var startTime: Date?
    var stopTime: Date?
    var snoozeTime: Float = 0
    var isHeating: Bool = true
    var initialTemp: Float = 0
    var snoozing: Bool = false
    private var timerMinutes: Float = 0
    private var startTemp: Float = 0
    private var localIsRunning: Bool = false
    
    var isRunning: Bool {
        return localIsRunning
    }
    
    var isNotRunning: Bool {
        return !localIsRunning
    }
    
    var isNotDone: Bool {
        return minutesLeft() > 0
    }
    
    func stopTimer() {
        localIsRunning = false
        stopTime = Date()
    }
    
    func startTimer(fromTemp: Float, toTemp: Float) {
        localIsRunning = true
        initialTemp = fromTemp
        if let timerMinutes = thermalModel!.time(totemp: toTemp, fromtemp: fromTemp) {
            startTime = Date()
            self.timerMinutes = timerMinutes
            if toTemp > fromTemp {
                isHeating = true
            } else {
                isHeating = false
            }
            startTemp = fromTemp
        }
    }
    
    func snoozeTimer(for minutes: Float) {
        localIsRunning = true
        snoozing = true
        timerMinutes = timerMinutes + minutes
    }
    
    func minutesLeft() -> Float {
        return timerMinutes - minutesElapsed()
    }
    
    func tempEstimate() -> Float {
        let minElapsed = minutesElapsed()
        if isHeating {
            return thermalModel!.tempAfterHeating(time: minElapsed,
                                                  fromtemp: startTemp)
        } else {
            return thermalModel!.tempAfterCooling(time: minutesElapsed(),
                                                  fromtemp: startTemp)
        }
    }
    
    func secondsElapsed() -> Float {
        let now = localIsRunning ? Date() : stopTime!
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
