//
//  SavedShoppingTripTableViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/18/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData

class SavedShoppingTripTableViewController: UITableViewController {

    private var savedShoppingTrips = [ShoppingTrip]()
    
    private var shoppingList = [ShoppingIngredient]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()

        loadShoppingTrips()
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return savedShoppingTrips.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingTripCell", for: indexPath)

        let shoppingTrip = savedShoppingTrips[indexPath.row]
        
        cell.textLabel?.text = "\(String(describing: shoppingTrip.fromDate)) to \(String(describing: shoppingTrip.toDate))"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let shoppingSet = savedShoppingTrips[indexPath.row].ingredients {
            shoppingList = Array(shoppingSet) as! [ShoppingIngredient]
            performSegue(withIdentifier: "loadShoppingList", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadShoppingList" {
            let shoppingListVC = segue.destination as! ShoppingListTableViewController
            shoppingListVC.shoppingList = shoppingList
        }
    }

    private func loadShoppingTrips() {
        let shoppingTripRequest: NSFetchRequest<ShoppingTrip> = ShoppingTrip.fetchRequest()
        do {
            savedShoppingTrips = try context.fetch(shoppingTripRequest)
        } catch {
            print("Error loading shopping trips. \(error)")
        }
    }

}
