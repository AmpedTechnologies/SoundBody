//
//  NewUserSignUp.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/23/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SafariServices

class NewUserSignUp: UIViewController, SFSafariViewControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passOne: UITextField!
    @IBOutlet weak var passTwo: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    //@IBOutlet weak var signUpNotice: UILabel!
    @IBOutlet weak var signUpNotice: UITextView!
    
    
    
    
    
    var pass: String!
    var emailIn: String!
    var ref: DatabaseReference!
    let dateFormat = DateFormatter()
    
    //Setup tap recognizer
    let tap = UITapGestureRecognizer(target: self, action: #selector(NewUserSignUp.dismissKey))
    
    // Setup predicate for password test - upper case, lower case, number, and special char
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d$@$#!%*?&]{8,}")
    
    //Alerts Setup
    let passAlert = UIAlertController(title: "Invalid Password", message: "Your password needs to be a minimum of 8 characters long and contain atleast: \r\rOne upper case letter \rOne lower case letter \rOne special character \rOne number", preferredStyle: .alert)
    let passMatchAlert = UIAlertController(title: "Passwords do not match", message: "", preferredStyle: .alert)
    let emailInvalidAlert = UIAlertController(title: "Please enter a valid email address", message: " ", preferredStyle: .alert)
    let signUpAlert = UIAlertController(title: "Would you like to unlock the premium programs", message: " 100s of personalized recovery programs at your fingertips", preferredStyle: .alert)
    let accountAlert = UIAlertController(title: "Account already Exists", message: "Have you forgotten your password?", preferredStyle: .alert)
    let resetAlert = UIAlertController(title: "Reset password has been sent", message: " ", preferredStyle: .alert)
    
    
    //Function to deal with dismiss keyboard on screen tap
    @objc func dismissKey(){
        view.endEditing(true)
    }
    
    //Join now button action
    @IBAction func joinButton(_ sender: Any) {
        //Set date
        let completeDate = dateFormat.string(from: Date())
        pass = passOne.text!
        emailIn = email.text!
        //Check to see if email address is already assigned an account
        Auth.auth().fetchProviders(forEmail: emailIn, completion: {
            (account, error) in
            
            if let account = account {
                print(account)
                self.present(self.accountAlert, animated: true)
            } else {
                print("Email doesnt exist")
            
        // Check to see if all constraints are being met - passwords match, contains neccessary pieces, and is an email address
        if  self.passOne.text! == self.passTwo.text! && self.passwordTest.evaluate(with: self.pass) && self.emailIn.contains("@"){
            print("Account has been setup")
            
                // Create user on database
                Auth.auth().createUser(withEmail: self.emailIn, password: self.pass!) { (user, error) in
                    //Find users unique ID and add to database with setupDate and membership status
                    let userID = user!.user.uid
                    self.ref.child("individual").child(userID).child("userDetails").setValue(["setupDate" : completeDate, "Membership Status" : "Free"])
            }
            self.present(self.signUpAlert, animated: true)
            
        }else {
            //If email doesnt contain @ symbol
            if !self.emailIn.contains("@") {
                self.present(self.emailInvalidAlert, animated: true)
                //If passwords do not match
            } else if self.passOne.text != self.passTwo.text! {
                self.present(self.passMatchAlert, animated: true)
                //If password doesnt contain necessary chars
            }else if self.passwordTest.evaluate(with: self.pass) == false {
                self.present(self.passAlert, animated: true)
            }
        }
            }
        })
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        signUpNotice.delegate = self
        
        // Add tap gesture to view
        view.addGestureRecognizer(tap)
        
        // UI Setup
        joinButton.layer.borderColor = UIColor.white.cgColor
        joinButton.layer.borderWidth = 2.0
        joinButton.layer.cornerRadius = 5.0
        
        // Date format setup
        dateFormat.dateFormat =  "MMM d,yyyy h:mm:ss a"
        
        //Alert Action Setup
        passAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        passMatchAlert.addAction((UIAlertAction(title: "OK", style: .cancel, handler: nil)))
        emailInvalidAlert.addAction((UIAlertAction(title: "OK", style: .cancel, handler: nil)))
        
        signUpAlert.addAction(UIAlertAction(title: "Not right now", style: .default, handler: { (result) in
            self.performSegue(withIdentifier: "signedUp", sender: self)
        }))
        signUpAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (result) in
            self.performSegue(withIdentifier: "memberOptions", sender: self)
        }))
        
        accountAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (result) in
            self.resetPass()
            print("Send forgotten password email")}))
        
        accountAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        resetAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (result) in
                self.email.text = ""
                self.passOne.text = ""
                self.passTwo.text = ""
        }))
        
        //Setup the signUpNotice text in the textView
        let termLink = NSMutableAttributedString(string: "Terms and Conditions")
        termLink.addAttribute(.link, value: "http://ampedtechnologies.com/termsconditions", range:  NSRange(location: 0, length: 20))
        
        let privacyLink = NSMutableAttributedString(string: " and Privacy Policy for RVIVE")
        privacyLink.addAttribute(.link, value: "http://www.ampedtechnologies.com/privacyPolicy", range: NSRange(location: 4, length: 15))
        
        let statement = NSMutableAttributedString(string: "By creating an account you are agreeing to the ")
        statement.append(termLink)
        statement.append(privacyLink)
    
        signUpNotice.attributedText = statement
        signUpNotice.textColor = UIColor.white
        signUpNotice.textAlignment = .center
    }
    
    /*
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        self.present(safariVC, animated: true)
        return false
    }
    */
    func resetPass(){
        Auth.auth().sendPasswordReset(withEmail: email.text!) { (error) in
            print(error)
            self.present(self.resetAlert, animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let Login = segue.destination as? Login {
            Login.newUser = emailIn
            Login.orgLogin = false
        }
        
        if let PremiumSignUp = segue.destination as? PremiumSignUp {
            PremiumSignUp.newUser = emailIn
            PremiumSignUp.orgLogin = false
        }
        // Pass the selected object to the new view controller.
    }
 

}
