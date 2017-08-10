//
//  CalibrationViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 8/6/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController {
    var modelParams: ThermalModelParams!
    private var state: EcoChefState!
    private let smallstep: Float = 2
    private let largestep: Float = 10
    private let crossover: Float = 100
    private var currentTemp: Float = 70
    private var calTimer: CalibrationTimer!
    private var timer: Timer?
    private var initialCurrentTemp: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        state = app.state!
        
        calTimer = CalibrationTimer(params: modelParams, tamb: state.Tamb)
        
        UpdateLimits()
        Reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ResetTimer()
    }
    
    private func Quantize(_ temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    // Update view while time is not engaged
    // TODO: Integrate timer view updates
    func UpdateView() {
        // Pull from sliders
        currentTemp = round(currentTempSlider.value)
        
        // Labels
        currentTempLabel.text = String(Int(currentTemp))
        modelLabel.textColor = .darkGray
        modelLabel.text = modelParams.name
        
        ShowTime(minutes: nil)
    }
    
    func ShowTime(minutes: Float?) {
        if let min = minutes {
            let pretimemin = floor(min)
            let pretimesec = round(60*(min - pretimemin))
            minLabel.text = String(Int(pretimemin))
            var sectext : String
            if pretimesec < 10 {
                sectext = "0" + String(Int(pretimesec))
            } else {
                sectext = String(Int(pretimesec))
            }
            secLabel.text = sectext
        } else {
            secLabel.text = "00"
            minLabel.text = "00"
        }
    }
    
    private func UpdateLimits() {
        currentTempSlider.minimumValue = state.Tamb
        UpdateView()
    }
    
    func Reset() {
        currentTempSlider.value = currentTempSlider.minimumValue
        UpdateView()
    }
    
    // MARK: - Notification and timer functionality
    
    // Timer delegate function
    func TimerCount() {
        let mins = calTimer.minutesElapsed()
        ShowTime(minutes: mins)
    }
    
    private func EnableTimerControls() {
        startButton.setTitle("Start", for: UIControlState.normal)
        markButton.isEnabled = false
        UpdateView()
    }
    
    private func DisableTimerControls () {
        startButton.setTitle("Reset", for: UIControlState.normal)
        startButton.isEnabled = true
        markButton.isEnabled = true
    }
    
    func ResetTimer() {
        StopTimer()
        Reset()
    }
    
    func StopTimer() {
        calTimer.stopTimer()
        timer?.invalidate()
        EnableTimerControls()
    }
    
    func StartTimer() {
        // Timer
        calTimer.startTimer()
        timer =
            Timer.scheduledTimer(timeInterval: 0.5,
                                 target: self,
                                 selector: #selector(CalibrationViewController.TimerCount),
                                 userInfo: nil,
                                 repeats: true)
        
        // UI
        let modelname = modelParams.name
        modelLabel.text = "Calibrating \(modelname)"
        modelLabel.textColor = UIColor.red
        DisableTimerControls()
    }
    
    // MARK: - IB
    
    @IBAction func ambientClicked() {
        Reset()
    }
    
    @IBAction func currentTempChanged(_ sender: UISlider) {
        currentTemp = Quantize(sender.value)
        currentTempLabel.text = String(Int(currentTemp))
    }
    
    @IBAction func currentTempDoneChanging(_ sender: UISlider) {
        currentTempSlider.value = currentTemp
    }
    
    @IBAction func startTimerClicked() {
        if calTimer.isNotRunning {
            StartTimer()
        } else {
            ResetTimer()
        }
    }
    
    @IBAction func markClicked() {
        calTimer.mark(temp: currentTemp)
    }
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var startButton: TimerButton!
    @IBOutlet weak var markButton: TimerButton!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentTempSlider: UISlider!
}
