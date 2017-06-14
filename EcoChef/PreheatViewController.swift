//
//  FirstViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/9/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class PreheatViewController : UIViewController {
    let smallstep: Float = 2
    let largestep: Float = 25
    let crossover: Float = 100
    let tempdefault: Float = 350
    var desiredTemp: Float = 0
    var currentTemp: Float = 0
    var model: ThermalModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = ThermalModel()
        UpdateAmbient()
        Reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func quantize(temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    func colorfrom(frac:Float) -> UIColor {
        let fracfloat:CGFloat = CGFloat(frac)
        return UIColor(red: 0.5 - cos(3.1457*fracfloat)/2, green: 0, blue: 0.5 + cos(3.1457*fracfloat)/2, alpha: 1)
    }
    
    func SetCurrent(temp:Float) {
        currentTemp = quantize(temp: temp)
        currentTempLabel.text = String(Int(currentTemp))
        
        let maxtemp = currentTempSlider.maximumValue
        let mintemp = currentTempSlider.minimumValue
        let tempfrac = (temp - mintemp)/(maxtemp - mintemp)
        currentTempSlider.minimumTrackTintColor = colorfrom(frac:tempfrac)
    }
    
    func SetDesired(temp:Float) {
        desiredTemp = quantize(temp: temp)
        desiredTempLabel.text = String(Int(desiredTemp))
        
        let maxtemp = desiredTempSlider.maximumValue
        let mintemp = desiredTempSlider.minimumValue
        let tempfrac = (temp - mintemp)/(maxtemp - mintemp)
        desiredTempSlider.minimumTrackTintColor = colorfrom(frac:tempfrac)
        
        let pretimefrac = model.time(totemp: desiredTemp, fromtemp: currentTemp)
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
    
    func UpdateAmbient() {
        let T0 = quantize(temp: model.T0)
        currentTempSlider.minimumValue = T0
        desiredTempSlider.minimumValue = T0 + smallstep
        if currentTempSlider.value < T0 {
            currentTempSlider.value = T0
        }
        if desiredTempSlider.value < T0 {
            desiredTempSlider.value = T0 + smallstep
        }
    }
    
    func Reset() {
        currentTempSlider.value = currentTempSlider.minimumValue
        desiredTempSlider.value = tempdefault
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

