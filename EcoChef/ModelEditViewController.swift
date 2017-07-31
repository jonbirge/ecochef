//
//  ModelEditViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/3/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class ModelEditViewController: UITableViewController {
    var modelParams: ThermalModelParams?
    //var modelFitter: ThermalModelFitter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modelParams == nil {
            modelParams = ThermalModelParams(name: "New Model")
        }
        //modelFitter = ThermalModelFitter(params: modelParams!)
        nameField.text = modelParams!.name
        noteField.text = modelParams!.note
        rcField.text = String(modelParams!.a)
        hrField.text = String(modelParams!.b)
        fitSwitch.isOn = modelParams!.calibrated
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    // MARK: - Table view data source
    
    func updateView() {
        if fitSwitch.isOn {
            rcField.text = String(modelParams!.a)
            hrField.text = String(modelParams!.b)
            rcField.isEnabled = false
            hrField.isEnabled = false
            rcField.textColor = .lightGray
            hrField.textColor = .lightGray
        } else {
            rcField.isEnabled = true
            hrField.isEnabled = true
            rcField.textColor = .black
            hrField.textColor = .black
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
        dataLabel.isEnabled = fitSwitch.isOn
        dataCell.isUserInteractionEnabled = fitSwitch.isOn
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let measView = segue.destination as? MeasTableViewController {
            measView.modelParams = modelParams
        }
    }
    
    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        guard let name = nameField.text,
            let rc = Float(rcField.text!),
            let hr = Float(hrField.text!),
            let note = noteField.text else
        {
            // TODO: Actually handle this!
            performSegue(withIdentifier: "UnwindToModelList", sender: self)
            print("ModelEditController: can't save poorly formed data.")
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
            modelParams!.fitfromdata()
        }
        updateView()
    }

    @IBOutlet weak var dataCell: UITableViewCell!
    @IBOutlet weak var fitSwitch: UISwitch!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var rcField: UITextField!
    @IBOutlet weak var hrField: UITextField!
    @IBOutlet weak var noteField: UITextField!
}
