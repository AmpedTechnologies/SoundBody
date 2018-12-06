//
//  PremiumSignUp.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/27/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

class PremiumSignUp: UIViewController {
    
    var ref: DatabaseReference!

    @IBOutlet weak var freeVersionButton: UIButton!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var lifetimeView: UIView!
    @IBOutlet weak var subscriptionNotice: UITextView!
    
    var newUser: String!
    var orgLogin: Bool!
    var memberType = ""
    let demoAlert = UIAlertController(title: "Congratulations", message: "", preferredStyle: .alert)
    
    
    @IBAction func freeButton(_ sender: Any) {
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    
    @objc func monthButton(_ sender: UITapGestureRecognizer){
        memberType = "Monthly"
        print("Monthly membership")
        premiumConfirm()
    }
    
    @objc func yearButton(){
        memberType = "Yearly"
        print("yearly membership")
        premiumConfirm()
        
    }
    
    @objc func lifetimeButton(){
        memberType = "Lifetime"
        print("Lifetime membership")
        premiumConfirm()
    }
    
    func premiumConfirm(){
        demoAlert.message = "You have signed up for the \(memberType) membership"
        self.present(demoAlert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        let monthTap = UITapGestureRecognizer(target: self, action: #selector(PremiumSignUp.monthButton(_:)))
        monthView.addGestureRecognizer(monthTap)
        monthView.isUserInteractionEnabled = true
      
        let yearTap = UITapGestureRecognizer(target: self, action: #selector(PremiumSignUp.yearButton))
        yearView.addGestureRecognizer(yearTap)
        yearView.isUserInteractionEnabled = true
        
        let lifetimeTap = UITapGestureRecognizer(target: self, action: #selector(PremiumSignUp.lifetimeButton))
        lifetimeView.addGestureRecognizer(lifetimeTap)
        lifetimeView.isUserInteractionEnabled = true
        
        monthView.layer.cornerRadius = 6.0
        monthView.layer.masksToBounds = true
        yearView.layer.cornerRadius = 6.0
        yearView.layer.masksToBounds = true
        lifetimeView.layer.cornerRadius = 6.0
        lifetimeView.layer.masksToBounds = true
        
        demoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (result) in
            self.updateUserMembership()
            self.performSegue(withIdentifier: "toLogin", sender: self)
        }))
        
        // Setup Subscription Notice textView
        let terms = NSMutableAttributedString(string: "Terms and Conditions")
        terms.addAttribute(.link, value: "http://ampedtechnologies.com/ampedrxtermsconditions", range: NSRange(location: 0, length: 20))
        
    
        let privacyPolicy = NSMutableAttributedString(string: " and Privacy Policy.")
        
        
        privacyPolicy.addAttribute(.link, value: "http://www.ampedtechnologies.com/ampedrxprivacyPolicy", range: NSRange(location: 5, length: 14))
        
        let subNotice = NSMutableAttributedString(string: "Subscription Terms: All subscriptions are automatically renewed unless turned off in Account Settings at least 24h before current period ends. Payment is charged through your iTunes account.")
        
        subNotice.append(terms)
        subNotice.append(privacyPolicy)
        
        //UI setp for TextView
        subscriptionNotice.attributedText = subNotice
        subscriptionNotice.font = UIFont(name: (subscriptionNotice.font?.fontName)!, size: 10)
        subscriptionNotice.textColor = UIColor.white
        subscriptionNotice.textAlignment = .center

    }
    

    func updateUserMembership(){
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        self.ref.child("individual").child(userID).child("userDetails").updateChildValues(["Membership Type" : memberType, "Membership Status" : "Premium"])
    }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let Login = segue.destination as? Login {
            Login.newUser = newUser
            Login.orgLogin = orgLogin
        }
        
    }
}
