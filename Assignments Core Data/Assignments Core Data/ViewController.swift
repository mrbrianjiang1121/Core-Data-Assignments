//
//  ViewController.swift
//  Assignments Core Data
//
//  Created by Brian Jiang on 7/11/19.
//  Copyright © 2019 Brian Jiang. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    var assignments = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignment")
        do {
            assignments = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch let err as NSError {
            print("Unable to fetch items", err)
        }
    }
    
    @objc func addItem() {
        let alertController = UIAlertController(title: "Add Assignment", message: "What assignments do you need to do?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let field = alertController.textFields?.first {
                self.saveItem(assignmentName: field.text!)
                self.tableView.reloadData()
            }
        }
        let revertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(revertAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "What do you need to do?"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveItem(assignmentName: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Assignment", in: managedContext)
        let assignment = NSManagedObject(entity: entity!, insertInto: managedContext)
        assignment.setValue(assignmentName, forKey: "assignmentName")
        
        do {
            try managedContext.save()
            assignments.append(assignment)
        } catch let err as NSError {
            print("Could not save this item", err)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let assignment = assignments[indexPath.row]
        cell?.textLabel?.text = assignment.value(forKey: "assignment") as! String?
        
        return cell!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return assignments.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            
            managedContext.delete(assignments[indexPath.row])
            assignments.remove(at: indexPath.row)
            
            self.tableView.reloadData()
        }
    }
}
