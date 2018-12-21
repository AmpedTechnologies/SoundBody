//
//  ProfileViewController.swift
//  Amped
//
//  Created by Gregg Weaver on 10/18/17.
//  Copyright © 2017 Amped. All rights reserved.
//



import UIKit
import Firebase
import MessageUI

class ProfileViewController: UIViewController, MFMailComposeViewControllerDelegate {

    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var orgName: String!

    @IBOutlet weak var recLockerImage: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nameOut: UILabel!
    @IBOutlet weak var profOut: UILabel!
    @IBOutlet weak var demo: UILabel!
    @IBOutlet weak var sessionNumOut: UILabel!
    @IBOutlet weak var dobOut: UILabel!
    @IBOutlet weak var emailOut: UILabel!
    @IBOutlet weak var lockerIcon: UIImageView!
    
    var edit = false
    var sizeW = UIScreen.main.bounds.width
    var savedPhoto: UIImage!
    var name = " "
    var age = 0
    var profession = " "
    
    // Send feedback button
    @IBAction func sendFeedbackButton(_ sender: Any) {
        sendEmail()
    }
    
    // Change password button action
    @IBAction func changePassword(_ sender: Any) {
         performSegue(withIdentifier: "changePassword", sender: self)
    }
    
    
    //Send email feedback function
    func sendEmail(){
        if MFMailComposeViewController.canSendMail(){
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("RVIVE FeedBack")
            mail.setMessageBody("", isHTML: true)
            mail.setToRecipients(["information@ampedtechnologies.com"])
            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    //Setup mail composer to deal with errors and completion
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print(result.rawValue)
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    // Recovery locker action - CURRENTLY HIDDEN
    @IBAction func recoveryLockerButton(_ sender: Any) {
        performSegue(withIdentifier: "recoveryLocker", sender: self)
        
    }
    
    // Goals button action - CURRENTLY HIDDEN
    @IBAction func goalsButton(_ sender: Any) {
        performSegue(withIdentifier: "goals", sender: self)
    }
    
    // Notification action - CURRENTLY HIDDEN
    @IBAction func notificationButton(_ sender: Any) {
        performSegue(withIdentifier: "aboutUs", sender: self)
    }
    
    
    // Exit button Actions
    @IBOutlet weak var exitButton: UIButton!
    @IBAction func exitButton(_ sender: Any) {
        UserDefaults.standard.set(profOut.text, forKey: "prof")
        UserDefaults.standard.set(nameOut.text, forKey: "name")
        app.scores.setValue(nameOut.text, forKey: "name")
        performSegue(withIdentifier: "menu", sender: self)
    }
    
    // Get user details from the database
    func getUserDetails(company: String, completionHandler:@escaping (_ status: String)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() == true {
                let firstname = snapshot.childSnapshot(forPath: "first name").value as? String
                let lastname = snapshot.childSnapshot(forPath: "last name").value as? String
                self.nameOut.text = (firstname! + " " + lastname!)
                self.profOut.text = snapshot.childSnapshot(forPath: "profession").value as? String
            }
                else {
                    completionHandler("")
                    return
            }
            completionHandler("IT WORKED")
            
        })
    }
    
    // Load information to profile page
    func loadData(){
        Functions.setSessionInformation(company: orgName, sessionType: "numberOfSessions") { (result) in
            self.sessionNumOut.text = String(result)
        }
        getUserDetails(company: orgName) { (result) in
            print(result)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        // Setup variable with the bundle version and output to screen
        var ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.versionLabel.text = "Ver. " + ver!
    
        //UI Setup
        self.exitButton.setTitleColor(.white, for: .normal)
        self.exitButton.layer.borderWidth = 2
        self.exitButton.layer.borderColor = UIColor.white.cgColor
        self.exitButton.layer.cornerRadius = 5.0
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "backBackground.png")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        // Load data from database
        loadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
