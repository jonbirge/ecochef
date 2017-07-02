//
//  FirstViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/9/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit
import UserNotifications

class PreheatViewController : UIViewController, UNUserNotificationCenterDelegate {
    let smallstep: Float = 2
    let largestep: Float = 25
    let crossover: Float = 100
    let tempdefault: Float = 350
    let heatingColor: UIColor = UIColor.red
    let coolingColor: UIColor = UIColor.purple
    private var desiredTemp: Float = 350
    private var currentTemp: Float = 70
    let model = ThermalModel()
    let modelTimer = ThermalTimer()
    var modelData: [ThermalModelParams] = []
    private var state: EcoChefState?
    
    var Tamb : Float {
        get {
            return model.Tamb
        }
        set (newTamb) {
            model.Tamb = Quantize(temp: newTamb)
            state?.Tamb = model.Tamb
        }
    }
    
    var selectedModel: Int {
        get {
            return state!.selectedModel
        }
        set (newIndex) {
            state?.selectedModel = newIndex
            model.setfrom(params: modelData[state!.selectedModel])
        }
    }
    
    var stateURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("state")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelTimer.thermalModel = model
        LoadModelData()
        if let state = NSKeyedUnarchiver.unarchiveObject(withFile: stateURL.path) as? EcoChefState {
            self.state = state
        } else {
            print("state file not loaded! setting state from defaults.")
            self.state = EcoChefState()
        }
        UpdateAmbient()
        Reset()
    }

    private func LoadModelData() {
        var theparams : ThermalModelParams
        
        theparams = ThermalModelParams(name: "Gas oven")
        theparams.a *= 1.1
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric oven")
        theparams.a *= 1.2
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection oven")
        theparams.a *= 0.9
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Speed oven")
        theparams.a *= 0.8
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Outdoor grill")
        theparams.a *= 1.0
        modelData.append(theparams)
    }
    
    func Quantize(temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    func SetCurrent(temp:Float) {
        currentTemp = Quantize(temp: temp)
        currentTempLabel.text = String(Int(currentTemp))
        UpdateView()
    }
    
    func SetDesired(temp:Float) {
        desiredTemp = Quantize(temp: temp)
        desiredTempLabel.text = String(Int(desiredTemp))
        UpdateView()
    }
    
    func UpdateView() {
        // Colors
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
        
        // Run model
        let minfrac = model.time(totemp: desiredTemp, fromtemp: currentTemp)
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
    
    func UpdateAmbient() {
        model.Tamb = state!.Tamb
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
    
    func CheckTimerEnable() {
        if desiredTemp == currentTemp {
            startButton.isEnabled = false
        } else {
            startButton.isEnabled = true
        }
    }
    
    // MARK: timer functions
    
    private var timer: Timer?
    private var timerDisabledControls: [UIControl] = []
    private var timerRunning: Bool = false
    private var timerCurrentTemp: Float = 0
    
    func ResetTimer() {
        currentTempSlider.value = Float(timerCurrentTemp)
        StopTimer()
    }
    
    func StopTimer() {
        timerRunning = false
        timer?.invalidate()
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for theControl in timerDisabledControls {
            theControl.isEnabled = true
        }
        preheatLabel.isHidden = true
        startButton.setTitle("Start", for: UIControlState.normal)
        timerResetButton.isEnabled = false
        UpdateView()
        CheckTimerEnable()
    }
    
    func StartTimer() {
        // Timer
        modelTimer.startTimer(fromTemp: currentTemp, toTemp: desiredTemp)
        timer =
            Timer.scheduledTimer(timeInterval: 0.2, target: self,
                                 selector: #selector(PreheatViewController.TimerCount),
                                 userInfo: nil,
                                 repeats: true)
        
        // UI
        timerRunning = true
        timerCurrentTemp = currentTemp
        timerDisabledControls =
            [currentTempSlider, desiredTempSlider, tempResetButton]
        for theControl in timerDisabledControls {
            theControl.isEnabled = false
        }
        preheatLabel.isHidden = false
        if modelTimer.isHeating {
            preheatLabel.text = "Preheating"
            preheatLabel.textColor = heatingColor
        } else {
            preheatLabel.text = "Cooling"
            preheatLabel.textColor = coolingColor
        }
        startButton.setTitle("Stop", for: UIControlState.normal)
        timerResetButton.isEnabled = true
        
        // Notification
        let content = UNMutableNotificationContent()
        var notifyTitle: String
        if modelTimer.isHeating {
            notifyTitle = "Preheating done"
        } else {
            notifyTitle = "Cooling done"
        }
        let notifyText = "\(modelData[selectedModel]) should be \(Int(desiredTemp)) degrees."
        content.title = NSString.localizedUserNotificationString(forKey: notifyTitle, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: notifyText, arguments: nil)
        content.sound = UNNotificationSound(named: "birge-ring.aiff")

        let timeLeft = Double(modelTimer.minutesLeft())
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0*timeLeft, repeats: false)
        let request = UNNotificationRequest(identifier: "PreheatAlarm", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        center.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let alertOption = UNNotificationPresentationOptions.alert
        let soundOption = UNNotificationPresentationOptions.sound
        completionHandler(alertOption.union(soundOption))
    }
    
    func TimerCount() {
        let minutesLeft = modelTimer.minutesLeft()
        if minutesLeft > 0 {
            ShowTime(minutes: minutesLeft)
            let tempEst = modelTimer.tempEstimate()
            currentTempLabel.text = String(Int(round(tempEst)))
            currentTempSlider.value = tempEst
        } else {
            let Tset = desiredTempSlider.value
            currentTempSlider.value = Tset
            UpdateCurrent()
            StopTimer()
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
            settingsView.initialSelection = selectedModel
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let source = segue.source as? SettingsViewController else { return }
        
        // Pull data from SettingsViewController
        Tamb = source.Tamb
        UpdateAmbient()
        selectedModel = source.selectedModel
        UpdateView()
        
        // Save to disk
        NSKeyedArchiver.archiveRootObject(state!, toFile: stateURL.path)
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
    
    @IBAction func DesiredTouchUpIn() {
        CheckTimerEnable()
    }
    
    @IBAction func CurrentTouchUpIn() {
        CheckTimerEnable()
    }
    
    @IBAction func ResetButton(_ sender: UIButton) {
        Reset()
    }
}
