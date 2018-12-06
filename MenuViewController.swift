//
//  MenuViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 4/26/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import HealthKit

class chall{
    var title: String!
    var badge: String!
    
    init(title: String, badge: String){
        self.title = title
        self.badge = badge
    }
}

class MenuViewController: UIViewController {

    // Setup Varibale used
    let healthKitStore = HKHealthStore()
    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    
    
    var lockerEquipment: [String] = []
    var orgName: String!
    let dateFormat = DateFormatter()
    let today = Date()
    var sessionDate: String!
    var path: String!
    var totalSessions: Int?
    var timeOut = ""
    var minimum: Bool!
    var t = 0
    var sessionSelected = ""
    var locker = "AtHome"
    var sessionCount = 0
    var fullProgCount = 0
    var mindProgCount = 0
    var sleepScore: Int?
    var sleepGoal: Int?
    var mindScore: Int?
    
    @IBOutlet weak var leadingCon: NSLayoutConstraint!
    @IBOutlet weak var trailCon: NSLayoutConstraint!
    
    
    // Main Screen Buttons
    @IBOutlet weak var rxButton: UIButton!
    @IBOutlet weak var nationButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var pathwayView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    
    // Show side bar menu
    var menuClicked = false
    var menuHidden = true
        @objc func menuButton(sender: UIButton){
        if menuClicked == false {
        menuHidden = false
        leadingCon.constant = 250
        trailCon.constant = -250
        menuClicked = true
        } else {
            menuView.isHidden = true
            menuHidden = true
            leadingCon.constant = 0
            trailCon.constant = 0
            menuClicked = false
        }
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0.0, options: .calculationModeLinear, animations: {
            self.view.layoutIfNeeded()
        }) { (result) in
            if self.menuHidden == false {
                self.menuView.isHidden = false
                
            }
            print("Animated")
        }
    }
    
    // Button Setup
    func setButton(name: UIButton){
        name.layer.borderWidth = 2.0
        name.layer.borderColor = UIColor.white.cgColor
        name.layer.cornerRadius = 5.0
        name.layer.masksToBounds = true
    }
    
    // Setup and action for Mindset button
    @IBOutlet weak var mindfulness: UIButton!
    @IBAction func midfullnessButton(_ sender: Any) {
        sessionSelected = "Mindset"
        app.pathway = "Mindset"
        app.sessionType = "User Selected"
        ButtonAction()
    }
    
    // Setup and action for Mobility button
    @IBOutlet weak var mobility: UIButton!
    @IBAction func mobilityButton(_ sender: Any) {
        sessionSelected = "Mobility"
        app.pathway = "Mobility"
        ButtonAction()
    }
    
    // Setup and action for Fatigue button
    @IBOutlet weak var fatigue: UIButton!
    @IBAction func fatigueButton(_ sender: Any) {
        sessionSelected = "Fatigue"
        app.pathway = "Fatigue"
        ButtonAction()
    }
    
    // Setup and action for Soreness button
    @IBOutlet weak var soreness: UIButton!
    @IBAction func sorenessButton(_ sender: Any) {
        sessionSelected = "Aches and Pains"
        app.pathway = "Aches and Pains"
        ButtonAction()
    }
    
    // Action when button is pressed
    func ButtonAction(){
        app.location = "Home"
        //Determine if login as individual or organization account
        if orgName != "individual" {
            performSegue(withIdentifier: "OrgCatalogue", sender: self)
        } else {
            performSegue(withIdentifier: "IndividualCatalogue", sender: self)
            
        }
    }
    
    // Find specific user information - SenderID and Weight
    func findUserInfo(company: String) {
        
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
            let result = snapshot.childSnapshot(forPath: "senderId").value as? String
            let weight = snapshot.childSnapshot(forPath: "weight").value as? String
            
            self.app.scores.setValue(weight, forKey: "weight")
            self.app.scores.setValue(result, forKey: "senderId")
            
        })
        
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        //Load the locker information from Database
        loadLockerData()
        
        
        // Read in Apple Health Information
        readHRV()
        readSleep()
        readSteps()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Check HealthKit Permissions
        getHealthKitPermission()
        
        //Set orgname from userdefaults in app delegate
        orgName = app.scores.value(forKey: "organization") as! String
        
        //Run function to change pathway buttons depending on screen size
        screenSize()
        
        //Load information from database
        findUserInfo(company: orgName)
        loadAchieve()
        

        //Set Logo in title of nav bar
        let logo = UIImage(named: "AmpedRx Small")
        let ImageView = UIImageView(image: logo!)
        ImageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = ImageView
        
        //set menu button on nav bar
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        menuButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        menuButton.setBackgroundImage(UIImage(named: "hamburger.png"), for: .normal)
        menuButton.addTarget(self, action: #selector(MenuViewController.menuButton(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        
    }
    
    // Pathway Button Constraints
    @IBOutlet weak var topTwoConst: NSLayoutConstraint!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var soreHConst: NSLayoutConstraint!
    @IBOutlet weak var fatHConst: NSLayoutConstraint!
    @IBOutlet weak var mobHConst: NSLayoutConstraint!
    @IBOutlet weak var mindHConst: NSLayoutConstraint!
    
    @IBOutlet weak var soreWConst: NSLayoutConstraint!
    @IBOutlet weak var fatWConst: NSLayoutConstraint!
    @IBOutlet weak var mobWConst: NSLayoutConstraint!
    @IBOutlet weak var mindWConst: NSLayoutConstraint!
    
    // Change pathway button constraints depending on screen size.
    func screenSize(){
        let widthMult = Double(self.view.frame.width) / 375
        let heightMult = Double(self.view.frame.height) / 667
       
        if heightMult > 1 {
        mobHConst.constant = mobility.frame.height * CGFloat(heightMult)
        mindHConst.constant = mindfulness.frame.height * CGFloat(heightMult)
        soreHConst.constant = soreness.frame.height * CGFloat(heightMult)
        fatHConst.constant = fatigue.frame.height * CGFloat(heightMult)
            
        mobWConst.constant = mobility.frame.width * CGFloat(widthMult)
        mindWConst.constant = mindfulness.frame.width * CGFloat(widthMult)
        soreWConst.constant = soreness.frame.width * CGFloat(widthMult)
        fatWConst.constant = fatigue.frame.width * CGFloat(widthMult)
            
        fatigue.frame.size.width = fatigue.frame.width * CGFloat(widthMult)
        fatigue.frame.size.height = fatigue.frame.height * CGFloat(heightMult * 0.9)
        soreness.frame.size.width = soreness.frame.width * CGFloat(widthMult)
        soreness.frame.size.height = soreness.frame.height * CGFloat(heightMult * 0.9)
        mindfulness.frame.size.width = mindfulness.frame.width * CGFloat(widthMult)
        mindfulness.frame.size.height = mindfulness.frame.height * CGFloat(heightMult * 0.9)
        mobility.frame.size.width = mobility.frame.width * CGFloat(widthMult)
        mobility.frame.size.height = mobility.frame.height * CGFloat(heightMult * 0.9)
        
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Setup information transfer through Stroyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let progNavVC = segue.destination as? UINavigationController {
            let programSelect = progNavVC.viewControllers.first as! ProgramSelectionViewController
            programSelect.lockerEquipment = lockerEquipment;
        }
    }
  
    // Pull down locker information from database 1 modality at time
    func setAtHomeModalities(passOrg: String, locker: String, passModality: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        ref.child(passOrg).child(userID).child("lockers").child(locker).child(passModality).observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let result = snapshot.value as? Bool
                else {
                    completionHandler(false)
                    
                    return
            }
            completionHandler(result)
        })
    }
    
    
    // load both the individual locker and app delegate locker with the equipment in locker if return == true
    func loadLockerData(){
        
        self.app.lockerEquipment.removeAll()
        self.app.lockerEquipment.append("Pilates")
        self.app.lockerEquipment.append("Yoga")
        self.app.lockerEquipment.append("Unguided Meditation")
        self.app.lockerEquipment.append("Guided Meditation")
        self.app.lockerEquipment.append("Binaural Beats")
        self.app.lockerEquipment.append("Breathing")
        self.app.lockerEquipment.append("Full Program")
        self.app.lockerEquipment.append(" Full Programs")
        
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Mobility Exercises") { (result) in if result == true {self.lockerEquipment.append("MobEx"); self.app.lockerEquipment.append("AmpedRx Mobility")}}
        //Compression
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Compression Legs") { (result) in if result == true {self.lockerEquipment.append("Normatec"); self.app.lockerEquipment.append("Compression Therapy")}}
        //setAtHomeModalities(passOrg: company, locker: locker, passModality: "Compression Arms") { (result) in if result == true {self.lockerEquipment.append("Normatec")}}
        //setAtHomeModalities(passOrg: company, locker: locker, passModality: "Compression Hips") { (result) in if result == true {self.lockerEquipment.append("Normatec")}}
        
        //Thermal Therapy
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Shower") { (result) in if result == true {self.lockerEquipment.append("Shower"); self.app.lockerEquipment.append("Cold Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Water Immersion") { (result) in if result == true {self.lockerEquipment.append("Bath"); self.app.lockerEquipment.append("Cold Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Ice") { (result) in if result == true {self.lockerEquipment.append("Ice"); self.app.lockerEquipment.append("Cold Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Cold Compression") { (result) in if result == true {self.lockerEquipment.append("Game Ready"); self.app.lockerEquipment.append("Cold Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Cryotherapy") { (result) in if result == true {self.lockerEquipment.append("Cryotherapy"); self.app.lockerEquipment.append("Cold Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Heat Pack") { (result) in if result == true {self.lockerEquipment.append("Heat"); self.app.lockerEquipment.append("Heat Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Sauna") { (result) in if result == true {self.lockerEquipment.append("Sauna"); self.app.lockerEquipment.append("Heat Therapy")}}
        
        // Myofascial Equip
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Roller") { (result) in if result == true {self.lockerEquipment.append("Myofascial Roller"); self.app.lockerEquipment.append("Foam Roller")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Ball") { (result) in if result == true {self.lockerEquipment.append("Myofascial Ball"); self.app.lockerEquipment.append("Myofascial Ball")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Stick") { (result) in if result == true {self.lockerEquipment.append("Myofascial Stick"); self.app.lockerEquipment.append("Myofascial Stick")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Floss Band") { (result) in if result == true {self.lockerEquipment.append("Floss Band"); self.app.lockerEquipment.append("Floss Band")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Resistance Band") { (result) in if result == true {self.lockerEquipment.append("Resistance Band"); self.app.lockerEquipment.append("Resistance Band")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "IASTM") { (result) in if result == true {self.lockerEquipment.append("IASTM"); self.app.lockerEquipment.append("IASTM Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Kinesio Tape") { (result) in if result == true {self.lockerEquipment.append("Kinesio Tape"); self.app.lockerEquipment.append("Kinesio Tape")}}
        
        //Light Therapy
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "IR Sauna") { (result) in if result == true {self.lockerEquipment.append("IrSauna"); self.app.lockerEquipment.append("Light Therapy")}}
        
        //Electrical Muscle Stim
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Soreness Relief Unit") { (result) in if result == true {self.lockerEquipment.append("Compex"); self.app.lockerEquipment.append("Tens Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Recovery Flush Unit") { (result) in if result == true {self.lockerEquipment.append("Marc Pro"); self.app.lockerEquipment.append("Muscle Stimulation")}}
        
        // Vibration Therapy
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Vibration Hand Held") { (result) in if result == true {self.lockerEquipment.append("VibHH"); self.app.lockerEquipment.append("Vibration Therapy")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Vibration Plate") { (result) in if result == true {self.lockerEquipment.append("Vibration Plate"); self.app.lockerEquipment.append("Whole Body Vibration Therapy")}}
        
        //Mindset Therapy
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "EGG Unit") { (result) in if result == true {self.lockerEquipment.append("Muse"); self.app.lockerEquipment.append("EGG Unit")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Neurostimulation Unit") { (result) in if result == true {self.lockerEquipment.append("Thync"); self.app.lockerEquipment.append("Neurostimulation")}}
        
        // Sensory Deprevation
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Float Tank") { (result) in if result == true {self.lockerEquipment.append("Float Tank"); self.app.lockerEquipment.append("Sensory Therapy")}}
        
        //Cream
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Cream") { (result) in if result == true {self.lockerEquipment.append("Cream"); self.app.lockerEquipment.append("Analgesic Cream ")}}
        
        
    }
    
    
    // Array holding challenges by title and badge URL.
    var challenges: [chall] = [chall(title: "10 Sessions", badge: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/Challenges%2FBadges%2FBadgeOne.png?alt=media&token=11ea832c-a75c-4385-83e1-4a5cea7054d6"), chall(title: "10 Full programs", badge: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/Challenges%2FBadges%2FBadgeTwo.png?alt=media&token=f4bc5782-d9c4-4202-8ad2-4fc0e3330ea0"), chall(title: "5 Meditation Sessions", badge: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/Challenges%2FBadges%2FBadgeThree.png?alt=media&token=4c85c77d-1c88-4286-ae34-662d40018128")]

    
    // Check to see if any of the challenges has been completed
    func loadAchieve(){
        checkAchievement(company: orgName) { (result) in
            self.totalSessions = result
            
            // if total sessions == 10
            if result == 10 {
                // update database with challenge info if true
                self.updateAchieve(company: self.orgName, title: self.challenges[0].title, badge: self.challenges[0].badge)
            }
            
            // if full programs(AMPEDRX) workouts == 10
            if self.fullProgCount == 10 {
                // update database with challenge info if true
                self.updateAchieve(company: self.orgName, title: self.challenges[1].title, badge: self.challenges[2].badge)
            }
            
            //if user has completed 5 mindfulness sessions
            if self.mindProgCount == 5{
                // update database with challenge info if true
                self.updateAchieve(company: self.orgName, title: self.challenges[2].title, badge: self.challenges[2].badge)
            }
        }
        // Set total number of sessions in UserDefaults on app delegate
        self.app.scores.setValue(totalSessions, forKey: "totalSessions")
        }
    
    // Function for updating the database with challenge information
    func updateAchieve(company: String, title: String, badge: String){
        let userID: String = (Auth.auth().currentUser?.uid)!
        print("HERE AGAIN")
        ref.child(company).child(userID).child("userDetails").child("challenges").updateChildValues([title : badge])
    }
    
    
    
    // Function to calculate the number of specific sessions that have been completed - total #, # of full program and # of mindfulness workouts
    func checkAchievement(company: String, complete: @escaping (Int)-> Void){
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child(company).child(userID).child("Scores").child("Sessions").observeSingleEvent(of: .value) { (Snapshot) in
            let snap = Snapshot.children.allObjects as! [DataSnapshot]
            
            for s in snap {
                let path = s.childSnapshot(forPath: "Pathway").value as! String
                if path == " Full Program" {
                    self.fullProgCount += 1
                } else if path == "Unguided Meditation" || path == "Guided Meditation" {
                    self.mindProgCount += 1
                }
                
                self.sessionCount += 1
            }
            complete(self.sessionCount)
        }
        
    }
    
    
    //Setup HealthKit Permissions
    func getHealthKitPermission() {
        if #available(iOS 11.0, *) {
            let healthkitTypesToRead = NSSet(array: [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) ?? "",
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate) ?? "",
                HKObjectType.activitySummaryType(),
                ])
            
            let healthkitTypesToWrite = NSSet(array: [
                
                ])
            
            healthKitStore.requestAuthorization(toShare: healthkitTypesToWrite as? Set, read: healthkitTypesToRead as? Set) { (success, error) in
                if success {
                    print("Permission accept.")
                    
                    self.readSleep()
                    self.readHRV()
                } else {
                    if error != nil {
                        print(error ?? "")
                    }
                    print("Permission denied.")
                }
            }
        }
    }
    
    // Read in sleep information from apple health
    func readSleep(){
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            //let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue) ? "InBed" : "Asleep"
                            
                            let seconds = sample.endDate.timeIntervalSince(sample.startDate)
                            let minutes = seconds/60
                            let hours = minutes/60
                            
                            let s = String(format:"%.1f",hours)
                            self.app.scores.setValue(s, forKey: "SleepIn")
                            
                        }
                    }
                }
            }
            self.healthKitStore.execute(query)
        }
    }
    
    //read in HRV from apple Health
    func readHRV(){
        if #available(iOS 11.0, *) {
            
            if let HrvType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN) {
                
                //let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                //let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: HKQueryOptions.strictEndDate)
                let query = HKSampleQuery(sampleType: HrvType, predicate: nil, limit: 10, sortDescriptors: [sortDescriptor]) { sampleQuery, results, error  in
                    if(error == nil) {
                        for result in results! {
                            let HRV = result as! HKQuantitySample
                            
                            var hrvReadings: [Int] = []
                            hrvReadings.append(Int(HRV.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)).rounded()))
                            self.app.hrv.append(contentsOf: hrvReadings)
                            
                        }
                    }
                }
                
                self.healthKitStore.execute(query)
                
            }
        }
    }
    
    //Read steps from Apple Health
    func readSteps(){
        if #available(iOS 11.0, *) {
            
            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
            let now = Date()
            let yesterday = Date() - (24*60*60)
            let startOfYesterday = Calendar.current.startOfDay(for: yesterday)
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: startOfDay, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()
                
                let s = sum?.doubleValue(for: HKUnit.count())
                if s != nil {
                    self.app.steps = (sum?.doubleValue(for: HKUnit.count()))!
                    //self.updatePreScoreInfo(company: self.orgName, score: "Total Steps(Yesterday)", count: Int(self.app.steps))
                }
            }
            
            healthKitStore.execute(query)
        }
        
    }
    
}
