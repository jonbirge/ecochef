//
//  ModelEditViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/3/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class ModelEditViewController: UITableViewController {
    var modelparams: ThermalModelParams?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modelparams == nil {
            self.modelparams = ThermalModelParams(name: "New Model")
            print("ModelEditViewController: creating new model")
        }
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }

    // MARK: - Table view data source
    
    func updateView() {
        nameField.text = modelparams!.name
        rcField.text = String(modelparams!.a)
        hrField.text = String(modelparams!.b)
        noteField.text = modelparams!.note
        modLabel.text = modelparams!.mod.description
    }
    
    // TODO: Stop disabling measured data cell
    func updateData() {
        if let measdata = modelparams!.measurements {
            dataLabel.text = "\(measdata.count) data points"
        } else {
            dataCell.isUserInteractionEnabled = false
            dataCell.accessoryType = .none
            dataLabel.text = "No data"
            dataLabel.textColor = .lightGray
        }
    }

    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MeasList" {
            let measView = segue.destination as! MeasTableViewController
            measView.measData = modelparams?.measurements
        }
    }
    
    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        guard let name = nameField.text,
            let rc = Float(rcField.text!),
            let hr = Float(hrField.text!),
            let note = noteField.text
            else { return }
        
        if let modelparams = self.modelparams {
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
