//
//  RecipeSelectorTableViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/11/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData

class RecipeSelectorTableViewController: UITableViewController {

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var recipes = [Recipe]()
    
    var delegate: RecipeToMeal?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAllRecipes()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeSelectorCell", for: indexPath)

        cell.textLabel?.text = recipes[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            delegate?.addRecipe(recipes[indexPath.row])
            self.dismiss(animated: true, completion: nil)
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
}

protocol RecipeToMeal {
    func addRecipe(_ recipe: Recipe)
}
