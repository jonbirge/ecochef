//
//  TimerViewController.swift
//  EcoChef
//
//  Copyright © 2017-2022 Birge Clocks. All rights reserved.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController, UNUserNotificationCenterDelegate {
    private var currentTimer: TimerController!  // convenience
    private var timerList: [TimerController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notification setup
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Timer controllers
        timerList.append(TimerController(timerButton1))
        timerList.append(TimerController(timerButton2))
        timerList.append(TimerController(timerButton3))
        timerList.append(TimerController(timerButton4))
        timerList.append(TimerController(timerButton5))
        timerList.append(TimerController(timerButton6))
        timerList.append(TimerController(timerButton7))
        timerList.append(TimerController(timerButton8))
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
            resetButton.isEnabled = false
        } else {
            startButton.setTitle("Start", for: .normal)
            resetButton.isEnabled = true
        }
    }
    
    // MARK: - IB
    
    @IBOutlet var startButton: UIButton!
    
    // TODO: Use single Action
    
    @IBAction func clickTimer(_ sender: TimerButton) {
        
    }
    
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
    
    @IBAction func changeTime(_ sender: UISlider) {
        let mins = sender.value
        currentTimer.timerButton.setTime = mins
        currentTimer.timerButton.curTime(mins)
    }
    
    @IBOutlet var resetButton: UIButton!
    
    @IBOutlet var timerButton1: TimerButton!
    
    @IBOutlet var timerButton2: TimerButton!
    
    @IBOutlet var timerButton3: TimerButton!
    
    @IBOutlet var timerButton4: TimerButton!
    
    @IBOutlet var timerButton5: TimerButton!
    
    @IBOutlet var timerButton6: TimerButton!
    
    @IBOutlet var timerButton7: TimerButton!
    
    @IBOutlet var timerButton8: TimerButton!
}
