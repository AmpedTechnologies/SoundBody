//
//  GoalSettingsViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 4/4/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase

class GoalSettingsViewController: UIViewController {
    
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    var orgName: String!
    var setup = false
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var mindSlider: UISlider!
    @IBOutlet weak var sleepSlider: UISlider!
    @IBOutlet weak var mindOut: UILabel!
    @IBOutlet weak var sleepOut: UILabel!
    @IBOutlet weak var wellnessSessions: UILabel!
    @IBOutlet weak var wellnessSlider: UISlider!
    
    
    var ud = UserDefaults.standard
    var mindSessions: Int?
    var sleepHours: Int?
    
    // Action for mindslider
    @IBAction func mindSliderAction(_ sender: Any) {
        mindSlider.setValue(mindSlider.value.rounded(.down), animated: true)
        
            mindOut.text = String(Int(mindSlider.value))
    }
    
    //Action for sleep Slider
    @IBAction func sleepSliderAction(_ sender: Any) {
        sleepSlider.setValue(sleepSlider.value.rounded(.down), animated: true)
        
        sleepOut.text = String(Int(sleepSlider.value))
    }
    
    // Action for Wellness session slider
    @IBAction func wellnessSliderAction(_ sender: Any) {
        wellnessSlider.setValue(wellnessSlider.value.rounded(.down), animated: true)
        
        wellnessSessions.text = String(Int(wellnessSlider.value))
    }
    
    
    // Update database information upon exit button clicked
    @IBAction func exitButtonAction(_ sender: Any) {
        Functions.updateGoal(company: orgName, area: "mindSessions", count: Int(mindSlider.value))
        Functions.updateGoal(company: orgName, area: "sleepHours", count: Int(sleepSlider.value))
        Functions.updateGoal(company: orgName, area: "wellnessSessions", count: Int(wellnessSlider.value))
        if setup == false {
        performSegue(withIdentifier: "exit", sender: self)
        } else {
            performSegue(withIdentifier: "backToSetup", sender: self)
        }
    }
    
    // Function to get user goal information from database
    func loadData(){
        print("----")
        Functions.getUserGoals(company: orgName, detail: "sleepHours") { (result) in
            self.sleepSlider.value = Float(result)
            self.sleepOut.text = String(result)
        }
        Functions.getUserGoals(company: orgName, detail: "mindSessions") { (result) in
            self.mindSlider.value = Float(result)
            self.mindOut.text = String(result)
        }
        Functions.getUserGoals(company: orgName, detail: "wellnessSessions") { (result) in
            self.wellnessSlider.value = Float(result)
            self.wellnessSessions.text = String(result)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        //Run funtion to get user goal information
        loadData()
        
        // UI Setup
        self.exitButton.setTitleColor(.white, for: .normal)
        self.exitButton.layer.borderWidth = 2
        self.exitButton.layer.borderColor = UIColor.white.cgColor
        self.exitButton.layer.cornerRadius = 5.0
        
        sleepSlider.setThumbImage(UIImage(named: "MetalButton.png"), for: UIControlState.normal)
        mindSlider.setThumbImage(UIImage(named: "MetalButton.png"), for: UIControlState.normal)
        wellnessSlider.setThumbImage(UIImage(named: "MetalButton.png"), for: UIControlState.normal)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
