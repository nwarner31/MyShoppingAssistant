//
//  MealPlannerTableViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/10/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData

class MealPlannerTableViewController: UITableViewController, RecipeToMeal {
 
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let meals = ["Breakfast", "Lunch", "Dinner"]
    let dishes = ["main dish", "side dish 1", "side dish 2"]
    
    var mealPlan: MealPlan?
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(mealPlan)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return meals[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor.green
        
        let headerView = view as! UITableViewHeaderFooterView
        
        headerView.textLabel?.textColor = UIColor.blue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealRecipeCell", for: indexPath)

        
        if let recipe = getRecipe(mealNumber: indexPath.section, dishNumber: indexPath.row) {
            cell.textLabel?.text = recipe.name
        } else {
            cell.textLabel?.text = "\(meals[indexPath.section]) \(dishes[indexPath.row])"
        }
        
        return cell
    }
    
    private func getRecipe(mealNumber: Int, dishNumber: Int) -> Recipe? {
        var meal: Meal?
        if mealNumber == 0 {
            meal = mealPlan?.breakfast
        } else if mealNumber == 1 {
            meal = mealPlan?.lunch
        } else {
            meal = mealPlan?.dinner
        }
        
        if dishNumber == 0 {
            return meal?.mainDish
        } else if dishNumber == 1 {
            return meal?.sideDish1
        } else {
            return meal?.sideDish2
        }
        
    }
    
    private func setRecipe(_ recipe: Recipe, mealNumber: Int, dishNumber: Int) {
        
        var meal: Meal?
        if mealNumber == 0 {
            if mealPlan?.breakfast == nil {
                mealPlan?.breakfast = Meal(context: context)
            }
            meal = mealPlan?.breakfast
        } else if mealNumber == 1 {
            if mealPlan?.lunch == nil {
                mealPlan?.lunch = Meal(context: context)
            }
            meal = mealPlan?.lunch
        } else {
            if mealPlan?.dinner == nil {
                mealPlan?.dinner = Meal(context: context)
            }
            meal = mealPlan?.dinner
        }
        
        if dishNumber == 0 {
            meal?.mainDish = recipe
        } else if dishNumber == 1 {
            meal?.sideDish1 = recipe
        } else {
            meal?.sideDish2 = recipe
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "selectRecipeForMeal", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectRecipeForMeal" {
            let recipeSelectorVC = segue.destination as! RecipeSelectorTableViewController
            recipeSelectorVC.delegate = self
        }
    }
    
    func addRecipe(_ recipe: Recipe) {
        //print(recipe.name)
        if let selectedRow = tableView.indexPathForSelectedRow {
            setRecipe(recipe, mealNumber: selectedRow.section, dishNumber: selectedRow.row)
          
            //print(mealPlan)
            do {
                try context.save()
            } catch {
                print("Error saving recipe to meal. \(error)")
            }
            tableView.reloadData()
        }
    }
}
