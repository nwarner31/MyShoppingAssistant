//
//  ShoppingListTableViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/18/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {

    var shoppingList = [ShoppingIngredient]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCartListCell", for: indexPath) as!  RecipeIngredientTableViewCell

        let shoppingIngredient = shoppingList[indexPath.row]
        
        cell.ingredientLabel.text = shoppingIngredient.ingredient?.name ?? ""
        cell.measurementLabel.text = shoppingIngredient.measurement
        cell.amountLabel.text = "\(shoppingIngredient.amount)"
        
        if shoppingIngredient.isInCart {
            cell.backgroundColor = UIColor.green
        } else if shoppingIngredient.isOutOfStock {
            cell.backgroundColor = UIColor.red
        } else {
            cell.backgroundColor = UIColor.white
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shoppingIngredient = shoppingList[indexPath.row]
        
        shoppingIngredient.isInCart = !shoppingIngredient.isInCart
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error updating shopping list. \(error)")
        }
    }
   
}
