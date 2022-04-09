//
//  ModelEditViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/3/17.
//  Copyright © 2017-2022 Birge & Fuller. All rights reserved.
//

import UIKit

class ModelEditViewController: UITableViewController, ThermalParamListener {
    var modelParams: ThermalModelParams?
    
    func thermalParamsChanged(for params: ThermalModelParams) {
        print("ModelEditViewCont: Notified of parameter change")
        updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modelParams == nil {
            modelParams = ThermalModelParams(name: "New Model")
        }
        nameField.text = modelParams!.name
        noteField.text = modelParams!.note
        rcField.text = String(modelParams!.a)
        hrField.text = String(modelParams!.b)
        fitSwitch.isOn = modelParams!.calibrated
        
        modelParams?.registerListener(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    // MARK: - Table view data source
    
    func updateView() {
        guard modelParams != nil else { return }
        print("ModelEditViewCont:updateView")
        let isLearning = fitSwitch.isOn
        if isLearning {
            rcField.text = String(modelParams!.a)
            hrField.text = String(modelParams!.b)
            rcField.isEnabled = false
            hrField.isEnabled = false
            rcField.textColor = .systemGray
            hrField.textColor = .systemGray
        } else {
            rcField.isEnabled = true
            hrField.isEnabled = true
            rcField.textColor = .label
            hrField.textColor = .label
        }
        let measData = modelParams!.measurements
        if measData.count == 0 {
            dataLabel.text = "No data"
        } else {
            if measData.count > 1 {
                dataLabel.text = "\(measData.count) data points"
            } else {
                dataLabel.text = "1 data point"
            }
        }
        dataLabel.isEnabled = isLearning
        dataCell.isUserInteractionEnabled = isLearning
        calibrateButton.isEnabled = isLearning
    }

    // MARK: - Navigation
    
    // Preparation before navigation to measured data point list
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let measView = segue.destination as? MeasTableViewController {
            measView.modelParams = modelParams
        } else if let calView = segue.destination as? CalibrationViewController {
            calView.modelParams = modelParams
        }
    }
    
    // Unwind from measured data point list editing scene
    @IBAction func prepareForUnwind(for segue: UIStoryboardSegue) {
        print("ModelEditViewCont:prepForUnwind")
    }
    

    // MARK: - IB
    
    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        guard let name = nameField.text,
            let rc = Float(rcField.text!),
            let hr = Float(hrField.text!),
            let note = noteField.text else
        {
            // TODO: Actually handle this and tell user!
            performSegue(withIdentifier: "UnwindToModelList", sender: self)
            print("ModelEditCont: can't save poorly formed data.")
            return
        }
        
        if let modelparams = self.modelParams {
            modelparams.name = name
            modelparams.a = rc
            modelparams.b = hr
            modelparams.note = note
            modelparams.mod = Date()
            modelparams.calibrated = fitSwitch.isOn
        }
        
        performSegue(withIdentifier: "UnwindToModelList", sender: self)
    }
    
    @IBAction func clickFitSwitch() {
        if fitSwitch.isOn {
            modelParams?.fitfromdata()
        }
        updateView()
    }

    @IBOutlet var calibrateButton: UIButton!
    @IBOutlet var dataCell: UITableViewCell!
    @IBOutlet var fitSwitch: UISwitch!
    @IBOutlet var dataLabel: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var rcField: UITextField!
    @IBOutlet var hrField: UITextField!
    @IBOutlet var noteField: UITextField!
}
