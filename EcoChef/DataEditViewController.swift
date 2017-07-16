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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // TODO: Prepare for unwind

    // MARK: - Outlets
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var finalField: UITextField!
    @IBOutlet weak var ambField: UITextField!
}
