//
//  PlantsTableViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
// PlantCell
// AddPlantSegue
// DetailPlantSegue
// LoginSegue ?
// EditUserSegue

// TEST
var testPlants: [FakePlant] = [FakePlant(nickname: "Jackie",
      species: "Tulip",
      water_schedule: Date(timeIntervalSinceNow: 60),
      last_watered: nil,
      frequency: 3,
      image_url: nil,
      id: 1),
FakePlant(nickname: "Tanya",
      species: "Dandelion",
      water_schedule: Date(timeIntervalSinceNow: 190),
      last_watered: nil,
      frequency: 2,
      image_url: nil,
      id: 2),
FakePlant(nickname: "Paula",
      species: "Rose",
      water_schedule: Date(timeIntervalSinceNow: 340),
      last_watered: nil,
      frequency: 1,
      image_url: nil,
      id: 3)]
// TEST

class PlantsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    @IBOutlet weak var userIcon: UIBarButtonItem!
    @IBOutlet weak var addPlantIcon: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlantIcon.tintColor = .systemGreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show login screen when view did appear
        //performSegue(withIdentifier: "LoginModalSegue", sender: self)
        tableView.reloadData()
    }
    
    func startTimer() {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testPlants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath)

        // Configure the cell...
    
        // TEST
        let testCell = testPlants[indexPath.row]
        cell.textLabel?.text = "\(testCell.nickname) - \(testCell.species)"
        cell.textLabel?.textColor = .systemGreen
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = "Every \(testCell.frequency) days - \(dateFormatter.string(from: testCell.water_schedule))"
        // TEST
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // DetailViewController (to ADD plant)
        if segue.identifier == "AddPlantSegue" {
            print("AddPlantSegue")
            //guard let detailVC = segue.destination as? DetailViewController else {return}
            
        }
        
        // DetailViewController (to EDIT plant)
        if segue.identifier == "DetailPlantSegue" {
            print("DetailPlantSegue")
        }
        
        // UserViewController (to EDIT user)
        if segue.identifier == "EditUserSegue" {
            print("EditUserSegue")
        }
    }
}

// TEST
class FakePlant {
    var nickname: String
    var species: String
    var water_schedule: Date
    var last_watered: Date?
    var frequency: Int
    var image_url: String?
    var id: Int
    
    init(nickname: String, species: String, water_schedule: Date, last_watered: Date?, frequency: Int = 0, image_url: String?, id: Int) {
        self.nickname = nickname
        self.species = species
        self.water_schedule = water_schedule
        self.last_watered = last_watered
        self.frequency = frequency
        self.image_url = image_url
        self.id = id
    }
}
// TEST
