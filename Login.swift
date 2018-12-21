//
//  Login.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/20/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import HealthKit
import Firebase
import KeychainSwift
import LocalAuthentication
import Kingfisher
import CryptoSwift
import SwiftyStoreKit
import JGProgressHUD

//Extension to add tap gesture to dismiss keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


class Login: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var orgNameIn: UITextField!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var passOut: UILabel!
    @IBOutlet weak var resetLabelOut: UILabel!
    @IBOutlet weak var resetPassword: UIButton!
    
    let alert = UIAlertController(title: "Do You want to use TOUCH ID to login?", message: "", preferredStyle: .alert)
    //let passwordAlert = UIAlertController(title: "Do You want to save your password?", message: "", preferredStyle: .alert)
    
    let keychain = KeychainSwift()
    let healthKitStore = HKHealthStore()
    let UD = UserDefaults.standard
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    
    var email: String?
    var company: String?
    var password: String?
    var orgLogin: Bool!
    var orgName: String!
    var newUser: String!
    
    
    // Check is authorization details are correct.
    func AuthUser(uName: String, pWord: String){
        
        
        Auth.auth().signIn(withEmail: uName, password: pWord) { (user, error) in
            
            if let error = error {
                self.passOut.text = "email/password is Incorrect"
                return
            }
            
            // If no error occured check is the company exists
            Functions.checkCompany(company: self.orgName, completionHandler: { (result) in
                if result == true {
                    let hud = JGProgressHUD()
                    hud.textLabel.text = "SIGNING IN"
                    hud.show(in: self.view)
                    hud.dismiss(afterDelay: 6.0)
                    
                    self.app.scores.setValue(self.userName.text, forKey: "username")
                    //Check to see if there is a password stored in Keychain if not store the entered password
                    if self.keychain.get("password") == nil {
                        let pass = self.passWord.text?.sha256()
                        self.keychain.set(self.passWord.text!, forKey: "password")
                    }
                    self.app.scores.setValue(self.orgName, forKey: "organization")
                    //Check to see if the setup has been completed by the user if so send to menu page if not send to setup page
                    Functions.checkForSetup(company: self.orgName, completionHandler: { (result) in
                        if result == true {
                            self.performSegue(withIdentifier: "toMenu", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "setup", sender: self)
                        }
                    })
                    
                } else {
                    // Output to screen if no company exists
                    self.passOut.text = "NO ACCOUNT FOUND"
                }
            })
        }
    }
    
    //Login Button Action
    @IBAction func loginSubmit(_ sender: Any) {
        
        // Assign inputs
        email = self.userName.text
        //Check which type of login is being sent - individual or Organization
        if self.orgLogin == false {
            self.orgName = "individual"
        }else {
            self.orgName = orgNameIn.text
        }
        
        // If password exists run Auth function
        if let password = self.passWord.text
        {
            
            AuthUser(uName: email!, pWord: password)
        } else {
            passOut.text = "email/password is Incorrect"
        }
    }
    
    
    // Setup permission with Health kit
    func getHealthKitPermission() {
        if #available(iOS 11.0, *) {
            let healthkitTypesToRead = NSSet(array: [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN) ?? "",
                HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) ?? "",
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) ?? "",
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) ?? "",
                
                ])
            let healthkitTypesToWrite = NSSet(array: [
                HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession) ?? "",
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) ?? ""
                ])
            
            healthKitStore.requestAuthorization(toShare: healthkitTypesToWrite as? Set, read: healthkitTypesToRead as? Set) { (success, error) in
                if success {
                    print("Permission accept.")
                    
                } else {
                    if error != nil {
                        print(error ?? "")
                    }
                    print("Permission denied.")
                }
            }
        } else {
            
        }
        
    }
    
    // Read in HRV from apple health
    func readHRV(){
        if #available(iOS 11.0, *) {
            if let HRV = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN) {
                
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                let query = HKSampleQuery(sampleType: HRV, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, results, error) -> Void in
                    if let result = results {
                        for item in result {
                            if let sample = item as? HKCategorySample {
                                let value = (sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue) ? "InBed" : "Asleep"
                            }
                        }
                    }
                    self.healthKitStore.execute(query)
                }
            }
        }
    }
    
    // Setup Touch ID
    func evaulateTocuhIdAuthenticity(context: LAContext) {
        guard let lastAccessedUserName = (app.scores.value(forKey: "username") as? String) else { return }
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: lastAccessedUserName) { (authSuccessful, authError) in
            if authSuccessful {
                self.completeTouchIdLogin(username: lastAccessedUserName)
            } else {
                if let error = authError as? LAError {
                    
                }
            }
        }
    }
    
    //Function for completing touch ID login
    func completeTouchIdLogin(username: String){
        guard !username.isEmpty else { return }
        let passwordItem = self.keychain.get("password")
        do {
            let storedPassword = try passwordItem
            if self.orgLogin == false {
                self.orgName = "individual"
            }else {
                DispatchQueue.main.async {
                    self.orgName = self.orgNameIn.text
                }
            }
            
            AuthUser(uName: username, pWord: storedPassword!)
            
        }
    }
    
    //
    @IBAction func emailEntered(_ sender: Any) {
        resetLabelOut.isHidden = true
    }
    
    // Forgotton Password Button Action
    @IBAction func resetPassword(_ sender: Any) {
        if email == nil {
            self.resetLabelOut.text = "Please enter your email address above and click forgot password again to recieve a reset email"
            self.resetLabelOut.isHidden = false
        } else {
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                self.resetLabelOut.text = "Reset password email sent"
                self.resetLabelOut.isHidden = false
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as? String
        
        // Setup hiding the keyboard on screen tap
        self.hideKeyboardWhenTappedAround()
        
        
        // What to do if individual login
        if orgLogin == false {
            orgLabel.isHidden = true
            orgNameIn.isHidden = true
            if keychain.get("password") != nil {
                authenticateUserUsingTouchID()
            }
        }else {
            
            if orgName != nil  {
                if orgName == "individual" {
                    orgNameIn.text = " "
                } else {
                    orgNameIn.text = orgName
                    authenticateUserUsingTouchID()
                }
            }
            
        }
        // if there is an email saved in UserDefaults set that to email text field
        if newUser != nil {
            userName.text = newUser!
        }else {
        if (app.scores.value(forKey: "username")) != nil {
            email = (app.scores.value(forKey: "username") as? String)
            self.userName.text = email!
        } 
        }
        
        //alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in}))
        //alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        
        
        
        //UI Setup
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 2.0
        loginButton.layer.cornerRadius = 5.0
        backButton.layer.cornerRadius = backButton.frame.size.width / 2
        backButton.layer.borderColor = UIColor.green.cgColor
        backButton.layer.borderWidth = 1.0
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        getHealthKitPermission()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // Authorize the user by touch ID
    fileprivate func authenticateUserUsingTouchID(){
        let context = LAContext()
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) {
            self.evaulateTocuhIdAuthenticity(context: context)
        }
    }
    
    
}
