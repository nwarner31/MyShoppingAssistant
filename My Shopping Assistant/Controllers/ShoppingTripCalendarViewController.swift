//
//  ShoppingTripCalendarViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/15/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData
import FSCalendar

class ShoppingTripCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    private var mealPlans = [Date: MealPlan]()
    private var firstDateSelected: Date?
    
    private var shoppingTripBeginDate: Date?
    private var shoppingTripEndDate: Date?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var shoppingList: [ShoppingIngredient]?
    
    @IBOutlet weak var calendar: FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self

        loadMealPlans()
        // Do any additional setup after loading the view.
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let mealPlan = mealPlans[date]
        
        var numberOfMeals = 0
        
        //Conditionals to check if there is a meal for each meal of the day and if
        // so adds 1 to the event number
        numberOfMeals += mealPlan?.breakfast != nil ? 1 : 0
        numberOfMeals += mealPlan?.lunch != nil ? 1 : 0
        numberOfMeals += mealPlan?.dinner != nil ? 1 : 0
        
        return numberOfMeals
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        //Gets the number of seconds between the current time and the
        //date selected with the time being at midnight. The Time difference
        //is then compared to the number of seconds in a day (24 x 60 x 60 = 86,400)
        //to then determine if the selected date is the current date or later.
        let timeDifferenceInSeconds = date.timeIntervalSince(Date())
        if timeDifferenceInSeconds > -86400 {
            //print("true")
            selectDate(date)
            return true
        } else {
            //print("false")
            cannotSelectPastDateAlert()
            return false
        }
        
    }
    
    private func selectDate(_ date: Date) {
        if firstDateSelected == nil {
            firstDateSelected = date
        } else {
            if (firstDateSelected?.timeIntervalSince(date).isLess(than: 0.0))! {
                print("less")
                confirmDates(beginDate: firstDateSelected!, endDate: date)
            } else if (firstDateSelected?.timeIntervalSince(date).isEqual(to: 0.0))! {
                print("equal")
                confirmDates(beginDate: firstDateSelected!)
            } else {
                print("greater")
                confirmDates(beginDate: date, endDate: firstDateSelected!)
            }
        }
    }
    
    private func confirmDates(beginDate: Date, endDate: Date? = nil) {
        var message = ""
        if let endDate = endDate {
            message = "Do you want to create a shopping list for dates between: \(beginDate) and \(endDate)"
        } else {
            message = "Do you want to create a shopping list for date: \(beginDate)"
        }
        let confirmDatesAlert = UIAlertController(title: "Confirm dates", message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.getMealPlans(beginDate: beginDate, endDate: endDate)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.calendar.deselect(beginDate)
            self.firstDateSelected = nil
            confirmDatesAlert.dismiss(animated: true, completion: nil)
        }
        
        confirmDatesAlert.addAction(confirmAction)
        confirmDatesAlert.addAction(cancelAction)
        
        present(confirmDatesAlert, animated: true, completion: nil)
        
        
    }
    private func cannotSelectPastDateAlert() {
        let pastDateAlert = UIAlertController(title: "Unable to select date", message: "You cannot select a date that has already passed", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            pastDateAlert.dismiss(animated: true, completion: nil)
        }
        
        pastDateAlert.addAction(dismissAction)
        
        present(pastDateAlert, animated: true, completion: nil)
    }
    
    private func getMealPlans(beginDate: Date, endDate: Date? = nil) {
        var meals = [MealPlan]()
        if let endDate = endDate {
            //Iterates over the sorted meal plan dates
            for date in mealPlans.keys.sorted() {
                //If the date in the sorted dates is after the end date then exit the loop
                if endDate.timeIntervalSince(date).isLess(than: 0.0) {
                    break
                    //Adds the meal plans that fall before the end date but after the begin date
                } else if beginDate.timeIntervalSince(date).isLess(than: 0.0) {
                    if let mealPlan = mealPlans[date] {
                        meals.append(mealPlan)
                    }
                }
            }
        } else {
            //Gets the meal plan for the date selected if there is only 1 date
            if let mealPlan = mealPlans[beginDate] {
                meals.append(mealPlan)
            }
        }
        if meals.count > 0 {
            shoppingTripBeginDate = beginDate
            shoppingTripEndDate = endDate ?? beginDate
            createIngredientList(meals: meals)
        } else {
            noMealsInDateRangeAlert()
        }
    }
    private func createIngredientList(meals: [MealPlan]) {
        print(meals)
        var ingredientDictionary = [String: ShoppingIngredient]()
        for plan in meals {
            if let breakfast = plan.breakfast {
                if breakfast.mainDish != nil {
                    ingredientDictionary = addIngredientIn(breakfast.mainDish!, to: ingredientDictionary)
                }
                if breakfast.sideDish1 != nil {
                    ingredientDictionary = addIngredientIn(breakfast.sideDish1!, to: ingredientDictionary)
                }
                if breakfast.sideDish2 != nil {
                    ingredientDictionary = addIngredientIn(breakfast.sideDish2!, to: ingredientDictionary)
                }
            }
            if let lunch = plan.lunch {
                if lunch.mainDish != nil {
                    ingredientDictionary = addIngredientIn(lunch.mainDish!, to: ingredientDictionary)
                }
                if lunch.sideDish1 != nil {
                    ingredientDictionary = addIngredientIn(lunch.sideDish1!, to: ingredientDictionary)
                }
                if lunch.sideDish2 != nil {
                    ingredientDictionary = addIngredientIn(lunch.sideDish2!, to: ingredientDictionary)
                }
            }
            if let dinner = plan.dinner {
                if dinner.mainDish != nil {
                    ingredientDictionary = addIngredientIn(dinner.mainDish!, to: ingredientDictionary)
                }
                if dinner.sideDish1 != nil {
                    ingredientDictionary = addIngredientIn(dinner.sideDish1!, to: ingredientDictionary)
                }
                if dinner.sideDish2 != nil {
                    ingredientDictionary = addIngredientIn(dinner.sideDish2!, to: ingredientDictionary)
                }
            }
        }
        shoppingList = Array(ingredientDictionary.values)
        performSegue(withIdentifier: "viewIngredientsList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewIngredientsList" {
            let shoppingListVC = segue.destination as! ShoppingListViewController
            shoppingListVC.ingredientsList = shoppingList!
            shoppingListVC.shoppingTripBeginDate = shoppingTripBeginDate
            shoppingListVC.shoppingTripEndDate = shoppingTripEndDate
            
        }
    }
    
    private func addIngredientIn(_ dish: Recipe, to ingredientDictionary: [String: ShoppingIngredient]) -> [String: ShoppingIngredient] {
        var ingredientDictionary = ingredientDictionary
        let ingredients = dish.ingredients?.allObjects as! [RecipeIngredient]
        for ingredient in ingredients {
            //print("\(ingredient.ingredientName!.name!) \(ingredient.measurement!)")
            if let shoppingIngredient = ingredientDictionary["\(ingredient.ingredientName!.name!) \(ingredient.measurement!)"] {
                shoppingIngredient.amount += ingredient.amount
            } else {
                let shoppingIngredient = ShoppingIngredient(context: context)
                
                shoppingIngredient.ingredient = ingredient.ingredientName
                shoppingIngredient.measurement = ingredient.measurement
                shoppingIngredient.amount = ingredient.amount
                shoppingIngredient.isInCart = false
                shoppingIngredient.isOutOfStock = false
                
                ingredientDictionary["\(ingredient.ingredientName!.name!) \(ingredient.measurement!)"] = shoppingIngredient
                
                
            }
        }
        return ingredientDictionary
    }
    
    private func noMealsInDateRangeAlert() {
        let noMealsInDatesAlert = UIAlertController(title: "No meals in dates", message: "There were no meals between the dates provided. Please select dates with meal plans or add ones in.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            noMealsInDatesAlert.dismiss(animated: true, completion: nil)
        }
        
        noMealsInDatesAlert.addAction(okAction)
        
        present(noMealsInDatesAlert, animated: true, completion: nil)
    }
    
    private func loadMealPlans() {
        let mealPlanRequest: NSFetchRequest<MealPlan> = MealPlan.fetchRequest()
        
        do {
            let mealPlanArray = try context.fetch(mealPlanRequest)
            
            for mealPlan in mealPlanArray {
                let date = mealPlan.forDate
                
                mealPlans[date!] = mealPlan
            }
            print(mealPlanArray)
            calendar.reloadData()
        } catch {
            print("Error loading meal plans. \(error)")
        }
    }
    

}
