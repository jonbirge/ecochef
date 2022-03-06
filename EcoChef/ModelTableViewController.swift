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
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            modelData.modelArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
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
            editController.modelParams = modelData.modelArray[indexPath.row]
        }
    }
    
    @IBAction func doEdit(_ sender: UIBarButtonItem) {
        if self.isEditing {
            self.setEditing(false, animated: true)
        } else {
            self.setEditing(true, animated: true)
        }
    }
    
    @IBAction func doAdd(_ sender: UIBarButtonItem) {
        let defaultModelList = ThermalModelData.DefaultModelList()
        
        let alertController = UIAlertController(title: "Choose model type",
                                                message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for theModel in defaultModelList {
            let theAction = UIAlertAction(title: theModel.name, style: .default) {
                action in
                self.modelData.modelArray.append(theModel)
                self.tableView.reloadData()
                let lastIndex = self.modelData.modelArray.count - 1
                let thePath = IndexPath(row: lastIndex, section: 0)
                self.tableView.selectRow(at: thePath, animated: true, scrollPosition: .none)
                self.performSegue(withIdentifier: "EditModel", sender: self) }
            alertController.addAction(theAction) }
        
        alertController.popoverPresentationController?.sourceView = self.view
            
        present(alertController, animated: true)
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        print("ModelTableViewController:goBack()")
        performSegue(withIdentifier: "UnwindModelList", sender: self)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        print("ModelTableViewController:prepareForUnwind()")
        guard let source = segue.source as? ModelEditViewController,
        let modelParams = source.modelParams
            else { return }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            modelData.modelArray.remove(at: indexPath.row)
            modelData.modelArray.insert(modelParams, at: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            modelData.modelArray.append(modelParams)
        }
        
        tableView.reloadData()
    }
    
}
