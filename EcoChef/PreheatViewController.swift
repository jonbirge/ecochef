//
//  FirstViewController.swift
//  EcoChef
//
//  Copyright © 2017-2022 Birge & Fuller. All rights reserved.
//

import UIKit
import UserNotifications
import SafariServices

class PreheatViewController : UIViewController, UNUserNotificationCenterDelegate {
    
    private let model = ThermalModel()
    private let modelTimer = ThermalTimer()
    private let smallstep: Float = 2
    private let largestep: Float = 25
    private let crossover: Float = 100
    private let smallstepC: Float = 1
    private let largestepC: Float = 10
    private let crossoverC: Float = 50
    private let heatingColor: UIColor = UIColor.red
    private let coolingColor: UIColor = UIColor.purple
    
    private var desiredTemp: Float = 350
    private var currentTemp: Float = 70
    private var modelData = ThermalModelData()
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
    
    // TODO: Should some of this be in AppDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get state from application object
        let app = UIApplication.shared.delegate as! AppDelegate
        state = app.state
        // state!.notOnBoarded = true // FOR TESTING
        print("Tamb: \(state!.Tamb)")
        print("desT: \(state!.desiredTemp)")
        print("useCelcius: \(state!.useCelcius)")
        print("notOnBoarded: \(state!.notOnBoarded)")
        
        timerDisabledControls = [modelButton,
                                 currentTempSlider, desiredTempSlider,
                                 tempResetButton, settingsButton]
        modelTimer.thermalModel = model
        modelData.LoadModelData()
        UpdateFromState()
        UpdateSliders()
        Reset()
        
