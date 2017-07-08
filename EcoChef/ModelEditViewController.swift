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
        updateView()
    }

    // MARK: - Table view data source
    
    func updateView() {
        if let modelparams = self.modelparams {
            nameField.text = modelparams.name
            rcField.text = String(modelparams.a)
            hrField.text = String(modelparams.b)
            noteField.text = modelparams.note
            modLabel.text = modelparams.mod.description
        } else {
            self.modelparams = ThermalModelParams(name: "New Model")  // default
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        guard let name = nameField.text,
        let rc = Float(rcField.text!),
        let hr = Float(hrField.text!)
            else { return }
        
        let note = noteField.text!
        let mod = Date()
        modelparams = ThermalModelParams(name: name,
                                         a: rc, b: hr,
                                         note: note,
                                         mod: mod)
        
        performSegue(withIdentifier: "UnwindToModelList", sender: self)
    }

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var rcField: UITextField!
    @IBOutlet weak var hrField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var modLabel: UILabel!
}
