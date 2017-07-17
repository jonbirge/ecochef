//
//  DataEditViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/16/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class DataEditViewController: UITableViewController {
    var dataPoint: HeatingDataPoint!

    override func viewDidLoad() {
        super.viewDidLoad()
        UpdateView()
    }

    func UpdateView() {
        timeField.text = String(dataPoint.time)
        startField.text = String(dataPoint.Tstart)
        finalField.text = String(dataPoint.Tfinal)
        ambField.text = String(dataPoint.Tamb)
    }
    
    // MARK: - Outlets and Actions
    
    @IBAction func doSave(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "UnwindToMeasList", sender: self)
    }
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var finalField: UITextField!
    @IBOutlet weak var ambField: UITextField!
}
