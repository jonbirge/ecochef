//
//  SettingsViewController.swift
//  EcoChef
//
//  Copyright © 2022 Birge Clocks. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class SettingsViewController:
    UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate {
    var modelData: ThermalModelData?
    var initialTamb: Float?  // F
    var Tamb: Float!  // F
    var useCelcius: Bool = false
    
    @IBOutlet var ambientField: UITextField!
    @IBOutlet var ambientStepper: UIStepper!
    @IBOutlet var modelPicker: UIPickerView!
    @IBOutlet var siteLabel: UILabel!
    @IBOutlet var siteCell: UITableViewCell!
    @IBOutlet var celciusCell: UITableViewCell!
    @IBOutlet var farenheitCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Tamb = initialTamb ?? 70
           
        if let modelIndex = modelData?.selectedIndex {
        modelPicker.selectRow(modelIndex,
            inComponent: 0, animated: false)
        }
        updateUnits()
        updateViews()
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available.")
            siteLabel.isEnabled = false
            siteCell.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        modelPicker.reloadAllComponents()
        modelData?.WriteToDisk()
    }
    
    /// Called when temp units are changed in interface by user
    private func updateUnits() {
        if useCelcius {
            ambientStepper.maximumValue = 40
            ambientStepper.minimumValue = -20
            ambientStepper.stepValue = 1
            ambientStepper.value = Double(round(2*ThermalModel.FtoC(temp:Tamb))/2)
        } else {
            ambientStepper.maximumValue = 110
            ambientStepper.minimumValue = 0
            ambientStepper.stepValue = 1
            ambientStepper.value = Double(round(Tamb))
        }
    }
    
    /// Update all views from data models
    private func updateViews() {
        var ambientStr : String
        if useCelcius {
            ambientStr = ThermalModel.DisplayC(temp: Tamb)
        } else {
            ambientStr = ThermalModel.DisplayF(temp: Tamb)
        }
        ambientField.text = ambientStr
        
        if useCelcius {
            celciusCell.accessoryType = UITableViewCell.AccessoryType.checkmark
            farenheitCell.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            celciusCell.accessoryType = UITableViewCell.AccessoryType.none
            farenheitCell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }
    
    // MARK: Output handling
    
    var selectedModel: Int {
        return modelPicker.selectedRow(inComponent: 0)
    }

    // MARK: UIPickerView handling
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        guard let theCount = modelData?.modelArray.count else {
            return 0
        }
        return theCount
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let theString = modelData?.modelArray[row].name else { return nil }
        return NSAttributedString(string: theString)
    }
    
    // MARK: UITableView handling
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 {  // UNITS
            if indexPath.row == 0 {
                useCelcius = true
                celciusCell.isSelected = false
            } else {
                useCelcius = false
                farenheitCell.isSelected = false
            }
            updateUnits()
            updateViews()
        }
        
        if indexPath.section == 4 {  // INFO
            switch indexPath.row {
            case 0:
                showFAQ()
            case 1:
                showSite()
            default:
                return
            }
        }
    }
    
    /// Use web view to show FAQ
    func showFAQ() {
        if let faqURL = URL(string: EcoChefState.faqURL) {
            let safariViewCont = SFSafariViewController(url:faqURL)
            present(safariViewCont, animated: true, completion: nil)
        }
    }
    
    /// Show online help from **birgefuller.com**
    func showSite() {
        let email = "ecochef@birgefuller.com"
        let subject = "[EcoChef] Question"
        
        // https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller
        if MFMailComposeViewController.canSendMail()
        {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([email])
            mailComposer.setSubject(subject)
            present(mailComposer, animated: true, completion: nil)
            print("Displayed mail modal dialog")
        }
        else
        {
            print("Error: Device not configured for email, yet button was enabled!")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        print("In mailComposeController delegate...")
        print(result.rawValue)
        siteCell.isSelected = false
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        modelData?.selectedIndex = selectedModel
        performSegue(withIdentifier: "UnwindSettings", sender: self)
    }
    
    @IBAction func clickAmbientStepper(_ sender: UIStepper) {
        if useCelcius {
            //print("Tamb = " + String(ambientStepper.value) + " C")
            Tamb = ThermalModel.CtoF(temp: Float(ambientStepper.value))
        } else {
            //print("Tamb = " + String(ambientStepper.value) + " F")
            Tamb = Float(ambientStepper.value)
        }
        updateViews()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let modelTableView = segue.destination as? ModelTableViewController {
            modelTableView.modelData = self.modelData
        }
    }
    
}
