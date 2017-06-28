//
//  FirstViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/9/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit
import UserNotifications

class PreheatViewController : UIViewController {
    let smallstep: Float = 2
    let largestep: Float = 25
    let crossover: Float = 100
    let tempdefault: Float = 350
    let heatingColor: UIColor =
        UIColor(hue: 0.0, saturation: 0.95, brightness: 0.8, alpha: 1)
    let coolingColor: UIColor =
        UIColor(hue: 0.6, saturation: 0.95, brightness: 1, alpha: 1)
    private var desiredTemp: Float = 250
    private var currentTemp: Float = 70
    let model = ThermalModel()
    var modelData: [ThermalModelParams] = []
    let modelTimer = ThermalTimer()
    
    var Tamb : Float {
        get {
            return model.Tamb
        }
        set (newTamb) {
            model.Tamb = quantize(temp: newTamb)
        }
    }
    
    private var modelIndex: Int = 0
    var selectedModel: Int {
        get {
            return modelIndex
        }
        set (newIndex) {
            modelIndex = newIndex
            model.setfrom(params: modelData[modelIndex])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadModelData()
        modelTimer.thermalModel = model
        modelIndex = 1
        Tamb = 72.0
        UpdateAmbientLimits()
        Reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func LoadModelData() {
        var theparams : ThermalModelParams
        
        theparams = ThermalModelParams(name: "Gas Oven")
        theparams.a *= 1.1
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric Oven")
        theparams.a *= 1.2
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection Oven")
        theparams.a *= 0.9
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Speed Oven")
        theparams.a *= 0.8
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Outdoor Grill")
        theparams.a *= 1.0
        modelData.append(theparams)
    }
    
    func quantize(temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    func SetCurrent(temp:Float) {
        currentTemp = quantize(temp: temp)
        currentTempLabel.text = String(Int(currentTemp))
        UpdateColor()
        UpdateTime()
    }
    
    func SetDesired(temp:Float) {
        desiredTemp = quantize(temp: temp)
        desiredTempLabel.text = String(Int(desiredTemp))
        UpdateColor()
        UpdateTime()
    }
    
    func UpdateColor() {
        var uiColor: UIColor
        switch desiredTemp - currentTemp {
        case let x where x > 0:
            uiColor = heatingColor
        case let x where x < 0:
            uiColor = coolingColor
        default:
            uiColor = .darkGray
        }
        desiredTempSlider.minimumTrackTintColor = uiColor
    }
    
    func UpdateTime() {
        // Run model
        let minfrac = model.time(totemp: desiredTemp, fromtemp: currentTemp)
        
        // Update display
        ShowTime(minutes: minfrac)
    }
    
    func ShowTime(minutes: Float) {
        let pretimemin = floor(minutes)
        let pretimesec = round(60*(minutes - pretimemin))
        minLabel.text = String(Int(pretimemin))
        
        var sectext : String
        if pretimesec < 10 {
            sectext = "0" + String(Int(pretimesec))
        } else {
            sectext = String(Int(pretimesec))
        }
        secLabel.text = sectext
    }
    
    func UpdateCurrent() {
        SetCurrent(temp: currentTempSlider.value)
    }
    
    func UpdateDesired() {
        SetDesired(temp: desiredTempSlider.value)
    }
    
    func UpdateAmbientLimits() {
        currentTempSlider.minimumValue = Tamb
        desiredTempSlider.minimumValue = Tamb + smallstep
            UpdateCurrent()
        if desiredTempSlider.value < (Tamb + smallstep) {
            desiredTempSlider.value = Tamb + smallstep
         }
        UpdateDesired()
    }
    
    func Reset() {
        currentTempSlider.value = currentTempSlider.minimumValue
        desiredTempSlider.value = tempdefault
        UpdateCurrent()
        UpdateDesired()
    }
    
    // MARK: timer functions
    
    var timer: Timer?
    private var timerDisabledControls: [UIControl] = []
    private var timerRunning: Bool = false
    private var oldCurrentTemp: Float = 0
    
    private func ResetTimer() {
        currentTempSlider.value = Float(oldCurrentTemp)
        StopTimer()
    }
    
    private func StopTimer() {
        timer?.invalidate()
        timerRunning = false
        for theControl in timerDisabledControls {
            theControl.isEnabled = true
        }
        preheatLabel.textColor = .gray
        startButton.setTitle("Start", for: UIControlState.normal)
        timerResetButton.isEnabled = false
        UpdateCurrent()
        UpdateTime()
    }
    
    func StartTimer() {
        // UI
        timerRunning = true
        oldCurrentTemp = currentTemp
        timerDisabledControls =
            [currentTempSlider, desiredTempSlider, tempResetButton]
        for theControl in timerDisabledControls {
            theControl.isEnabled = false
        }
        preheatLabel.textColor = .red
        startButton.setTitle("Stop", for: UIControlState.normal)
        timerResetButton.isEnabled = true
        
        // Timer
        modelTimer.startTimer(fromTemp: currentTemp, toTemp: desiredTemp)
        timer =
            Timer.scheduledTimer(timeInterval: 0.2, target: self,
                                 selector: #selector(PreheatViewController.CountUp),
                                 userInfo: nil,
                                 repeats: true)
        
        // Notification
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Preheat timer", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: modelData[selectedModel].name + " is preheated.",
                                                                arguments: nil)

        let timeLeft = Double(modelTimer.minutesLeft())
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0*timeLeft, repeats: false)
        let request = UNNotificationRequest(identifier: "PreheatAlarm", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func CountUp() {
        let minutesLeft = modelTimer.minutesLeft()
        if minutesLeft > 0 {
            ShowTime(minutes: minutesLeft)
            let tempEst = modelTimer.tempEstimate()
            currentTempLabel.text = String(Int(round(tempEst)))
            currentTempSlider.value = tempEst
        } else {
            ResetTimer()
            let Tset = desiredTempSlider.value
            currentTempSlider.value = Tset
            UpdateCurrent()
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.initialTamb = Tamb
            var modelNames: [String] = []
            for themodel in modelData {
                modelNames.append("\(themodel)")
            }
            settingsView.modelNames = modelNames
            settingsView.initialSelection = modelIndex
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let source = segue.source as? SettingsViewController else { return }
        Tamb = source.Tamb
        UpdateAmbientLimits()
        modelIndex = source.selectedModel
        model.setfrom(params: modelData[modelIndex])
        UpdateTime()
    }
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var desiredTempLabel: UILabel!
    @IBOutlet weak var currentTempSlider: UISlider!
    @IBOutlet weak var desiredTempSlider: UISlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerResetButton: UIButton!
    @IBOutlet weak var curTempLabel: UILabel!
    @IBOutlet weak var tempResetButton: UIButton!
    @IBOutlet weak var preheatLabel: UILabel!
    
    @IBAction func StartButton(_ sender: UIButton) {
        if timerRunning == false {
            StartTimer()
        } else {
            StopTimer()
        }
    }
    
    @IBAction func TimerReset(_ sender: UIButton) {
       ResetTimer()
    }
    
    @IBAction func CurrentTempChange(_ sender: UISlider) {
        UpdateCurrent()
    }
    
    @IBAction func DesiredTempChange(_ sender: UISlider) {
        UpdateDesired()
    }

    @IBAction func ResetButton(_ sender: UIButton) {
        Reset()
    }
}
