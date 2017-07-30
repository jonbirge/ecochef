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
    var modelFitter: ThermalModelFitter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modelParams == nil {
            modelParams = ThermalModelParams(name: "New Model")
            print("ModelEditViewController: creating new model")
        }
        modelFitter = ThermalModelFitter(params: modelParams!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    // MARK: - Table view data source
    
    func updateView() {
        nameField.text = modelParams!.name
        rcField.text = String(modelParams!.a)
        hrField.text = String(modelParams!.b)
        noteField.text = modelParams!.note
        modLabel.text = modelParams!.mod.description
        updateData()
    }
    
    func updateData() {
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
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MeasList" {
            let measView = segue.destination as! MeasTableViewController
            measView.modelParams = modelParams
        }
    }
    
    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        guard let name = nameField.text,
            let rc = Float(rcField.text!),
            let hr = Float(hrField.text!),
            let note = noteField.text
            else { return }
        
        if let modelparams = self.modelParams {
            modelparams.name = name
            modelparams.a = rc
            modelparams.b = hr
            modelparams.note = note
            modelparams.mod = Date()
        }
        
        performSegue(withIdentifier: "UnwindToModelList", sender: self)
    }

    @IBOutlet weak var dataCell: UITableViewCell!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var rcField: UITextField!
    @IBOutlet weak var hrField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var modLabel: UILabel!
}
