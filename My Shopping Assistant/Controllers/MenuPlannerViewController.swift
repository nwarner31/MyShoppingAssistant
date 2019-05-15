//
//  MenuPlannerViewController.swift
//  My Shopping Assistant
//
//  Created by Nathaniel Warner on 5/9/19.
//  Copyright © 2019 Nathaniel Warner. All rights reserved.
//

import UIKit
import CoreData

class MenuPlannerViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    private var mealPlans = [Date: MealPlan]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var calendar: FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        calendar.dataSource = self
        calendar.delegate = self
        loadMealPlans()
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

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        performSegue(withIdentifier: "planMeals", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "planMeals" {
            let mealPlan = mealPlans[calendar.selectedDate!] ?? MealPlan(context: context)
            if mealPlan.forDate == nil {
                mealPlan.forDate = calendar.selectedDate!
            }
            let mealPlannerVC = segue.destination as! MealPlannerTableViewController
            mealPlannerVC.mealPlan = mealPlan
        }
    }

}
