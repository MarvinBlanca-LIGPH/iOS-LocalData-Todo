//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Mark Marvin Blanca on 3/15/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { (uiAlertAction) in
            let category = Category(context: self.context)
            
            category.name = textField.text
            self.categoryArray.append(category)
            self.saveData()
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
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell",for: indexPath)
        let selectedPath = categoryArray[indexPath.row]
        
        cell.textLabel?.text = selectedPath.name
        
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
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
        
    }
    
    //MARK: - Data Manipulation Methods
    
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Failed to save data with error \(error)")
        }
    }
    
    func loadData() {
        let data: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categoryArray = try context.fetch(data)
        } catch {
            print("Failed to fetch data with error \(error)")
        }
        tableView.reloadData()
    }
}
