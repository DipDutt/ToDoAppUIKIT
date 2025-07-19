//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TodoListViewController: UITableViewController {
    // MARK: - Properties
    var toDoList:Results<Item>?
    var selectedCategory:Category? {
        didSet {
            loadedItems()
        }
    }
    
    let realm = try! Realm()
    
    @IBOutlet weak var serachBar: UISearchBar!
    
    // MARK: - ViewDidload()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        serachBar.barTintColor = .systemMint.withAlphaComponent(0.5)
    }
    
    // MARK: - this section for tableviewdatasource.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDoList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = toDoList?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text =  itemCell?.title ?? ""
        cell.accessoryType = itemCell?.isDone ?? false ? .checkmark : .none
        cell.backgroundColor = .systemTeal.withAlphaComponent(0.5)
        cell.delegate = self
        return cell
    }
    
    // MARK: - this section for tableviewdelegate.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoList?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print("An error occurred while saving the status: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - create pressAddItemButton to add item in the ToDolist.
    @IBAction func pressAddItemButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "Add items on the ToDoList✅", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add Item ➕", style: .default) { action in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text ?? ""
                        newItem.date = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch  {
                    print("error getting ream data")
                }
                
            }
            self.tableView.reloadData()
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "write your item"
            textField = alertTextField
            
        }
    }
    
    // MARK: - Create loadedItems method for read data form coredata model.
    
    func loadedItems() {
        toDoList = selectedCategory?.items.sorted(byKeyPath:"title", ascending: true)
    }
    
}

// MARK: - Create extension of ToListViewController for work with UISearchBar {

extension TodoListViewController: UISearchBarDelegate {
    
    // MARK: - create method to work with searchbarButton clicked to query data from core data.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoList = toDoList?.filter("title Contains[cd] %@",  searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
        
    }
    
    // MARK: - create searchbar text change method for go to orginal todo list.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty {
            self.loadedItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        tableView.reloadData()
        
    }
    
}

// MARK: - create TodoListViewController to work with swipe cell.

extension TodoListViewController:SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let category = self.toDoList?[indexPath.row] {
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
