//
//  MeasTableViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/16/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class MeasTableViewController: UITableViewController {
    var measData: HeatingDataSet!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeasCell", for: indexPath)

        // Configure the cell...
        let thedata = measData[indexPath.row]
        cell.textLabel?.text = "\(thedata.time) min"
        if thedata.Tstart == thedata.Tamb {
            cell.detailTextLabel?.text = "\(thedata.Tstart)º to \(thedata.Tfinal)º"
        } else {
            cell.detailTextLabel?.text =
            "\(thedata.Tstart)º to \(thedata.Tfinal)º at \(thedata.Tamb)º"
        }
        
        return cell
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
