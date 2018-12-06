//
//  SetupAccountViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 5/23/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseMessaging

class SetupAccountViewController: UIViewController {
    
    // Setup initial alert
    let alert = UIAlertController(title: "We know your Excited!", message: "Before you can get Amped your need to complete the setup of your Profile and Wellness locker", preferredStyle: .alert)

    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var ud = UserDefaults.standard
    
    var orgName: String!
    var Name: String!
    var Profession: String!
    var Age: Int!
    var Height: Double!
    var Weight: Double!
    var Residence: String!
    var setup = true
    var profile = false
    var goals = false
    var locker = false
    var sleepScore: Int?
    var sleepGoal: Int?
    var mindScore: Int?
    
    @IBOutlet weak var privacyPolicy: UIButton!
    @IBOutlet weak var setupProfile: UIButton!
    @IBOutlet weak var setupLocker: UIButton!
    @IBOutlet weak var getAmped: UIButton!
    
    // Action for privacy policy button - take user to privcy policy page
    @IBAction func privacyPolicyButton(_ sender: Any) {
        performSegue(withIdentifier: "privacy", sender: self)
    }
    
    // Take user to profile setup page
    @IBAction func setupProfileButton(_ sender: Any) {
        profile = true
        // set UserDefault to true
        ud.setValue(profile, forKey: "profileComplete")
        performSegue(withIdentifier: "setupProfile", sender: self)
    }
    
    // Take user to recovery locker screen so they can setup their locker equip
    @IBAction func setupLockerButton(_ sender: Any) {
        locker = true
        // set UserDefault to true
        ud.setValue(locker, forKey: "lockerComplete")
        performSegue(withIdentifier: "setupLocker", sender: self)
    }
    
    // Finalize setup button - check to see if all the necessary peices have been completed.
    @IBAction func getAmpedButton(_ sender: Any) {
        guard let l = ud.value(forKey: "lockerComplete") as? Bool else { return }
        guard let p = ud.value(forKey: "profileComplete") as? Bool else { return }
        
        // Check to see if all buttons have been selected and completed.
        if l == true && p == true && privacyPolicy.layer.backgroundColor != UIColor.clear.cgColor {
            loadData()
        performSegue(withIdentifier: "firstSession", sender: self)
        } else {
            self.present(alert, animated: true)
        }
    }
    
    //Setup the users sleep score on the database
    func loadData(){
        Functions.setScoreInformation(company: orgName, sessionType: "sleepScore") { (result) in
            self.sleepScore = result
            self.app.scores.setValue(self.sleepScore, forKey: "sleepScoreTotal")
        }
    }
    
    /* Function to add sleep score variable to databasw
    func setScoreInformation(company: String, sessionType: String, completionHandler:@escaping (_ status: Int)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        ref.child(company).child(userID).child("Scores").observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let result = snapshot.childSnapshot(forPath: sessionType).value as? Int
                else {
                    completionHandler(0)
                    return
            }
            completionHandler(result)
            
        })
    }*/
   
    // Function to deal with button UI
    func setupCompleteButton(buttonName: UIButton){
        buttonName.layer.borderColor = UIColor.clear.cgColor
        buttonName.layer.borderWidth = 2.0
        buttonName.backgroundColor = UIColor(red: 45/255, green: 110/255, blue: 39/255, alpha: 1)
        buttonName.layer.cornerRadius = 5.0
    }
    
    func setupButtonLayout(button: UIButton){
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.cornerRadius = 5.0
    }
    
    
    
    func buttonState(name: String, buttonName: UIButton){
        if (ud.value(forKey: name)) != nil {
            if (ud.value(forKey: name)) as! Bool == true {
                setupCompleteButton(buttonName: buttonName)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Functions.getPrivacyInfo(company: orgName) { (result) in
            if result == true {
                self.setupCompleteButton(buttonName: self.privacyPolicy)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        // Subscripte user to push notification based on their organization name
        Messaging.messaging().subscribe(toTopic: orgName)
        
        // Setup alert actions
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        //Setup UI
        setupButtonLayout(button: privacyPolicy)
        setupButtonLayout(button: setupProfile)
        setupButtonLayout(button: setupLocker)
        setupButtonLayout(button: getAmped)
        buttonState(name: "profileComplete", buttonName: setupProfile)
        buttonState(name: "lockerComplete", buttonName: setupLocker)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Segue setup for information transfer between storyboards
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let GoalSettingsViewController = segue.destination as? GoalSettingsViewController {
            GoalSettingsViewController.setup = setup;
        }
        if let LockerViewController = segue.destination as? LockerViewController {
            LockerViewController.setup = setup;
        }
    }
    
    
    

}
