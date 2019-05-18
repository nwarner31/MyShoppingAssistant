//
//  ShoppingListViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/17/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var ingredientsList = [ShoppingIngredient]()
    var shoppingTripBeginDate: Date?
    var shoppingTripEndDate: Date?
    
    private var shoppingTrip: ShoppingTrip?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var ingredientsListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientsListTableView.dataSource = self
        ingredientsListTableView.delegate = self
        // Do any additional setup after loading the view.
        print(shoppingTripBeginDate)
        print(shoppingTripEndDate)
    }
    

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let shoppingTrip = ShoppingTrip(context: context)
        shoppingTrip.addToIngredients(NSSet(array: ingredientsList))
        shoppingTrip.fromDate = shoppingTripBeginDate
        shoppingTrip.toDate = shoppingTripEndDate
        do {
            try context.save()
            self.shoppingTrip = shoppingTrip
            performSegue(withIdentifier: "finishShoppingList", sender: self)
        } catch {
            print("Error saving shopping trip. \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishShoppingList" {
            let shoppingListVC = segue.destination as! ShoppingListTableViewController
            shoppingListVC.shoppingList = ingredientsList
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingListCell", for: indexPath) as! RecipeIngredientTableViewCell
        
        let shoppingIngredient = ingredientsList [indexPath.row]
        
        cell.ingredientLabel.text = shoppingIngredient.ingredient?.name ?? ""
        cell.measurementLabel.text = shoppingIngredient.measurement
        cell.amountLabel.text = "\(shoppingIngredient.amount)"
        
        return cell
    }

}
