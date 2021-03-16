//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Mark Marvin Blanca on 3/15/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist.")
        }
        
        navBar.barTintColor = UIColor(hexString: "1D9BF6")
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { (uiAlertAction) in
            let category = Category()
            
            category.name = textField.text!
            let color = UIColor.randomFlat()
            category.bgColor = color.hexValue()
            self.saveData(with: category)
            self.tableView.reloadData()
        }
        
        alert.addTextField { (uiTextField) in
            uiTextField.placeholder = "Input a category"
            textField = uiTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let selectedPath = categoryArray?[indexPath.row]
        cell.textLabel?.text = selectedPath?.name ?? "No categories added"
        
        if let color = selectedPath?.bgColor {
            if let uiColor = UIColor(hexString: color) {
                cell.backgroundColor = uiColor
                cell.textLabel?.textColor = ContrastColorOf(uiColor, returnFlat: true)
            }
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
        
    }
    
    //MARK: - Data Manipulation Methods
    
    
    func saveData(with category: Category) {
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Failed to write on realm with error \(error)")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categoryArray?[indexPath.row] {
            self.deleteItem(from: category)
        }
    }
    
    func deleteItem(from category: Category) {
        do {
            try self.realm.write {
                self.realm.delete(category)
            }
        } catch {
            print("Failed deleting category, \(error)")
        }
    }
    
    func loadData() {
        categoryArray = realm.objects(Category.self)
    }
}
