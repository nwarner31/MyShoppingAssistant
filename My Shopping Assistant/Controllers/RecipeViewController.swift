//
//  RecipeViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/7/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IngredientToRecipe {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
    

    var recipe: Recipe?
    private var ingredients = [RecipeIngredient]()
    
    @IBOutlet weak var recipePicImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        recipeNameLabel.text = recipe?.name
        
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        
        if let ingredientsSet = recipe?.ingredients {
            ingredients = Array(ingredientsSet) as! [RecipeIngredient]
        }
        
        
        // Do any additional setup after loading the view.
    }
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < recipe?.ingredients?.count ?? 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipeIngredientCell", for: indexPath) as! RecipeIngredientTableViewCell
            let ingredient = ingredients[indexPath.row]
            cell.ingredientLabel.text = ingredient.ingredientName?.name
            cell.amountLabel.text = "\(ingredient.amount)"
            cell.measurementLabel.text = ingredient.measurement
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addIngredientCell", for: indexPath) as! AddItemTableViewCell
            
            cell.iconImage.image = UIImage(named: "add-icon")
            cell.titleLabel.text = "Add new ingredient"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= ingredients.count {
            performSegue(withIdentifier: "addIngredient", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addIngredient" {
            let addIngredientVC = segue.destination as! AddIngredientToRecipeViewController
            addIngredientVC.delegate = self
        }
    }
    
    func addIngredient(_ ingredient: Ingredient, amount: Float, measurement: String) {
        //print("\(amount) \(measurement) \(ingredient.name ?? "")")
        
        let newRecipeIngredient = RecipeIngredient(context: context)
        newRecipeIngredient.ingredientName = ingredient
        newRecipeIngredient.amount = amount
        newRecipeIngredient.measurement = measurement
        recipe?.addToIngredients(newRecipeIngredient)
        ingredients.append(newRecipeIngredient)
        recipeTableView.reloadData()
        do {
            try context.save()
        } catch {
            print("Error saving new ingredient for recipe. \(error)")
        }
        
    }
}
