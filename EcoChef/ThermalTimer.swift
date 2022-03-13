//
//  ThermalTimer.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/27/17.
//  Copyright © 2022 Birge & Fuller. All rights reserved.
//

import Foundation

// Timer model
class ThermalTimer {
    var thermalModel: ThermalModel?
    var snoozeTime: Float = 0
    var isHeating: Bool = true
    var initialTemp: Float = 0
    private var snoozing: Bool = false
    private var startTime: Date?
    private var stopTime: Date?
    private var timerMinutes: Float = 0
    private var startTemp: Float = 0
    private var running: Bool = false
    
    var isRunning: Bool {
        return running
    }
    
    var isNotRunning: Bool {
        return !running
    }
    
    var isNotDone: Bool {
        return minutesLeft() > 0
    }
    
    var isSnoozing: Bool {
        return snoozing
    }
    
    func stopTimer() {
        running = false
        stopTime = Date()
    }
    
    func startTimer(fromTemp: Float, toTemp: Float) {
        running = true
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
        running = true
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
        let now = running ? Date() : stopTime!
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
