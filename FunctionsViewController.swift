//
//  FunctionsViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/15/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import HealthKit

class Functions {

    static let ref = Database.database().reference()
    static let userID: String = (Auth.auth().currentUser?.uid)!
    static let dateFormat = DateFormatter()
    static let healthStore = HKHealthStore()
    static let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)
    
        class func setScoreInformation(company: String, sessionType: String, completionHandler:@escaping (_ status: Int)-> Void) {
        
                ref.child(company).child(userID).child("Scores").observeSingleEvent(of: .value, with: { (snapshot) in
                        guard
                            let result = snapshot.childSnapshot(forPath: sessionType).value as? Int
                            else {
                                completionHandler(0)
                                return
                    }
                    completionHandler(result)
                })
        }

        // Function to check on the status of the users privacy policy
        class func getPrivacyInfo(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
            
            ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
                guard
                    let result = snapshot.childSnapshot(forPath: "Privacy Policy Agreement").value as? Bool
                    else {
                        completionHandler(false)
                        return
                    }
                completionHandler(result)
            })
    }
    
    // Function to check on the status of the users privacy policy
    class func getMembershipInfo(company: String, completionHandler:@escaping (_ status: String)-> Void) {
        
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let result = snapshot.childSnapshot(forPath: "Membership Status").value as? String
                else {
                    completionHandler("Free")
                    return
            }
            completionHandler(result)
        })
    }

    // Update pathway information on database
    class func updatePathwayInfo(company: String, program: String, prog: String, pathway: String, stus: String!, time: String, timeCompleted: Int) {
        
        dateFormat.dateFormat =  "MMM d,yyyy h:mm:ss a"
        let sessionDate = dateFormat.string(from: Date())
        ref.child(company).child(userID).child("Scores").child("Sessions").child(sessionDate).updateChildValues(["Program" : program, "Prog Type" : prog, "Pathway" : pathway, "Status": stus, "Time" : time, "Time Completed" : timeCompleted])
    }
    
    class // Function to send information to database
        func updateDailyCheckin(company: String, mind: Int, body: Int){
        //let userID: String = (Auth.auth().currentUser?.uid)!
        dateFormat.dateFormat =  "MMM d,yyyy h:mm:ss a"
        let reportDate = dateFormat.string(from: Date())
        
        ref.child(company).child(userID).child("Scores").child("Self Reports").child(reportDate).updateChildValues([
            "Mind" : mind, "Body" : body])
        
    }
    
    //Function to check on the recommendation status of the user
    class func getRecStatus(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        let state = false
        ref.child(company).child(userID).child("Scores").observeSingleEvent(of: .value) { (Snapshot) in
            guard
                let state = Snapshot.childSnapshot(forPath: "Amped Recommendation").value as? Bool else { return }
            completionHandler(state)
        }
    }
    
    class func updateRec(company: String, status: Bool){
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child(company).child(userID).child("Scores").updateChildValues([
            "Amped Recommendation" : status])
    }
    
    
    //Send mindfulness info to apple health
    class func saveMindMin(startTime: Date, endTime: Date){
        print("Save Mind Min data")
        let mindSample = HKCategorySample(type: mindfulType!, value: 0, start: startTime, end: endTime)
        
        healthStore.save(mindSample, withCompletion: { (success, error) -> Void in
            if error != nil { return }
            
            print("New Data sent to apple health \(success)")
        })
        
    }
    
    class func getUserGoals(company: String, detail: String, completionHandler:@escaping (_ status: Int)-> Void) {
        ref.child(company).child(userID).child("userDetails").child("goals").observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let result = snapshot.childSnapshot(forPath: detail).value as? Int
                else {
                    completionHandler(0)
                    return
            }
            completionHandler(result)
            
        })
    }
    
    class func updateData(company: String, area: String, count: Int) {
        ref.child(company).child(userID).child("Scores").updateChildValues([area : count])
    }
    
    class func checkCompany(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        var member: Bool!
        ref.child(company).child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                member = true
            } else {
                member = false
            }
            completionHandler(member)
        }
    }
    
    class func checkForSetup(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        var setupComp: Bool!
        ref.child(company).child(userID).child("userDetails").child("Setup Complete Date").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                setupComp = true
            } else {
                setupComp = false
            }
            completionHandler(setupComp)
        }
    }
    
    class func updateUserInfo(company: String) {
        
        dateFormat.dateFormat =  "MMM d,yyyy h:mm:ss a"
        let completeDate = dateFormat.string(from: Date())
        
        ref.child(company).child(userID).child("userDetails").updateChildValues(["Setup Complete Date" : completeDate])
    }
    
    /*
    class func checkForSetup(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        var firstSession: Bool!
        ref.child(company).child(userID).child("Scores").child("Sessions").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                print("YES")
                firstSession = false
            } else {
                firstSession = true
            }
            completionHandler(firstSession)
        }
    } */
    
    class func setSessionInformation(company: String, sessionType: String, completionHandler:@escaping (_ status: Int)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        var result = 0
        ref.child(company).child(userID).child("Scores").child("Sessions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snapshots = snapshot.children.allObjects as! [DataSnapshot]
            for snap in snapshots {
                print(snap.key)
                result = result + 1
            }
            
            print(result)
            completionHandler(result)
            
        })
    }
    
    class func updateGoal(company: String, area: String, count: Int) {
        
        ref.child(company).child(userID).child("userDetails").child("goals").updateChildValues([area : count])
        
    }

}

class FunctionsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    

}
