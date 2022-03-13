//
//  TimerViewController.swift
//  EcoChef
//
//  Copyright © 2017-2022 Birge Clocks. All rights reserved.
//

import UIKit
import UserNotifications

// TODO: Turn into real view controller with graphics
/// Pseudo-view controller for cooking timer
class DualTimerController {
    var topLabel: UILabel
    var bottomLabel: UILabel
    var sumLabel: UILabel
    var timerButton: TimerButton
    private var timer: Timer?
    private var selected: Bool = false
    private var topside: Bool = true
    private var topcum: Float = 0
    private var bottomcum: Float = 0
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
    
    init(_ top: UILabel, _ bottom: UILabel, _ sum: UILabel,
         _ timer: TimerButton) {
        topLabel = top
        bottomLabel = bottom
        sumLabel = sum
        timerButton = timer
        
        timerButton.setTitleColor(normalColor, for: .normal)
        timerButton.setEdgeThickness(thinEdge)
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
    
    func flip() {
        if running {
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
            if topside {
                topcum = topcum + secondsElapsed()
            } else {
                bottomcum = topcum + secondsElapsed()
            }
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
    
    func updateTimes() {
        var topTotal: Float = topcum
        var bottomTotal: Float = bottomcum
        if running {
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
        
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Timer controllers
        timerList.append(DualTimerController(topLabel1, bottomLabel1, sumLabel1, timerButton1))
        timerList.append(DualTimerController(topLabel2, bottomLabel2, sumLabel2, timerButton2))
        timerList.append(DualTimerController(topLabel3, bottomLabel3, sumLabel3, timerButton3))
        timerList.append(DualTimerController(topLabel4, bottomLabel4, sumLabel4, timerButton4))
        timerList.append(DualTimerController(topLabel5, bottomLabel5, sumLabel5, timerButton5))
        timerList.append(DualTimerController(topLabel6, bottomLabel6, sumLabel6, timerButton6))
        timerList.append(DualTimerController(topLabel7, bottomLabel7, sumLabel7, timerButton7))
        timerList.append(DualTimerController(topLabel8, bottomLabel8, sumLabel8, timerButton8))
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
    
    @IBOutlet var startButton: UIButton!
    
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
    
    @IBAction func clickTimer6(_ sender: UIButton) {
        selectTimer(5)
    }
    
    @IBAction func clickTimer7(_ sender: UIButton) {
        selectTimer(6)
    }
    
    @IBAction func clickTimer8(_ sender: UIButton) {
        selectTimer(7)
    }
    
    @IBAction func startCounter(_ sender: UIButton) {
        if currentTimer.isRunning {
            currentTimer.stop()
        } else {
            currentTimer.start()
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
    
    @IBOutlet var timerButton1: TimerButton!
    @IBOutlet var topLabel1: UILabel!
    @IBOutlet var bottomLabel1: UILabel!
    @IBOutlet var sumLabel1: UILabel!
    
    @IBOutlet var timerButton2: TimerButton!
    @IBOutlet var topLabel2: UILabel!
    @IBOutlet var bottomLabel2: UILabel!
    @IBOutlet var sumLabel2: UILabel!
    
    @IBOutlet var timerButton3: TimerButton!
    @IBOutlet var topLabel3: UILabel!
    @IBOutlet var bottomLabel3: UILabel!
    @IBOutlet var sumLabel3: UILabel!

    @IBOutlet var timerButton4: TimerButton!
    @IBOutlet var topLabel4: UILabel!
    @IBOutlet var bottomLabel4: UILabel!
    @IBOutlet var sumLabel4: UILabel!
    
    @IBOutlet var timerButton5: TimerButton!
    @IBOutlet var topLabel5: UILabel!
    @IBOutlet var bottomLabel5: UILabel!
    @IBOutlet var sumLabel5: UILabel!
    
    @IBOutlet var timerButton6: TimerButton!
    @IBOutlet var topLabel6: UILabel!
    @IBOutlet var bottomLabel6: UILabel!
    @IBOutlet var sumLabel6: UILabel!
    
    @IBOutlet var timerButton7: TimerButton!
    @IBOutlet var topLabel7: UILabel!
    @IBOutlet var bottomLabel7: UILabel!
    @IBOutlet var sumLabel7: UILabel!
    
    @IBOutlet var timerButton8: TimerButton!
    @IBOutlet var topLabel8: UILabel!
    @IBOutlet var bottomLabel8: UILabel!
    @IBOutlet var sumLabel8: UILabel!
}
