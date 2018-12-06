//
//  TermsViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 6/4/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase

class TermsViewController: UIViewController {
    
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    var orgName: String!
    var agree = false
    @IBOutlet weak var agreeSwitch: UISwitch!
    @IBOutlet weak var exitButton: UIButton!
    
    //Exit button Action
    @IBAction func exitButton(_ sender: Any) {
        //Check the switch to ensure it has been clicked.
        if agreeSwitch.isOn == true{
            agree = true
        } else if agreeSwitch.isOn == false {
            agree = false
        }
        // Send updated switch status to database
        updatePrivacyPolicy(company: orgName, state: agree)
        performSegue(withIdentifier: "privacyReturn", sender: self)
        
    }
    
    // Function to update the database with latest switch state
    func updatePrivacyPolicy(company: String, state: Bool){
        let userId: String = (Auth.auth().currentUser?.uid)!
        ref.child(company).child(userId).child("userDetails").updateChildValues(["Privacy Policy Agreement" : state])
    }
    
    // Button action to send user to Amped Tech privacy policy on website.
    @IBAction func privacyPolicyButtonAction(_ sender: Any) {
        if let url = URL(string: "www.ampedtechnologies.com/AmpedRxPrivacyPolicy"){
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgName = app.scores.value(forKey: "organization") as! String
        ref = Database.database().reference()
        
        //UI Setup
        privacyPolicyButton.layer.borderColor = UIColor.white.cgColor
        privacyPolicyButton.layer.borderWidth = 2.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    

}
