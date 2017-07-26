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
            cell.detailTextLabel?.text = "\(thedata.Tstart)º ➔ \(thedata.Tfinal)º"
        } else {
            cell.detailTextLabel?.text =
            "\(thedata.Tstart)º ➔ \(thedata.Tfinal)º at \(thedata.Tamb)º"
        }
        
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let theview = segue.destination as? DataEditViewController else
        { return }
        
        if let path = tableView.indexPathForSelectedRow {  // old one
            theview.dataPoint = measData[path.row]
        } else {  // new one
            if measData.count > 0 {
                theview.dataPoint =
                    HeatingDataPoint(copiedfrom: measData[measData.count-1])
            } else {
                theview.dataPoint = HeatingDataPoint()
            }
            measData.addDataPoint(theview.dataPoint)
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        tableView.reloadData()
        print("prep for unwind in MeasTableViewController")
        
    }

}
