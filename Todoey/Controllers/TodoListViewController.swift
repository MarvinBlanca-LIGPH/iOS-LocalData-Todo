//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let color = selectedCategory?.bgColor {
            title = selectedCategory?.name
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation Controller does not exist.")
            }
            
            let uiColor = UIColor(hexString: color)!
            navBar.barTintColor = uiColor
            navBar.tintColor = ContrastColorOf(uiColor, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(uiColor, returnFlat: true)]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let selectedItem = todoItems?[indexPath.row] {
            cell.textLabel?.text = selectedItem.title
            cell.accessoryType = selectedItem.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.bgColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No todo items added."
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItem = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    selectedItem.done = !selectedItem.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let text = textField.text {
                
                if let category = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let item = Item()
                            item.title = text
                            item.dateCreated = Date()
                            category.items.append(item)
                        }
                    } catch {
                        print("Error saving new item, \(error)")
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task."
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItem(with item: Item) {
        //        do {
        //            try realm.write {
        //                realm.add(item)
        //            }
        //        } catch {
        //            print("Error saving context \(error)")
        //        }
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            deleteItem(from: item)
        }
    }
    
    func deleteItem(from item: Item) {
        do {
            try self.realm.write {
                self.realm.delete(item)
            }
        } catch {
            print("Failed deleting category, \(error)")
        }
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