        // Notification setup
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self, selector: #selector(PreheatViewController.didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(
            self, selector: #selector(PreheatViewController.didBecomeActive),
            name: UIApplication.willEnterForegroundNotification, object: nil)

        // UI notification setup
        // TODO: Put this elsewhere, maybe only when actually needed?
        let usernotificationCenter = UNUserNotificationCenter.current()
        usernotificationCenter.delegate = self
        let earlyAction = UNNotificationAction(
            identifier: "TIMER_SNOOZE", title: "Continue timer",
            options: .destructive)
        let rightAction = UNNotificationAction(
            identifier: "TIMER_GOOD", title: "Preheated",
            options: UNNotificationActionOptions(rawValue: 0))
        let timerFeedbackCategory = UNNotificationCategory(
            identifier: "TIMER_FEEDBACK",
            actions: [earlyAction, rightAction],
            intentIdentifiers: [],
            options: UNNotificationCategoryOptions(rawValue: 0))
        let timerDoneCategory = UNNotificationCategory(
            identifier: "TIMER_SIMPLE",
            actions: [],
            intentIdentifiers: [],
            options: UNNotificationCategoryOptions(rawValue: 0))
        usernotificationCenter.setNotificationCategories([timerFeedbackCategory, timerDoneCategory])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Onboarding
        if state.notOnBoarded {
            onBoarding()
            state.notOnBoarded = false
            state.writeStateToDisk()
        }
    }
    
    private func onBoarding() {
        UIView.transition(
            with: self.helpLabel, duration: 1.5,
            options: .transitionFlipFromBottom,
            animations: {
                self.helpLabel.isHidden = false },
            completion: nil)
    }
    
    @objc func didEnterBackground() {
        if modelTimer.isRunning {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func didBecomeActive() {
        if modelTimer.isRunning {
            timer = Timer.scheduledTimer(
                timeInterval: 0.2,
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
        if state.useCelcius {
            desiredTempSlider.value = ThermalModel.FtoC(temp: state.desiredTemp)
        } else {
            desiredTempSlider.value = state.desiredTemp
        }
        modelData.selectedIndex = state.selectedModel
        model.setfrom(params: modelData.selectedModelData)
        UpdateView()
    }
    
    private func WriteStateToDisk() {
        state.desiredTemp = desiredTemp
        state.writeStateToDisk()
    }
    
    // MARK: - UI & timer model

    private func Quantize(_ temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    private func QuantizeC(_ temp:Float) -> Float {
        if temp < crossoverC {
            return smallstepC*round(temp/smallstepC)
        } else {
            return largestepC*round(temp/largestepC)
        }
    }
    
    /// Pull in data from sliders
    private func ReadSliders() {
        if state.useCelcius {
            currentTemp = ThermalModel.CtoF(temp: (currentTempSlider.value))  // TODO: round?
            desiredTemp = ThermalModel.CtoF(temp: QuantizeC(desiredTempSlider.value))
        } else {
            currentTemp = currentTempSlider.value  // TODO: round?
            desiredTemp = Quantize(desiredTempSlider.value)
        }
    }

    // TODO: Make utility function that converts F temp into appropriate display based on `state`
    /// Update view while time is not engaged
    private func UpdateView() {
        if state.useCelcius {
            currentTemp = ThermalModel.CtoF(temp: (currentTempSlider.value))  // TODO: round?
            desiredTemp = ThermalModel.CtoF(temp: QuantizeC(desiredTempSlider.value))
            currentTempLabel.text = ThermalModel.DisplayC(temp: currentTemp)
            desiredTempLabel.text = ThermalModel.DisplayC(temp: desiredTemp)
        } else {
            currentTemp = currentTempSlider.value  // TODO: round?
            desiredTemp = Quantize(desiredTempSlider.value)
            currentTempLabel.text = ThermalModel.DisplayF(temp: currentTemp)
            desiredTempLabel.text = ThermalModel.DisplayF(temp: desiredTemp)
        }
        
        modelButton.setTitle(modelData.selectedModelData.name, for: .normal)
        
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
        ShowTime(minutes: minfrac)  // faster?
    }
    
    private func UpdateSliders() {
        var desiredMax, desiredMin: Float  // F
        var currentMax, currentMin: Float  // F
        
        print("PreviewViewController:UpdateSliders")
        
        desiredMin = 70
        model.Tamb = state.Tamb
        
        let maxTemp = Quantize(model.Tmax)  // F
        if maxTemp > 500 {
            desiredMax = 500
        } else {
            desiredMax = Quantize(model.Tmax)
        }
        
        currentMax = desiredMax
        currentMin = Tamb
        
        if state.useCelcius {
            currentTempSlider.maximumValue = round(ThermalModel.FtoC(temp: currentMax))
            currentTempSlider.minimumValue = round(ThermalModel.FtoC(temp: currentMin))
            desiredTempSlider.maximumValue = round(ThermalModel.FtoC(temp: desiredMax))
            desiredTempSlider.minimumValue = round(ThermalModel.FtoC(temp: desiredMin))
            currentTempSlider.value = ThermalModel.FtoC(temp: currentTemp)
            desiredTempSlider.value = QuantizeC(ThermalModel.FtoC(temp: desiredTemp))
        } else {
            currentTempSlider.maximumValue = currentMax
            currentTempSlider.minimumValue = currentMin
            desiredTempSlider.maximumValue = desiredMax
            desiredTempSlider.minimumValue = desiredMin
            currentTempSlider.value = currentTemp
            desiredTempSlider.value = Quantize(desiredTemp)
        }
        
        UpdateView()
        CheckTimerEnable()
    }
    
    private func ShowTime(minutes: Float?) {
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
    
    private func Reset() {
        currentTempSlider.value = currentTempSlider.minimumValue
        if state.useCelcius {
            desiredTempSlider.value = ThermalModel.FtoC(temp: state.desiredTemp)
        } else {
            desiredTempSlider.value = state.desiredTemp
        }
        UpdateView()
        CheckTimerEnable()
    }
    
    // TODO: Should instead check if modeled time would round to zero
    private func CheckTimerEnable() {
        if desiredTemp == currentTemp {
            startButton.isEnabled = false
        } else {
            startButton.isEnabled = true
        }
    }

    private func EnableTimerControls() {
        for theControl in timerDisabledControls {
            theControl.isEnabled = true
        }
        startButton.setTitle("Start", for: .normal)
        timerResetButton.isEnabled = false
        UpdateView()
        CheckTimerEnable()
    }

    private func DisableTimerControls() {
        for theControl in timerDisabledControls {
            theControl.isEnabled = false
        }
        startButton.setTitle("Done", for: .normal)
        startButton.isEnabled = true
        timerResetButton.isEnabled = true
    }

    private func ResetTimer() {
        CancelNotification()
        StopTimer()
        if state.useCelcius {
            currentTempSlider.value = ThermalModel.FtoC(temp: Float(initialCurrentTemp))
        } else {
            currentTempSlider.value = Float(initialCurrentTemp)
        }
        // currentTemp = initialCurrentTemp
        UpdateView()
    }

    private func StopTimer() {
        modelTimer.stopTimer()
        timer?.invalidate()
        EnableTimerControls()
    }

    private func SnoozeTimer() {
        // Start new timer
        modelTimer.snoozeTimer(for: 2.0)
        timer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(PreheatViewController.TimerCount),
            userInfo: nil,
            repeats: true)

        // UI
        let modelname = modelData.selectedModelData.name
        if modelTimer.isHeating {
            modelButton.setTitleColor(heatingColor, for: .disabled)
            modelButton.setTitle("Timing \(modelname)", for: .disabled)
        } else {
            modelButton.setTitleColor(coolingColor, for: .disabled)
            modelButton.setTitle("Timing \(modelname)", for: .disabled)
        }
        DisableTimerControls()
        AddNotification()
    }

    private func StartTimer() {
        // Timer
        modelTimer.startTimer(fromTemp: currentTemp, toTemp: desiredTemp)
        timer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(PreheatViewController.TimerCount),
            userInfo: nil,
            repeats: true)

        // UI
        initialCurrentTemp = currentTemp
        let modelname = modelData.selectedModelData.name
        if modelTimer.isHeating {
            modelButton.setTitle("Preheating \(modelname)", for: .disabled)
            modelButton.setTitleColor(heatingColor, for: .disabled)
        } else {
            modelButton.setTitle("Cooling \(modelname)", for: .disabled)
            modelButton.setTitleColor(coolingColor, for: .disabled)
        }
        DisableTimerControls()
        AddNotification()
    }

    /// Collect data from user
    private func LearnTime() {
        let isHeating = modelTimer.isHeating
        let theTime = modelTimer.minutesElapsed()
        let theModel = modelData.selectedModelData
        if theTime > 0 && isHeating
        {
            theModel.addDataPoint(time: theTime,
                                  Tstart: modelTimer.initialTemp,
                                  Tfinal: desiredTemp,
                                  Tamb: Tamb)
            if theModel.calibrated {  // TODO: always true?
                theModel.fitfromdata()
            }
            modelData.WriteToDisk()
        }
    }

    /// Ask user if we should collect data manually stopped timer
    private func QueryLearning() {
        let modelParams = modelData.selectedModelData
        if modelParams.calibrated && modelTimer.isHeating {
            let alert = UIAlertController(title: "Model Learning",
                                          message: "Should the \(modelParams.name) model learn from this preheat time?",
                                          preferredStyle: .alert)

            let noAction = UIAlertAction(title: "Ignore", style: .cancel)
            let yesAction = UIAlertAction(title: "Learn", style: .destructive) { action in
                self.LearnTime()
                self.currentTempSlider.value = self.desiredTempSlider.value
                self.UpdateView()
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)

            present(alert, animated: true)
        }
    }

    // MARK: - Notification
    
    /// Delegate for notification action
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        if response.actionIdentifier == "TIMER_SNOOZE" {
            SnoozeTimer()
        } else if response.actionIdentifier == "TIMER_GOOD" {  // user agrees we're done
            if modelTimer.isSnoozing {
                LearnTime()
            }
            EnableTimerControls()
        }
        completionHandler()
    }
    
    /// Timer delegate function
    @objc func TimerCount() {
        let minutesLeft = modelTimer.minutesLeft()
        if modelTimer.isNotDone {
            ShowTime(minutes: abs(minutesLeft))
            if !modelTimer.isSnoozing {
                let tempEst = modelTimer.tempEstimate()  // F
                if state.useCelcius {
                    currentTempLabel.text = ThermalModel.DisplayC(temp: tempEst)
                    currentTempSlider.value = ThermalModel.FtoC(temp: tempEst)
                } else {
                    currentTempLabel.text = ThermalModel.DisplayF(temp: tempEst)
                    currentTempSlider.value = tempEst
                }
                currentTemp = round(tempEst)
            }
        } else {
            let Tset = desiredTemp
            if state.useCelcius {
                currentTempSlider.value = ThermalModel.FtoC(temp: Tset)
            } else {
                currentTempSlider.value = Tset
            }
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
            let notifyText = "\(modelData.selectedModelData.name) should be \(Int(desiredTemp))º. Hold down to provide model learning data."
            content.body = NSString.localizedUserNotificationString(forKey: notifyText, arguments: nil)
        } else {
            content.categoryIdentifier = "TIMER_SIMPLE"
            let notifyText = "\(modelData.selectedModelData.name) should be \(Int(desiredTemp))º"
            content.body = NSString.localizedUserNotificationString(forKey: notifyText, arguments: nil)
        }
        content.title = NSString.localizedUserNotificationString(forKey: notifyTitle, arguments: nil)
        content.sound = UNNotificationSound(
            named: UNNotificationSoundName(rawValue: "birge-ring.aiff"))
        
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
    
    // Delegate
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
            settingsView.useCelcius = state.useCelcius
            settingsView.modelData = modelData
            helpLabel.isHidden = true
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let source = segue.source as? SettingsViewController else { return }
        
        print("Unwinding from SettingsViewController...")
        
        // Pull data from SettingsViewController
        model.setfrom(params: modelData.selectedModelData)
        state.selectedModel = modelData.selectedIndex
        state.useCelcius = source.useCelcius
        Tamb = source.Tamb
        UpdateSliders()
        UpdateView()
        
        // Save to disk
        WriteStateToDisk()
        modelData.WriteToDisk()
    }
    
    // MARK: - IBOutlets and IBActions
    
    @IBOutlet var helpLabel: UILabel!
    @IBOutlet var minLabel: UILabel!
    @IBOutlet var secLabel: UILabel!
    @IBOutlet var currentTempLabel: UILabel!
    @IBOutlet var desiredTempLabel: UILabel!
    @IBOutlet var currentTempSlider: UISlider!
    @IBOutlet var desiredTempSlider: UISlider!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var timerResetButton: UIButton!
    @IBOutlet var curTempLabel: UILabel!
    @IBOutlet var tempResetButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var modelButton: UIButton!
    
    @IBAction func StartButton(_ sender: UIButton) {
        if modelTimer.isNotRunning {  // start
            StartTimer()
        } else {  // done
            CancelNotification()
            StopTimer()
            QueryLearning()
        }
    }
    
    @IBAction func TimerReset(_ sender: UIButton) {
       ResetTimer()
    }
    
    @IBAction func SliderTempChange(_ sender: UISlider) {
        ReadSliders()
        UpdateView()
    }
    
    @IBAction func DesiredTouchUpIn() {
        if state.useCelcius {
            desiredTempSlider.value = ThermalModel.FtoC(temp: desiredTemp)
        } else {
            desiredTempSlider.value = desiredTemp
        }
        CheckTimerEnable()
        WriteStateToDisk()
    }
    
    @IBAction func CurrentTouchUpIn() {
        if state.useCelcius {
            currentTempSlider.value = ThermalModel.FtoC(temp: currentTemp)
        } else {
            currentTempSlider.value = currentTemp
        }
        CheckTimerEnable()
    }
    
    @IBAction func ResetButton(_ sender: UIButton) {
        Reset()
    }
}
