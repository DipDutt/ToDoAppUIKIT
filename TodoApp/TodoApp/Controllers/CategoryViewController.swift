//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Dip Dutt on 14/4/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

class CategoryViewController:UITableViewController {
    
    // MARK: - Properties
    var categories: Results<Category>?
    let realm = try! Realm()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        loadedItems()
    }
    
    // MARK: - this section for tableviewdatasource.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = categories?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "categorytableViewCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text =  categoryCell?.name ?? ""
        cell.backgroundColor = .lightGray.withAlphaComponent(0.6)
        cell.delegate = self
        return cell
    }
    
    // MARK: - this section for tableviewdelegate.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDoList", sender: self)
    }
    
    
    
    // MARK: - Create this method for segue Preparation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexSelect = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexSelect.row]
        }
        
    }
    
    // MARK: - Create pressedAddButton() method to add item.
    @IBAction func pressedAddButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "Add catogory on the ToDodey✅", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add category ➕", style: .default) { action in
            let newCategory = Category()
            newCategory.name = textField.text ?? ""
            self.saveditems(category: newCategory)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "write your category"
            textField = alertTextField
            
        }
    }
    
    // MARK: - Create saveditems method to save our customdata.
    func saveditems(category:Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch  {
            print("error getting context: \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Create loadedItems method for read data form coredata model.
    func loadedItems() {
        categories = realm.objects(Category.self)
        
    }
}

// MARK: - create categoryViewController extension to work with swipe Cell.
extension CategoryViewController:SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let category = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(category)
                    }
                } catch  {
                    print("error delete categories")
                }
                tableView.reloadData()
            }
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
        
    }
    
    // MARK: - create this method for action option on tableview cell
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    
}

