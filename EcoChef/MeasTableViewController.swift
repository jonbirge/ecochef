//
//  MeasTableViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/16/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class MeasTableViewController: UITableViewController {
    private var measData: HeatingDataSet!  // convenience
    var modelParams: ThermalModelParams!

    override func viewDidLoad() {
        super.viewDidLoad()
        measData = modelParams.measurements
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
        let thetime = round(100*thedata.time)/100
        cell.textLabel?.text = "\(thetime) min"
        if thedata.Tstart == thedata.Tamb {
            cell.detailTextLabel?.text = "\(Int(thedata.Tstart))º ➔ \(Int(thedata.Tfinal))º"
        } else {
            cell.detailTextLabel?.text =
            "\(Int(thedata.Tstart))º ➔ \(Int(thedata.Tfinal))º at \(Int(thedata.Tamb))º"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            measData.measlist.remove(at: indexPath.row)
            modelParams.fitfromdata()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
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
    
    // TODO: This evidently isn't needed or getting fired
    //    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    //        print("MeasTableViewController:prepareForUnwind()")
    //        modelParams.measurements.sort()
    //        tableView.reloadData()
    //        modelParams.fitfromdata()
    //    }

}
