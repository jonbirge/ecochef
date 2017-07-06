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
    var isHeating: Bool = true
    private var timerMinutes: Float = 0
    private var startTemp: Float = 0
    
    func startTimer(fromTemp: Float, toTemp: Float) {
        startTime = Date()
        timerMinutes = thermalModel!.time(totemp: toTemp, fromtemp: fromTemp)
        if toTemp > fromTemp {
            isHeating = true
        } else {
            isHeating = false
        }
        startTemp = fromTemp
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
