//
//  ChangePasswordViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 6/12/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import Lightbox
import KeychainSwift

extension ChangePasswordViewController: LightboxControllerPageDelegate {
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        print(page)
    }
}

class ChangePasswordViewController: UIViewController {

    
    @IBOutlet weak var videoOut: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var newPassOne: UITextField!
    @IBOutlet weak var newPassTwo: UITextField!
    @IBOutlet weak var warningOut: UILabel!
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    var checkString: String!
    var email: String!
    let keychain = KeychainSwift()
    var count = 0
    
    //Setup passOne action
    @IBAction func passOne(_ sender: Any) {
        warningOut.isHidden = true
    }
    
    // Setup the submit button action
    @IBAction func submit(_ sender: Any) {
        warningOut.isHidden = false
        //Check to make sure passwords are the same
        if newPassOne.text == newPassTwo.text {
            checkString = newPassOne.text
            // Ensure password is more than 8 characters long
            if checkString.count < 8 {
                warningOut.text = "Your password needs to be atleast 8 characters"
            } else {
                //If all conditions are true send changed password to database
                Auth.auth().currentUser?.updatePassword(to: checkString) { (error) in
                    self.keychain.set(self.checkString, forKey: "password")
                    self.warningOut.text = "Your password has been changed"
                }
            }
        } else {
            warningOut.text = "Your passwords did not match"
        }
    }
    
    // Action for back button
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        
        email = (app.scores.value(forKey: "username") as? String)
        
        //UI Setup
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.borderWidth = 2.0
        submitButton.layer.cornerRadius = 5.0
        
        backButton.layer.cornerRadius = backButton.frame.size.width / 2
        backButton.layer.borderColor = UIColor.green.cgColor
        backButton.layer.borderWidth = 1.0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
