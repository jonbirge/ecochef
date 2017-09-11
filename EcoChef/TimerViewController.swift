//
//  TimerViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 9/5/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class DualTimerController {
    var topLabel: UILabel
    var bottomLabel: UILabel
    var sumLabel: UILabel
    var timerButton: UIButton
    private var topside: Bool = true
    private var topcum: Float = 0
    private var bottomcum: Float = 0
    private var localIsRunning: Bool = false
    private var startTime: Date?
    private var timer: Timer?
    
    var isRunning: Bool {
        return localIsRunning
    }
    
    init(_ top: UILabel, _ bottom: UILabel, _ sum: UILabel,
         _ timer: UIButton) {
        topLabel = top
        bottomLabel = bottom
        sumLabel = sum
        timerButton = timer
    }
    
    func flip() {
        if topside {
            topcum += secondsElapsed()
        } else {
            bottomcum += secondsElapsed()
        }
        startTime = Date()
        topside = !topside
    }
    
    func reset() {
        topcum = 0
        bottomcum = 0
        localIsRunning = false
        timer?.invalidate()
    }
    
    func start() {
        localIsRunning = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
            self.updateTimes()
        }
    }
    
    func stop() {
        localIsRunning = false
        if topside {
            topcum = topcum + secondsElapsed()
        } else {
            bottomcum = topcum + secondsElapsed()
        }
    }
    
    func updateTimes() {
        var topTotal: Float = topcum
        var bottomTotal: Float = bottomcum
        if localIsRunning {
            if topside {
                topTotal += secondsElapsed()
            } else {
                bottomTotal += secondsElapsed()
            }
        }
        let sumTotal: Float = topTotal + bottomTotal
        topLabel.text = formatTimeFrom(seconds: topTotal)
        bottomLabel.text = formatTimeFrom(seconds: bottomTotal)
        sumLabel.text = formatTimeFrom(seconds: sumTotal)
    }
    
    private func secondsElapsed() -> Float {
        var seconds: TimeInterval = 0
        if let then = startTime {
            seconds = then.timeIntervalSinceNow
        }
        return -Float(seconds)
    }
    
    private func formatTimeFrom(seconds: Float) -> String {
        let min = Int(floor(seconds/60))
        let sec = round(10*(seconds - Float(60*min)))/10
        let timeform = "\(min):\(sec)"
        return timeform
    }
}

class TimerViewController: UIViewController {
    var currentTimer: DualTimerController!
    var timerList: [DualTimerController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerList.append(DualTimerController(topLabel1, bottomLabel1, sumLabel1, timerButton1))
        currentTimer = timerList.first
    }

    // MARK: - IB
    @IBAction func clickTimer1(_ sender: UIButton) {
    }
    
    @IBAction func startCounter(_ sender: UIButton) {
        if currentTimer.isRunning {
            currentTimer?.stop()
        } else {
            currentTimer?.start()
        }
    }
    
    @IBAction func clickTurn(_ sender: UIButton) {
        currentTimer.flip()
    }
    
    @IBOutlet weak var timerButton1: TimerButton!
    @IBOutlet weak var bottomLabel1: UILabel!
    @IBOutlet weak var topLabel1: UILabel!
    @IBOutlet weak var sumLabel1: UILabel!
}
