//
//  ModelTableViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 7/2/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class ModelTableViewController: UITableViewController {
    var modelData: ThermalModelData!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelData.modelArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath)
        cell.textLabel?.text = modelData.modelArray[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            modelData.modelArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let fromrow = fromIndexPath.row
        let torow = to.row
        let movedModel = modelData.modelArray[fromrow]
        modelData.modelArray.remove(at: fromrow)
        modelData.modelArray.insert(movedModel, at: torow)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let editController = segue.destination as? ModelEditViewController
            else { return }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            editController.modelparams = modelData.modelArray[indexPath.row]
        }
    }
    
    @IBAction func doEdit(_ sender: Any) {
        if self.isEditing {
            self.setEditing(false, animated: true)
        } else {
            self.setEditing(true, animated: true)
        }
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "UnwindModelList", sender: self)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let source = segue.source as? ModelEditViewController,
        let modelparams = source.modelparams
            else { return }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            modelData.modelArray.remove(at: indexPath.row)
            modelData.modelArray.insert(modelparams, at: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            modelData.modelArray.append(modelparams)
        }
        
        tableView.reloadData()
    }
    
}
