//
//  SettingsViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/20/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController:
UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var modelData: ThermalModelData!
    var initialTamb: Float = 0.0
    
    @IBOutlet weak var ambientField: UITextField!
    @IBOutlet weak var ambientStepper: UIStepper!
    @IBOutlet weak var modelPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        modelPicker.selectRow(modelData.selectedIndex, inComponent: 0, animated: true)
        modelPicker.showsSelectionIndicator = true
        ambientStepper.value = Double(initialTamb)
        updateViews()
    }
    
    // Output handling
    
    var selectedModel: Int {
        return modelPicker.selectedRow(inComponent: 0)
    }
    
    var Tamb: Float {
        return Float(ambientStepper.value)
    }

    // MARK: UIPickerView handling
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return modelData.modelArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: modelData.modelArray[row].name)
    }
    
    // MARK: UITableView handling
    
    // Non-standard segues
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            showFAQ()
        }
    }
    
    func updateViews() {
        let ambientStr = String(Int(Tamb)) + "º F"
        ambientField.text = ambientStr
    }
    
    func showFAQ() {
        if let faqURL = URL(string: "https://www.birge.us/ecochef-faq") {
            let safariViewController = SFSafariViewController(url:faqURL)
            present(safariViewController, animated: true, completion: nil)
        }
    }

    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        modelData.selectedIndex = selectedModel
        performSegue(withIdentifier: "UnwindSettings", sender: self)
    }
    
    @IBAction func clickAmbientStepper(_ sender: UIStepper) {
        updateViews()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let modelTableView = segue.destination as? ModelTableViewController {
            modelTableView.modelData = self.modelData
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        // Update data
        if let _ = segue.source as? ModelTableViewController {
            modelPicker.reloadAllComponents()
            modelData.WriteToDisk()
        }
    }
    
}