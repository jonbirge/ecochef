//
//  FirstViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/9/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit
import UserNotifications
import SafariServices

class PreheatViewController : UIViewController, UNUserNotificationCenterDelegate {
    let model = ThermalModel()
    let modelTimer = ThermalTimer()
    var modelData = ThermalModelData()
    let smallstep: Float = 2
    let largestep: Float = 25
    let crossover: Float = 100
    let heatingColor: UIColor = UIColor.red
    let coolingColor: UIColor = UIColor.purple
    private var desiredTemp: Float = 350
    private var currentTemp: Float = 70
    private var state: EcoChefState!
    private var timerDisabledControls: [UIControl]!
    private var timer: Timer?
    private var initialCurrentTemp: Float = 0
    
    var Tamb : Float {
        get { return model.Tamb }
        set (newTamb) {
            model.Tamb = Quantize(newTamb)
            state?.Tamb = model.Tamb
        }
    }
    
    // MARK: - Startup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get state from application object
        let app = UIApplication.shared.delegate as! AppDelegate
        state = app.state
        // state!.notOnBoarded = true // TESTING
        print("state Tamb: \(state!.Tamb)")
        print("state desT: \(state!.desiredTemp)")
        print("state notOnBoarded: \(state!.notOnBoarded)")
        
        timerDisabledControls =
            [currentTempSlider, desiredTempSlider, tempResetButton, settingsButton]
        modelTimer.thermalModel = model
        modelData.LoadModelData()
        UpdateFromState()
        UpdateLimits()
        Reset()
        
        // Onboarding
        if state.notOnBoarded {
            onBoarding()
            state.notOnBoarded = false
            state.writeStateToDisk()
        }
        
