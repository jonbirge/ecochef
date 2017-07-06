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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelTimer.thermalModel = model
        modelData.LoadModelData()
        LoadState()
        UpdateFromState()
        UpdateAmbient()
        Reset()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PreheatViewController.didBecomeActive), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func didEnterBackground() {
        print("PreheatView entered background")
        if timerRunning {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func didBecomeActive() {
        print("PreheatView entering foreground")
        if timerRunning {
            timer =
                Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(PreheatViewController.TimerCount),
                                     userInfo: nil,
                                     repeats: true)
        }
    }
    
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
        UpdateDesired()
    }
    
    func WriteStateToDisk() {
        state!.desiredTemp = desiredTemp
        NSKeyedArchiver.archiveRootObject(state!, toFile: stateURL.path)
    }

    private func Quantize(_ temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    func SetCurrent(temp:Float) {
        currentTemp = temp
        currentTempLabel.text = String(Int(currentTemp))
        UpdateView()
    }
    
    func SetDesired(temp:Float) {
        desiredTemp = temp
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
        SetDesired(temp: Quantize(desiredTempSlider.value))
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
        desiredTempSlider.value = state!.desiredTemp
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
    
    // MARK: Notification and timer functionality
    private var timer: Timer?
    private var timerDisabledControls: [UIControl] = []
    private var timerRunning: Bool = false
    private var initialCurrentTemp: Float = 0
    
    // Timer delegate function
    var timerCount: Int = 0
    func TimerCount() {
        timerCount += 1
        if timerCount % 10 == 0 {
            print("timer count: \(timerCount)")
        }
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
            UpdateCurrent()
            StopTimer()
        }
    }
    
    func ResetTimer() {
        StopTimer()
        currentTempSlider.value = Float(initialCurrentTemp)
        UpdateCurrent()
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
            Timer.scheduledTimer(timeInterval: 0.2,
                                 target: self,
                                 selector: #selector(PreheatViewController.TimerCount),
                                 userInfo: nil,
                                 repeats: true)
        
        // UI
        timerRunning = true
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
        let notifyText = "\(modelData.selectedModelData.name) should be \(Int(desiredTemp)) degrees."
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.initialTamb = Tamb
            settingsView.modelData = modelData
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let source = segue.source as? SettingsViewController else { return }
        
        // Pull data from SettingsViewController
        Tamb = source.Tamb
        UpdateAmbient()
        model.setfrom(params: modelData.selectedModelData)
        state!.selectedModel = modelData.selectedIndex
        UpdateView()
        
        // Save to disk
        WriteStateToDisk()
        modelData.WriteToDisk()
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
        SetCurrent(temp: Quantize(sender.value))
    }
    
    @IBAction func DesiredTempChange(_ sender: UISlider) {
        SetDesired(temp: Quantize(sender.value))
    }
    
    @IBAction func DesiredTouchUpIn() {
        CheckTimerEnable()
        WriteStateToDisk()
    }
    
    @IBAction func CurrentTouchUpIn() {
        CheckTimerEnable()
    }
    
    @IBAction func ResetButton(_ sender: UIButton) {
        Reset()
    }
}
