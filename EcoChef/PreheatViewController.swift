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
    let heatingColor: UIColor = UIColor.red
    let coolingColor: UIColor = UIColor.purple
    private var desiredTemp: Float = 350
    private var currentTemp: Float = 70
    let model = ThermalModel()
    let modelTimer = ThermalTimer()
    var modelData = ThermalModelData()
    private var state: EcoChefState?
    
    var Tamb : Float {
        get { return model.Tamb }
        set (newTamb) {
            model.Tamb = Quantize(newTamb)
            state?.Tamb = model.Tamb
        }
    }
    
    var stateURL: URL {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsURL.appendingPathComponent("state")
    }
    
    // MARK: - Startup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelTimer.thermalModel = model
        modelData.LoadModelData()
        LoadState()
        UpdateFromState()
        UpdateLimits()
        Reset()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didBecomeActive), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)

        let usernotificationCenter = UNUserNotificationCenter.current()
        usernotificationCenter.delegate = self
        
        let earlyAction = UNNotificationAction(identifier: "TIMER_EARLY", title: "Not preheated",
                                                options: .destructive)
        let rightAction = UNNotificationAction(identifier: "TIMER_GOOD", title: "Preheated",
                                              options: UNNotificationActionOptions(rawValue: 0))
        let timerFeedbackCategory = UNNotificationCategory(identifier: "TIMER_FEEDBACK", actions: [earlyAction, rightAction],
                                                   intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        let timerDoneCategory = UNNotificationCategory(identifier: "TIMER_DONE", actions: [],
                                                   intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        usernotificationCenter.setNotificationCategories([timerFeedbackCategory, timerDoneCategory])
    }
    
    func didEnterBackground() {
        if modelTimer.isRunning {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func didBecomeActive() {
        if modelTimer.isRunning {
            timer =
                Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(PreheatViewController.TimerCount),
                                     userInfo: nil,
                                     repeats: true)
        }
    }
    
    // MARK: - State
    
    private func LoadState() {
        if let state = NSKeyedUnarchiver.unarchiveObject(withFile: stateURL.path) as? EcoChefState {
            self.state = state
        } else {
            self.state = EcoChefState()
        }
    }
    
    private func UpdateFromState() {
        desiredTempSlider.value = state!.desiredTemp
        modelData.selectedIndex = state!.selectedModel
        model.setfrom(params: modelData.selectedModelData)
        UpdateView()
    }
    
    func WriteStateToDisk() {
        state!.desiredTemp = desiredTemp
        NSKeyedArchiver.archiveRootObject(state!, toFile: stateURL.path)
    }
    
    // MARK: - UI & model

    private func Quantize(_ temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    func UpdateView() {
        // Pull from sliders
        currentTemp = round(currentTempSlider.value)
        desiredTemp = Quantize(desiredTempSlider.value)
        
        // Labels
        currentTempLabel.text = String(Int(currentTemp))
        desiredTempLabel.text = String(Int(desiredTemp))
        
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
        ShowTime(minutes: minfrac!)  // faster?
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
            secLabel.text = "--"
            minLabel.text = "--"
        }
    }
    
    func UpdateLimits() {
        model.Tamb = state!.Tamb
        let maxTemp = Quantize(model.Tmax)
        if maxTemp > 500 {
            desiredTempSlider.maximumValue = 500
        } else {
            desiredTempSlider.maximumValue = Quantize(model.Tmax)
        }
        currentTempSlider.minimumValue = Tamb
        desiredTempSlider.minimumValue = Tamb + smallstep
        if desiredTempSlider.value < (Tamb + smallstep) {
            desiredTempSlider.value = Tamb + smallstep
        }
        UpdateView()
        CheckTimerEnable()
    }
    
    func Reset() {
        currentTempSlider.value = currentTempSlider.minimumValue
        desiredTempSlider.value = state!.desiredTemp
        UpdateView()
        CheckTimerEnable()
    }
    
    func CheckTimerEnable() {
        if desiredTemp == currentTemp {
            startButton.isEnabled = false
        } else {
            startButton.isEnabled = true
        }
    }
    
    // MARK: - Notification and timer functionality
    
    private var timer: Timer?
    private var timerDisabledControls: [UIControl] = []
    private var initialCurrentTemp: Float = 0
    
    // Timer delegate function
    func TimerCount() {
        let minutesLeft = modelTimer.minutesLeft()
        if minutesLeft > 0 {
            ShowTime(minutes: minutesLeft)
            let tempEst = modelTimer.tempEstimate()
            currentTempLabel.text = String(Int(round(tempEst)))
            currentTempSlider.value = tempEst
            currentTemp = round(tempEst)
        } else {
            let Tset = desiredTemp
            currentTempSlider.value = Tset
            UpdateView()
            StopTimer()
        }
    }
    
    func ResetTimer() {
        StopTimer()
        currentTempSlider.value = Float(initialCurrentTemp)
        UpdateView()
    }
    
    func StopTimer() {
        // Timer stuff
        modelTimer.stopTimer()
        timer?.invalidate()
        
        // Notification stuff
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for theControl in timerDisabledControls {
            theControl.isEnabled = true
        }
        
        // View stuff
        preheatLabel.isHidden = true
        startButton.setTitle("Start", for: UIControlState.normal)
        timerResetButton.isEnabled = false
        UpdateView()
        CheckTimerEnable()
    }
    
    // Delegate for notification action
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Got a notification action response: \(response.actionIdentifier)")
        if response.actionIdentifier == "TIMER_EARLY" {
            LearnTime(offset: 1.1)
        }
        completionHandler()
    }
    
    func StartTimer() {
        // Timer
        modelTimer.startTimer(fromTemp: currentTemp, toTemp: desiredTemp)
        timer =
            Timer.scheduledTimer(timeInterval: 0.2,
                                 target: self,
                                 selector: #selector(PreheatViewController.TimerCount),
                                 userInfo: nil,
                                 repeats: true)
        
        // UI
        initialCurrentTemp = currentTemp
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
        startButton.setTitle("Done", for: UIControlState.normal)
        timerResetButton.isEnabled = true
        
        // Notification
        let content = UNMutableNotificationContent()
        var notifyTitle: String
        if modelTimer.isHeating {
            notifyTitle = "Preheating done"
        } else {
            notifyTitle = "Cooling done"
        }
        let notifyText = "\(modelData.selectedModelData.name) should be \(Int(desiredTemp)) degrees. Swipe down to provide model learning feedback."
        content.title = NSString.localizedUserNotificationString(forKey: notifyTitle, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: notifyText, arguments: nil)
        content.sound = UNNotificationSound(named: "birge-ring.aiff")
        content.categoryIdentifier = "TIMER_FEEDBACK"
        
        let timeLeft = Double(modelTimer.minutesLeft())
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0*timeLeft, repeats: false)
        let request = UNNotificationRequest(identifier: "PREHEAT_ALARM", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        center.delegate = self
    }
    
    // Simple data collection for slow models
    // TODO: Move into ThermalModel and use judgement as to how to handle offsets
    func LearnTime(offset: Float = 1) {
        let isHeating = modelTimer.isHeating
        let elapsed = modelTimer.minutesElapsed()
        let thetime = elapsed * offset
        if thetime > 0 && isHeating {
            let measurement = HeatingDataPoint(time: thetime,
                                               Tstart: modelTimer.initialTemp,
                                               Tfinal: desiredTemp,
                                               Tamb: Tamb)
            let theModelParams = modelData.selectedModelData
            if theModelParams.measurements == nil {
                theModelParams.measurements = HeatingDataSet()
            }
            theModelParams.measurements!.addDataPoint(measurement)
            modelData.WriteToDisk()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let alertOption = UNNotificationPresentationOptions.alert
        let soundOption = UNNotificationPresentationOptions.sound
        completionHandler(alertOption.union(soundOption))
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.initialTamb = Tamb
            settingsView.modelData = modelData
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let source = segue.source as? SettingsViewController else { return }
        
        // Pull data from SettingsViewController
        model.setfrom(params: modelData.selectedModelData)
        state!.selectedModel = modelData.selectedIndex
        Tamb = source.Tamb
        UpdateLimits()
        UpdateView()
        
        // Save to disk
        WriteStateToDisk()
        modelData.WriteToDisk()
    }
    
    // MARK: - IBOutlets and IBActions
    
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
        if modelTimer.isNotRunning {
            StartTimer()
        } else {
            StopTimer()
            
            // UI learning interface
            let modelParams = modelData.selectedModelData
            let alert = UIAlertController(title: "Model learning",
                                          message: "Did \(modelParams.name) reach the desired temperature?", preferredStyle: .alert)
            let noAction = UIAlertAction(title: "Dismiss", style: .cancel)
            let yesAction = UIAlertAction(title: "Now", style: .destructive) { action in
                self.LearnTime()
                self.currentTempSlider.value = self.desiredTempSlider.value
                self.UpdateView()
            }
            let missedAction = UIAlertAction(title: "Earlier", style: .destructive) { action in
                self.LearnTime(offset: 0.9)
                self.currentTempSlider.value = self.desiredTempSlider.value
                self.UpdateView()
            }
            alert.addAction(noAction)
            alert.addAction(yesAction)
            alert.addAction(missedAction)
            
            present(alert, animated: true)
        }
    }
    
    @IBAction func TimerReset(_ sender: UIButton) {
       ResetTimer()
    }
    
    @IBAction func CurrentTempChange(_ sender: UISlider) {
        UpdateView()
    }
    
    @IBAction func DesiredTempChange(_ sender: UISlider) {
        UpdateView()
    }
    
    @IBAction func DesiredTouchUpIn() {
        desiredTempSlider.value = desiredTemp
        CheckTimerEnable()
        WriteStateToDisk()
    }
    
    @IBAction func CurrentTouchUpIn() {
        currentTempSlider.value = currentTemp
        CheckTimerEnable()
    }
    
    @IBAction func ResetButton(_ sender: UIButton) {
        Reset()
    }
}
