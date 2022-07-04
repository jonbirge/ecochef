//
//  TimerController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 5/17/22.
//  Copyright © 2022 Birge & Fuller, LLC. All rights reserved.
//

import Foundation
import UIKit

class TimerController {
    var timerButton: TimerButton
    private var timer: Timer?
    private var selected: Bool = false
    private var cumtime: Float = 0  // min
    private var running: Bool = false
    private var startTime: Date?
    private let timeInt: Double = 0.2
    private let normalColor: UIColor = .systemGray
    private let selectedColor: UIColor = .systemOrange
    private let timingColor: UIColor = .systemRed
    private let thinEdge: CGFloat = 0
    private let selEdge: CGFloat = 2
    
    var isRunning: Bool {
        return running
    }
    
    var isSelected: Bool {
        return selected
    }
    
    init(_ timer: TimerButton) {
        timerButton = timer
        timerButton.setTitleColor(normalColor, for: .normal)
        timerButton.setEdgeThickness(thinEdge)
        cumtime = 5.0;
        updateTimes()
    }
    
    func toggle() {
        selected = !selected
        if selected {
            timerButton.setTitleColor(selectedColor, for: .normal)
            timerButton.setEdgeThickness(selEdge)
        } else {
            if isRunning {
                timerButton.setTitleColor(timingColor, for: .normal)
            } else {
                timerButton.setTitleColor(normalColor, for: .normal)
            }
            timerButton.setEdgeThickness(thinEdge)
        }
    }
    
    func reset() {
        stop()
        cumtime = 0
        updateTimes()
    }
    
    func start() {
        timerButton.setTitleColor(timingColor, for: .normal)
        running = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: timeInt, repeats: true) { (timer) in
            self.updateTimes()
        }
    }
    
    func stop() {
        if selected {
            timerButton.setTitleColor(selectedColor, for: .normal)
        } else {
            timerButton.setTitleColor(normalColor, for: .normal)
        }
        if running {
            running = false
            timer?.invalidate()
            cumtime = cumtime + secondsElapsed()
        }
    }
    
    func pause() {
        if running {
            timer?.invalidate()
        }
    }
    
    func resume() {
        if running {
            timer = Timer.scheduledTimer(withTimeInterval: timeInt, repeats: true) { (timer) in
                self.updateTimes()
            }
        }
    }
    
    // TODO: Replace with functional parameter setter
    func updateTimes() {
        if running {
            cumtime += secondsElapsed()
        }
        timerButton.curTime(cumtime)
    }
    
    private func secondsElapsed() -> Float {
        var seconds: TimeInterval = 0
        if let then = startTime {
            seconds = then.timeIntervalSinceNow
        }
        
        return Float(-seconds)
    }
    
    private func formatTimeFrom(seconds: Float) -> String {
        var minstr : String
        var secstr : String
        
        let min = Int(floor(seconds/60))
        if min < 10 {
            minstr = "0\(min)"
        } else {
            minstr = "\(min)"
        }
        let sec = Int(round(seconds - Float(60*min)))
        if sec < 10 {
            secstr = "0\(sec)"
        } else {
            secstr = "\(sec)"
        }
        let timeform = minstr + ":" + secstr
        
        return timeform
    }
}
