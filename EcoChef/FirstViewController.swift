//
//  FirstViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/9/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
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

    func SetCurrent(temp:Float) {
        currentTemp = Int(round(temp))
        currentTempLabel.text = String(currentTemp)
    }
    
    func SetCurrentFinal(temp:Float) {
        SetCurrent(temp: temp)
        UpdateDesired()
    }
    
    func SetDesired(temp:Float) {
        var rawtemp = temp
        let curtemp = currentTempSlider.value
        if rawtemp < curtemp {
            rawtemp = curtemp
        }
        desiredTemp = Int(25*ceil(rawtemp/25))
        desiredTempLabel.text = String(desiredTemp)
        
        let pretime = model.timefor(temp: desiredTemp, fromtemp: currentTemp)
        timeLabel.text = String(pretime)
    }
    
    func UpdateCurrent() {
        SetCurrent(temp: currentTempSlider.value)
    }
    
    func UpdateDesired() {
        SetDesired(temp: desiredTempSlider.value)
    }
    
    func Reset() {
        currentTempSlider.value = 70.0
        desiredTempSlider.value = 350.0
        UpdateCurrent()
        UpdateDesired()
    }
   
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var desiredTempLabel: UILabel!
    @IBOutlet weak var currentTempSlider: UISlider!
    @IBOutlet weak var desiredTempSlider: UISlider!
    
    @IBAction func CurrentTempChange(_ sender: UISlider) {
        UpdateCurrent()
    }
    
    @IBAction func CurrentTempDone(_ sender: UISlider) {
        SetCurrentFinal(temp: sender.value)
    }
    
    @IBAction func DesiredTempChange(_ sender: UISlider) {
        UpdateDesired()
    }

    @IBAction func ResetButton(_ sender: UIButton) {
        Reset()
    }
}

