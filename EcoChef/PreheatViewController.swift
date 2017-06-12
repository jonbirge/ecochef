//
//  FirstViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/9/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class PreheatViewController : UIViewController {
    var desiredTemp: Int = 0
    var currentTemp: Int = 0
    var model: ThermalModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = ThermalModel()
        Reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func quantize(temp:Float) -> Int {
        if temp < 100 {
            return Int(2*round(temp/2))
        } else {
            return Int(25*round(temp/25))
        }
    }
    
    func SetCurrent(temp:Float) {
        currentTemp = quantize(temp: temp)
        currentTempLabel.text = String(currentTemp)
        
        let maxtemp = currentTempSlider.maximumValue
        let mintemp = currentTempSlider.minimumValue
        let tempfrac = CGFloat((temp - mintemp)/(maxtemp - mintemp))
        let tempcolor = UIColor(red: tempfrac, green: 0, blue: 1 - tempfrac, alpha: 1)
        currentTempLabel.textColor = tempcolor
        currentTempSlider.minimumTrackTintColor = tempcolor
    }
    
    func SetDesired(temp:Float) {
        var rawtemp = temp
        let curtemp = currentTempSlider.value
        if rawtemp < curtemp {
            rawtemp = curtemp
        }
        desiredTemp = quantize(temp: rawtemp)
        desiredTempLabel.text = String(desiredTemp)
        
        let maxtemp = desiredTempSlider.maximumValue
        let mintemp = desiredTempSlider.minimumValue
        let tempfrac = CGFloat((temp - mintemp)/(maxtemp - mintemp))
        let tempcolor = UIColor(red: tempfrac, green: 0, blue: 1 - tempfrac, alpha: 1)
        desiredTempLabel.textColor = tempcolor
        desiredTempSlider.minimumTrackTintColor = tempcolor
        
        let pretimefrac = model.timefor(temp: desiredTemp, fromtemp: currentTemp)
        DisplayTime(minfrac: pretimefrac)
    }
    
    func DisplayTime(minfrac:Float) {
        let pretimemin = floor(minfrac)
        let pretimesec = round(60*(minfrac - pretimemin))
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
        UpdateDesired()
    }
    
    func UpdateDesired() {
        SetDesired(temp: desiredTempSlider.value)
    }
    
    func Reset() {
        currentTempSlider.value = 72.0
        desiredTempSlider.value = 350.0
        UpdateCurrent()
        UpdateDesired()
    }
   
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var desiredTempLabel: UILabel!
    @IBOutlet weak var currentTempSlider: UISlider!
    @IBOutlet weak var desiredTempSlider: UISlider!
    
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

