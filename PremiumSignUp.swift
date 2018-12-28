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
import SwiftyStoreKit

class PremiumSignUp: UIViewController {
    
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    var sharedSecret = "09a57095c7b04a9cb298c41d00815358"
    var monthly = "RVIVE.sub.allaccessmonthly"
    var yearly = "RVIVE.sub.allaccessyearly"

    @IBOutlet weak var freeVersionButton: UIButton!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var yearView: UIView!
    //@IBOutlet weak var lifetimeView: UIView!
    @IBOutlet weak var subscriptionNotice: UITextView!
    
    var newUser: String!
    var orgLogin: Bool!
    var memberType = ""
    let demoAlert = UIAlertController(title: "Congratulations", message: "", preferredStyle: .alert)
    var orgName: String!
    
    @IBAction func freeButton(_ sender: Any) {
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    
    @objc func monthButton(_ sender: UITapGestureRecognizer){
        memberType = "Monthly"
        print("Monthly membership")
        purchaseSub(id: monthly, sharedSecret: sharedSecret) { (result) in
            
        }
    }
    
    @objc func yearButton(){
        memberType = "Yearly"
        print("yearly membership")
        purchaseSub(id: yearly, sharedSecret: sharedSecret) { (result) in
            //self.premiumConfirm()
        }
       
        
        
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
        orgName = app.scores.value(forKey: "organization") as! String
        let monthTap = UITapGestureRecognizer(target: self, action: #selector(PremiumSignUp.monthButton(_:)))
        monthView.addGestureRecognizer(monthTap)
        monthView.isUserInteractionEnabled = true
      
        let yearTap = UITapGestureRecognizer(target: self, action: #selector(PremiumSignUp.yearButton))
        yearView.addGestureRecognizer(yearTap)
        yearView.isUserInteractionEnabled = true
        
        //let lifetimeTap = UITapGestureRecognizer(target: self, action: #selector(PremiumSignUp.lifetimeButton))
        //lifetimeView.addGestureRecognizer(lifetimeTap)
        //lifetimeView.isUserInteractionEnabled = true
        
        monthView.layer.cornerRadius = 6.0
        monthView.layer.masksToBounds = true
        yearView.layer.cornerRadius = 6.0
        yearView.layer.masksToBounds = true
       // lifetimeView.layer.cornerRadius = 6.0
        //lifetimeView.layer.masksToBounds = true
        
        demoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (result) in
            self.updateUserMembership(company: self.orgName, premium: true)
            self.performSegue(withIdentifier: "toLogin", sender: self)
        }))
        
        // Setup Subscription Notice textView
        let terms = NSMutableAttributedString(string: "Terms and Conditions")
        terms.addAttribute(.link, value: "http://ampedtechnologies.com/termsconditions", range: NSRange(location: 0, length: 20))
        
    
        let privacyPolicy = NSMutableAttributedString(string: " and Privacy Policy.")
        
        
        privacyPolicy.addAttribute(.link, value: "http://www.ampedtechnologies.com/privacyPolicy", range: NSRange(location: 5, length: 14))
        
        let subNotice = NSMutableAttributedString(string: "Subscription Terms: RVIVE monthly subscription is $5.99. RVIVE yearly subscription is $49.99. All subscriptions are automatically renewed unless turned off in Account Settings at least 24h before current period ends. Payment is charged through your iTunes account. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription.")
        
        subNotice.append(terms)
        subNotice.append(privacyPolicy)
        
        //UI setp for TextView
        subscriptionNotice.attributedText = subNotice
        subscriptionNotice.font = UIFont(name: (subscriptionNotice.font?.fontName)!, size: 10)
        subscriptionNotice.textColor = UIColor.white
        subscriptionNotice.textAlignment = .center

    }
    

    func updateUserMembership(company: String, premium: Bool){
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        self.ref.child(company).child(userID).child("userDetails").updateChildValues(["Membership Type" : memberType, "Premium Membership" : premium])
    }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let Login = segue.destination as? Login {
            Login.newUser = newUser
            Login.orgLogin = orgLogin
        }
        
    }
    
    //In - app purchase
    func purchaseSub(id: String, sharedSecret: String, complete: @escaping (Bool) -> Void){
        
        SwiftyStoreKit.purchaseProduct(id, atomically: true) { result in
            
            if case .success(let purchase) = result {
                self.updateUserMembership(company: self.orgName, premium: true)
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.premiumConfirm()
                //self.verifySubscription(id: id, sharedSecret: sharedSecret)
                
                
            } else {
                // purchase error
            }
        }
        
        complete (true)
    }
    /*
    
    func verifySubscription(id: String, sharedSecret: String){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = id
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    
                    //
                    if self.app.existingUser == true {
                        self.performSegue(withIdentifier: "back", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "setupProfile", sender: self)
                    }
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    */
}