        // Notification setup
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didBecomeActive), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)

        // UI notification setup
        let usernotificationCenter = UNUserNotificationCenter.current()
        usernotificationCenter.delegate = self
        let earlyAction = UNNotificationAction(identifier: "TIMER_SNOOZE", title: "Continue timer",
                                                options: .destructive)
        let rightAction = UNNotificationAction(identifier: "TIMER_GOOD", title: "Preheated",
                                              options: UNNotificationActionOptions(rawValue: 0))
        let timerFeedbackCategory =
            UNNotificationCategory(identifier: "TIMER_FEEDBACK",
                                   actions: [earlyAction, rightAction],
                                   intentIdentifiers: [],
                                   options: UNNotificationCategoryOptions(rawValue: 0))
        let timerDoneCategory =
            UNNotificationCategory(identifier: "TIMER_SIMPLE",
                                   actions: [],
                                   intentIdentifiers: [],
                                   options: UNNotificationCategoryOptions(rawValue: 0))
        usernotificationCenter.setNotificationCategories([timerFeedbackCategory, timerDoneCategory])
    }
    
    private func onBoarding() {
        let alert = UIAlertController(title: "Welcome to EcoChef!",
                                      message: "Would you like to read the FAQ?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel) {
            action in
            UIView.transition(with: self.helpLabel, duration: 1.2,
                              options: .transitionFlipFromLeft,
                              animations: {
                                self.helpLabel.isHidden = false },
                              completion: nil)
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            if let faqURL = URL(string: EcoChefState.faqURL) {
                let safariViewController = SFSafariViewController(url:faqURL)
                self.present(safariViewController, animated: true, completion: nil)
            }
            self.helpLabel.isHidden = false
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
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
        } else {
            StopTimer()
            UpdateView()
        }
    }
    
    // MARK: - State
    
    private func UpdateFromState() {
        desiredTempSlider.value = state!.desiredTemp
        modelData.selectedIndex = state!.selectedModel
        model.setfrom(params: modelData.selectedModelData)
        UpdateView()
    }
    
    func WriteStateToDisk() {
        state!.desiredTemp = desiredTemp
        state!.writeStateToDisk()
    }
    
    // MARK: - UI & model

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
        desiredTemp = Quantize(desiredTempSlider.value)
        
        // Labels
        currentTempLabel.text = String(Int(currentTemp))
        desiredTempLabel.text = String(Int(desiredTemp))
        preheatLabel.textColor = .darkGray
        preheatLabel.text = modelData.selectedModelData.name
        
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
    
    // Delegate for notification action
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "TIMER_SNOOZE" {
            SnoozeTimer()
        } else if response.actionIdentifier == "TIMER_GOOD" {  // user agrees we're done
            if modelTimer.snoozing {
                LearnTime()
            }
            EnableTimerControls()
        }
        completionHandler()
    }
    
    // Timer delegate function
    func TimerCount() {
        let minutesLeft = modelTimer.minutesLeft()
        if modelTimer.isNotDone {
            ShowTime(minutes: abs(minutesLeft))
            if !modelTimer.snoozing {
                let tempEst = modelTimer.tempEstimate()
                currentTempLabel.text = String(Int(round(tempEst)))
                currentTempSlider.value = tempEst
                currentTemp = round(tempEst)
            }
        } else {
            let Tset = desiredTemp
            currentTempSlider.value = Tset
            UpdateView()
            StopTimer()
        }
    }
    
    private func AddNotification() {
        let modelParams = modelData.selectedModelData
        let content = UNMutableNotificationContent()
        var notifyTitle: String
        if modelTimer.isHeating {
            notifyTitle = "Preheating done"
        } else {
            notifyTitle = "Cooling done"
        }

        if modelParams.calibrated && modelTimer.isHeating {
            content.categoryIdentifier = "TIMER_FEEDBACK"
            let notifyText = "\(modelData.selectedModelData.name) should be \(Int(desiredTemp))º. Pull down to provide model learning data."
            content.body = NSString.localizedUserNotificationString(forKey: notifyText, arguments: nil)
        } else {
            content.categoryIdentifier = "TIMER_SIMPLE"
            let notifyText = "\(modelData.selectedModelData.name) should be \(Int(desiredTemp))º"
            content.body = NSString.localizedUserNotificationString(forKey: notifyText, arguments: nil)
        }
        content.title = NSString.localizedUserNotificationString(forKey: notifyTitle, arguments: nil)
        content.sound = UNNotificationSound(named: "birge-ring.aiff")
        
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
    
    private func CancelNotification() {
        // Notification stuff
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    private func EnableTimerControls() {
        for theControl in timerDisabledControls {
            theControl.isEnabled = true
        }
        startButton.setTitle("Start", for: UIControlState.normal)
        timerResetButton.isEnabled = false
        UpdateView()
        CheckTimerEnable()
    }
    
    private func DisableTimerControls () {
        for theControl in timerDisabledControls {
            theControl.isEnabled = false
        }
        startButton.setTitle("Done", for: UIControlState.normal)
        startButton.isEnabled = true
        timerResetButton.isEnabled = true
    }
    
    func ResetTimer() {
        CancelNotification()
        StopTimer()
        currentTempSlider.value = Float(initialCurrentTemp)
        UpdateView()
    }

    func StopTimer() {
        modelTimer.stopTimer()
        timer?.invalidate()
        EnableTimerControls()
    }
    
    func SnoozeTimer() {
        // Start new timer
        modelTimer.snoozeTimer(for: 2.5)
        timer =
            Timer.scheduledTimer(timeInterval: 0.2,
                                 target: self,
                                 selector: #selector(PreheatViewController.TimerCount),
                                 userInfo: nil,
                                 repeats: true)
        
        // UI
        DisableTimerControls()
        let modelname = modelData.selectedModelData.name
        if modelTimer.isHeating {
            preheatLabel.text = "Timing \(modelname)"
            preheatLabel.textColor = heatingColor
        } else {
            preheatLabel.text = "Timing \(modelname)"
            preheatLabel.textColor = coolingColor
        }
        
        // Throw up another notification
        AddNotification()
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
        let modelname = modelData.selectedModelData.name
        if modelTimer.isHeating {
            preheatLabel.text = "Preheating \(modelname)"
            preheatLabel.textColor = heatingColor
        } else {
            preheatLabel.text = "Cooling \(modelname)"
            preheatLabel.textColor = coolingColor
        }
        DisableTimerControls()
        AddNotification()
    }
    
    // Data collection for models
    func LearnTime() {
        let isHeating = modelTimer.isHeating
        let thetime = modelTimer.minutesElapsed()
        if thetime > 0 && isHeating {
            modelData.selectedModelData.addDataPoint(time: thetime,
                                                     Tstart: modelTimer.initialTemp,
                                                     Tfinal: desiredTemp,
                                                     Tamb: Tamb)
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
            helpLabel.isHidden = true
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
    
    @IBOutlet weak var helpLabel: UILabel!
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
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBAction func StartButton(_ sender: UIButton) {
        if modelTimer.isNotRunning {
            StartTimer()
        } else {  // done
            CancelNotification()
            StopTimer()
            
            // UI learning interface
            let modelParams = modelData.selectedModelData
            if modelParams.calibrated && modelTimer.isHeating {
                let alert = UIAlertController(title: "Model learning",
                                              message: "Did \(modelParams.name) reach the desired temperature?", preferredStyle: .alert)
                
                let noAction = UIAlertAction(title: "Dismiss", style: .cancel)
                let yesAction = UIAlertAction(title: "Yes", style: .destructive) { action in
                    self.LearnTime()
                    self.currentTempSlider.value = self.desiredTempSlider.value
                    self.UpdateView()
                }
                alert.addAction(yesAction)
                alert.addAction(noAction)
                
                present(alert, animated: true)
            }
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
