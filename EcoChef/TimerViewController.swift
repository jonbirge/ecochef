//
//  TimerViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 9/5/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit
import UserNotifications

class DualTimerController {
    private var topLabel: UILabel
    private var bottomLabel: UILabel
    private var sumLabel: UILabel
    private var timerButton: UIButton
    var isSelected: Bool = false
    private var topside: Bool = true
    private var topcum: Float = 0
    private var bottomcum: Float = 0
    private var localIsRunning: Bool = false
    private var startTime: Date?
    private var timer: Timer?
    private let timeInt: Double = 0.2
    
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
    
    func toggle() {
        isSelected = !isSelected
        if isSelected {
            timerButton.setTitleColor(.red, for: .normal)
        } else {
            timerButton.setTitleColor(.black, for: .normal)
        }
    }
    
    func flip() {
        if localIsRunning {
            if topside {
                topcum += secondsElapsed()
            } else {
                bottomcum += secondsElapsed()
            }
            startTime = Date()
            topside = !topside
        }
    }
    
    func reset() {
        stop()
        topcum = 0
        bottomcum = 0
        updateTimes()
    }
    
    func start() {
        localIsRunning = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: timeInt, repeats: true) { (timer) in
            self.updateTimes()
        }
    }
    
    func stop() {
        if localIsRunning {
            localIsRunning = false
            timer?.invalidate()
            if topside {
                topcum = topcum + secondsElapsed()
            } else {
                bottomcum = topcum + secondsElapsed()
            }
        }
    }
    
    func pause() {
        if localIsRunning {
            timer?.invalidate()
        }
    }
    
    func resume() {
        if localIsRunning {
            timer = Timer.scheduledTimer(withTimeInterval: timeInt, repeats: true) { (timer) in
                self.updateTimes()
            }
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
        let sumTotal: Float = floor(topTotal) + floor(bottomTotal)
        topLabel.text = formatTimeFrom(seconds: floor(topTotal))
        bottomLabel.text = formatTimeFrom(seconds: floor(bottomTotal))
        sumLabel.text = formatTimeFrom(seconds: sumTotal)
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

class TimerViewController: UIViewController, UNUserNotificationCenterDelegate {
    private var currentTimer: DualTimerController!  // convenience
    private var timerList: [DualTimerController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notification setup
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didBecomeActive), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // Timer controllers
        timerList.append(DualTimerController(topLabel1, bottomLabel1, sumLabel1, timerButton1))
        timerList.append(DualTimerController(topLabel2, bottomLabel2, sumLabel2, timerButton2))
        timerList.append(DualTimerController(topLabel3, bottomLabel3, sumLabel3, timerButton3))
        timerList.append(DualTimerController(topLabel4, bottomLabel4, sumLabel4, timerButton4))
        timerList.append(DualTimerController(topLabel5, bottomLabel5, sumLabel5, timerButton5))
        currentTimer = timerList.first
        currentTimer.toggle()
    }
    
    @objc func didEnterBackground() {
        for eachTimer in timerList {
            eachTimer.pause()
        }
    }
    
    @objc func didBecomeActive() {
        for eachTimer in timerList {
            eachTimer.resume()
        }
    }
    
    private func selectTimer(_ num: Int) {
        currentTimer.toggle()
        currentTimer = timerList[num]
        currentTimer.toggle()
        updateView()
    }

    private func updateView() {
        if currentTimer.isRunning {
            startButton.setTitle("Stop", for: .normal)
        } else {
            startButton.setTitle("Start", for: .normal)
        }
    }
    
    // MARK: - IB
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func clickTimer1(_ sender: UIButton) {
        selectTimer(0)
    }
    
    @IBAction func clickTimer2(_ sender: UIButton) {
        selectTimer(1)
    }
    
    @IBAction func clickTimer3(_ sender: UIButton) {
        selectTimer(2)
    }
    
    @IBAction func clickTimer4(_ sender: UIButton) {
        selectTimer(3)
    }
    
    @IBAction func clickTimer5(_ sender: UIButton) {
        selectTimer(4)
    }
    
    @IBAction func startCounter(_ sender: UIButton) {
        if currentTimer.isRunning {
            currentTimer?.stop()
        } else {
            currentTimer?.start()
        }
        updateView()
    }
    
    @IBAction func clickTurn(_ sender: UIButton) {
        currentTimer.flip()
    }
    
    @IBAction func clickReset(_ sender: UIButton) {
        currentTimer.reset()
    }
    
    @IBAction func clickResetAll(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reset all timers?", message: nil, preferredStyle: .actionSheet)
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) {
            action in
            for eachTimer in self.timerList {
                eachTimer.reset()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBOutlet weak var timerButton1: TimerButton!
    @IBOutlet weak var topLabel1: UILabel!
    @IBOutlet weak var bottomLabel1: UILabel!
    @IBOutlet weak var sumLabel1: UILabel!
    
    @IBOutlet weak var timerButton2: TimerButton!
    @IBOutlet weak var topLabel2: UILabel!
    @IBOutlet weak var bottomLabel2: UILabel!
    @IBOutlet weak var sumLabel2: UILabel!
    
    @IBOutlet weak var timerButton3: TimerButton!
    @IBOutlet weak var topLabel3: UILabel!
    @IBOutlet weak var bottomLabel3: UILabel!
    @IBOutlet weak var sumLabel3: UILabel!

    @IBOutlet weak var timerButton4: TimerButton!
    @IBOutlet weak var topLabel4: UILabel!
    @IBOutlet weak var bottomLabel4: UILabel!
    @IBOutlet weak var sumLabel4: UILabel!
    
    @IBOutlet weak var timerButton5: TimerButton!
    @IBOutlet weak var topLabel5: UILabel!
    @IBOutlet weak var bottomLabel5: UILabel!
    @IBOutlet weak var sumLabel5: UILabel!
}
