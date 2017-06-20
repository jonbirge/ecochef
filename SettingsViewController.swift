//
//  SettingsViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/20/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UITableViewController {

    @IBOutlet weak var ambientField: UITextField!
    @IBOutlet weak var ambientStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "UnwindSettings", sender: self)
    }
    
    @IBAction func clickAmbientStepper(_ sender: UIStepper) {
        let Tamb = sender.value
        let ambientStr = String(Int(Tamb)) + " degrees"
        ambientField.text = ambientStr
    }
    
    @IBAction func clickFAQ(_ sender: UIButton) {
        if let faqURL = URL(string: "https://www.birge.us/public") {
            let safariViewController = SFSafariViewController(url:faqURL)
            present(safariViewController, animated: true, completion: nil)
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

}
