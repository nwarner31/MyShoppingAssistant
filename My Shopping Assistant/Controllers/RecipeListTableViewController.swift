//
//  RecipeListTableViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/3/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class RecipeListTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadAllRecipes()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recipes.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeListCell", for: indexPath) as! SwipeTableViewCell

        cell.delegate = self
        if indexPath.row < recipes.count {
            cell.textLabel?.text = recipes[indexPath.row].name
        } else {
            cell.imageView?.image = UIImage(named: "add-icon")
            cell.textLabel?.text = "Add new recipe"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < recipes.count {
            performSegue(withIdentifier: "showRecipe", sender: self)
        } else {
            insertRecipeAlert()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipe" {
            let recipeVC = segue.destination as! RecipeViewController
            if let rowSelected = tableView.indexPathForSelectedRow?.row {
                recipeVC.recipe = recipes[rowSelected]
            }
        }
    }
    
    private func insertRecipeAlert() {
        let newRecipeAlert = UIAlertController(title: "Add new recipe", message: "Please enter the name of the new recipe", preferredStyle: .alert)
        
        var newRecipeTextField = UITextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            newRecipeAlert.dismiss(animated: true, completion: nil)
        }
        
        newRecipeAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Recipe name"
            newRecipeTextField = alertTextField
        }
        
        
        let insertAction = UIAlertAction(title: "Create Recipe", style: .default) { (action) in
            if let recipeName = newRecipeTextField.text {
                if recipeName != "" {
                    self.createRecipe(named: recipeName)
                    newRecipeAlert.dismiss(animated: true, completion: nil)
                } else {
                    let noRecipeNameAlert = UIAlertController(title: "No recipe name entered", message: "To save a recipe please enter a name", preferredStyle: .alert)
                    let closeNoRecipe = UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                        noRecipeNameAlert.dismiss(animated: true, completion: nil)
                    })
                    noRecipeNameAlert.addAction(closeNoRecipe)
                    self.present(noRecipeNameAlert, animated: true, completion: nil)
                }
            }
        }
        
        newRecipeAlert.addAction(insertAction)
        newRecipeAlert.addAction(cancelAction)
        
        present(newRecipeAlert, animated: true, completion: nil)
        
    }
    
    private func createRecipe(named recipeName: String) {
        print(recipeName)
        let newRecipe = Recipe(context: context)
        //context.insert(newRecipe)
        newRecipe.setValue(recipeName, forKey: "name")
        
        do {
            try context.save()
            recipes.append(newRecipe)
            tableView.reloadData()
        } catch {
            print("Error saving recipe. \(error)")
        }
    }

    private func loadAllRecipes() {
        let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        do {
            recipes = try context.fetch(recipeRequest)
            tableView.reloadData()
        } catch {
            print("Error getting recipes. \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            let deleteRecipeAction = SwipeAction(style: .destructive, title: "Delete Recipe") { (action, indexPath) in
                do {
                    self.context.delete(self.recipes[indexPath.row])
                    try self.context.save()
                    self.recipes.remove(at: indexPath.row)
                    self.tableView.reloadData()
                } catch {
                    print("Error deleting recipe. \(error)")
                }
            }
            
            return [deleteRecipeAction]
        } else {
            let editRecipeNameAction = SwipeAction(style: .default, title: "Edit Recipe Name") { (action, indexPath) in
                
            }
            editRecipeNameAction.backgroundColor = UIColor.green
            
            return [editRecipeNameAction]
        }
    }
}
