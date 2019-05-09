//
//  AddIngredientToRecipeViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/7/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData

class AddIngredientToRecipeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: IngredientToRecipe?

    private var ingredients = [Ingredient]()
    @IBOutlet weak var ingredientPickerView: UIPickerView!
    @IBOutlet weak var ingredientSizePickerView: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    
    private let measurementsArray = ["each", "lb", "cup", "can", "tsp", "Tbsp"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadIngredients()
        
        ingredientPickerView.delegate = self
        ingredientPickerView.dataSource = self
        
        ingredientSizePickerView.delegate = self
        ingredientSizePickerView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addIngredientButtonPressed(_ sender: UIButton) {
        if delegate != nil {
            let amountText = amountTextField.text != "" ? amountTextField.text! : "1.0"
            let amount = Float("\(amountText)")!
            let selectedIngredient = ingredients[ingredientPickerView.selectedRow(inComponent: 0) - 1]
            let selectedAmount = measurementsArray[ingredientSizePickerView.selectedRow(inComponent: 0) - 1]
            delegate?.addIngredient(selectedIngredient, amount: amount, measurement: selectedAmount)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return ingredients.count + 2
        } else if pickerView.tag == 2 {
            return measurementsArray.count + 1
        } else {
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            if row == 0 {
                return "Select Ingredient"
            } else if row <= ingredients.count {
                return ingredients[row - 1].name
            } else {
                return "Add New"
            }
        } else if pickerView.tag == 2 {
            if row == 0 {
                return "Size"
            } else {
                return measurementsArray[row - 1]
            }
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            if row == 0 {
                
            } else if row <= ingredients.count {
                
            } else {
                addIngredientAlert()
            }
            print(row)
        }
    }
    
    private func addIngredientAlert() {
        
        var ingredientNameTextField = UITextField()
        let insertIngredientAlert = UIAlertController(title: "Add new ingredient", message: "Please enter the name of the new ingredient", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            if let ingredientName = ingredientNameTextField.text {
                if ingredientName != "" {
                    self.saveIngredientName(ingredientName)
                    insertIngredientAlert.dismiss(animated: true, completion: nil)
                } else {
                    let noIngredientNameAlert = UIAlertController(title: "No ingredient name entered", message: "To save an ingredient please enter a name", preferredStyle: .alert)
                    let closeNoIngredient = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        noIngredientNameAlert.dismiss(animated: true, completion: nil)
                    })
                    noIngredientNameAlert.addAction(closeNoIngredient)
                    self.present(noIngredientNameAlert, animated: true, completion: nil)
                }
            }
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.ingredientPickerView.selectRow(0, inComponent: 0, animated: true)
            insertIngredientAlert.dismiss(animated: true, completion: nil)
        }
        
        insertIngredientAlert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Enter ingredient name here"
            ingredientNameTextField = nameTextField
        }
        
        insertIngredientAlert.addAction(saveAction)
        insertIngredientAlert.addAction(cancelAction)
        
        present(insertIngredientAlert, animated: true, completion: nil)
    }
    
    //MARK: - Core Data Methods

    private func loadIngredients() {
        let ingredientRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        do {
            ingredients = try context.fetch(ingredientRequest)
            
            ingredientPickerView.reloadComponent(0)
        } catch {
            print("Error loading ingredients. \(error)")
        }
    }
    private func saveIngredientName(_ ingredientName: String) {
        let newIngredient = Ingredient(context: context)
        newIngredient.setValue(ingredientName, forKey: "name")
        
        do {
            try context.save()
            ingredients.append(newIngredient)
            ingredientPickerView.reloadComponent(0)
        } catch {
            print("Error saving ingredient name. \(error)")
        }
    }
}

protocol IngredientToRecipe {
    func addIngredient(_ ingredient: Ingredient, amount: Float, measurement: String)
}
