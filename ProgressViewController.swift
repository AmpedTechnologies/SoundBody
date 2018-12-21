//
//  ProgressViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 7/13/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import UICircularProgressRing
import HealthKit

class Achievements {
    var badge: String!
    var title: String!
    
    init (badge: String, title: String){
        self.badge = badge
        self.title = title
    }
}

class pathways {
    var total: Int!
    var path: String!
    
    init (total: Int, path: String){
        self.total = total
        self.path = path
    }
}

class programs {
    var total: Int!
    var prog: String!
    
    init (total: Int, prog: String){
        self.total = total
        self.prog = prog
    }
}



class ProgressViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var hrvLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var ref: DatabaseReference!
    let healthKitStore = HKHealthStore()
    var orgName: String!
    let app = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var goalSettingButton: UIButton!
    @IBOutlet weak var wellnessRing: UICircularProgressRing!
    @IBOutlet weak var sleepScore: UICircularProgressRing!
    @IBOutlet weak var moveRing: UICircularProgressRing!
    @IBOutlet weak var exRing: UICircularProgressRing!
    @IBOutlet weak var standRing: UICircularProgressRing!
    
    let dateFormat = DateFormatter()
    var today = Date()
    var startDate: Date!
    var dateArray: [String] = []
    var hrReadings: [Int] = []
    var restHrReadings: [Int] = []
    var favProgs: [String] = []
    var favProgsCount: [String:Int] = [:]
    var progs: [String:Int] = [:]
    var Achieve: [Achievements] = []
    var paths = [pathways(total: 0, path: "Soreness"),pathways(total: 0, path: "Fatigue"),pathways(total: 0, path: "Mobility"), pathways(total: 0, path: "Mindfulness")]
    var sessionCount = 0
    var mindCount = 0
    var fatCount = 0
    var soreCount = 0
    var mobCount = 0
    
    @IBOutlet weak var selectedOne: UILabel!
    @IBOutlet weak var selectedTwo: UILabel!
    @IBOutlet weak var selectedThree: UILabel!
    @IBOutlet weak var treatedOne: UILabel!
    @IBOutlet weak var treatedTwo: UILabel!
    @IBOutlet weak var treatedThree: UILabel!
    @IBOutlet weak var ampedRxSessions: UILabel!
    @IBOutlet weak var mindfulMin: UILabel!
    @IBOutlet weak var restingHr: UILabel!
    @IBOutlet weak var minHr: UILabel!
    @IBOutlet weak var maxHr: UILabel!
    @IBOutlet weak var moveCal: UILabel!
    @IBOutlet weak var exMin: UILabel!
    @IBOutlet weak var standHr: UILabel!

    // Action for goal setting button
    @IBAction func goalSettButton(_ sender: Any) {
        performSegue(withIdentifier: "goals", sender: self)
    }
    
    // Collection view setup for Achievements
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Achieve.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "achieveCell", for: indexPath) as! AchieveCollectionViewCell
        
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        
        let badgeUrl = URL(string: Achieve[indexPath.row].badge)
        cell.badgeImage.kf.setImage(with: badgeUrl)
        cell.badgeLabel.text = Achieve[indexPath.row].title
        
        return cell
    }
    
    
    // Get apple health for the progress information
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
                    
                    //self.readSleep()
                    //self.readHRV()
                } else {
                    if error != nil {
                        print(error ?? "")
                    }
                    print("Permission denied.")
                }
            }
        }
    }

    // Upload Activity information to progress report from Apple health
    func readActivity(){
        print("READ ACTIVITY")
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )
        
        dateComponents.calendar = calendar
        
        // Setup Query components
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            
            guard let summaries = summaries, summaries.count > 0
                else {
                    print("No data returned. Perhaps check for error")
                    return
            }
            let standUnit    = HKUnit.count()
            let exerciseUnit = HKUnit.minute()
            let energyUnit = HKUnit.kilocalorie()
            
            for summary in summaries as! [HKActivitySummary] {
    
            let energy   = summary.activeEnergyBurned.doubleValue(for: energyUnit)
            let stand    = summary.appleStandHours.doubleValue(for: standUnit)
            let exercise = summary.appleExerciseTime.doubleValue(for: exerciseUnit)
                    
            let energyGoal   = summary.activeEnergyBurnedGoal.doubleValue(for: energyUnit)
            let standGoal    = summary.appleStandHoursGoal.doubleValue(for: standUnit)
            let exerciseGoal = summary.appleExerciseTimeGoal.doubleValue(for: exerciseUnit)
            
                DispatchQueue.main.async {
                 
                self.moveCal.text = String(Int(energy)) + " / " + String(Int(energyGoal))
                self.standHr.text = String(Int(stand)) + " / " + String(Int(standGoal))
                self.exMin.text = String(Int(exercise)) + " / " + String(Int(exerciseGoal))
                
                let energyProgress   = energyGoal == 0 ? 0 : energy / energyGoal
                let standProgress    = standGoal == 0 ? 0 : stand / standGoal
                let exProgress = exerciseGoal == 0 ? 0 : exercise / exerciseGoal
        
                self.moveRing.startProgress(to: UICircularProgressRing.ProgressValue(energyProgress * 100), duration: 2.0)
                self.standRing.startProgress(to: UICircularProgressRing.ProgressValue(standProgress * 100), duration: 2.0)
                self.exRing.startProgress(to: UICircularProgressRing.ProgressValue(exProgress * 100), duration: 2.0)
                }
            }
            
            
            // Handle the activity rings data here
        }
        healthKitStore.execute(query)
        
    }
    
    // Read in HR information from Apple health
    func readHeartRate(){
        
            if let hRT = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) {
        
                let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending: false)
               
                let query = HKSampleQuery(sampleType: hRT, predicate: nil, limit: 600, sortDescriptors: [sortDescriptor]) { sampleQuery, results, error  in
                    guard let results = results, results.count > 0
                        else {
                            return
                    }
                    
                    let hrUnit = HKUnit(from: "count/min")
                    for result in results {
                            let HR = (result as! HKQuantitySample)
                            self.hrReadings.append(Int(HR.quantity.doubleValue(for: hrUnit)))
                        self.hrReadings.sort(by: {$0 > $1})
                        let min = self.hrReadings[0]
                        let max = self.hrReadings[self.hrReadings.count - 1]
                        
                        DispatchQueue.main.async {
                            self.maxHr.text = String(min)
                            self.minHr.text = String(max)
                        }
                        }
                    }
                
                self.healthKitStore.execute(query)
        }
    }
    
    func readRestingHeartRate(){
        if #available(iOS 11.0, *) {
        //let predicate = HKQuery.predicateForSamples(withStart: Date, end: Date(), options: .strictEndDate)
        
        if let restHR = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate) {
            
            let Predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                                  end: Date(),
                                                                  options: .strictEndDate)
            
            let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: restHR, predicate: Predicate, limit: 1, sortDescriptors: [sortDescriptor]) { sampleQuery, results, error  in
                guard let results = results, results.count > 0
                    else {
                        print("No data returned. Perhaps check for error")
                        return
                }
                
                let hrUnit = HKUnit(from: "count/min")
                for result in results {
                    let HR = (result as! HKQuantitySample)
                    self.restHrReadings.append(Int(HR.quantity.doubleValue(for: hrUnit)))
                    self.restHrReadings.sort(by: {$0 > $1})
                    let rest = self.restHrReadings[0]
                   
                    
                    DispatchQueue.main.async {
                        self.restingHr.text = String(rest)
                       
                    }
 
                }
            }
            
            self.healthKitStore.execute(query)
            
        }
        }
    }
    
    var mindSesCount = 0
    
    // Check how many session have been completed in the last 7 days
    func checkSessions(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        let currentUser: String = (Auth.auth().currentUser?.uid)!
        let now = Date()
        let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        
        let range = lastWeekDate...now
        ref.child(company).child(currentUser).child("Scores").child("Sessions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            for snap in snapshots! {
            let sesDates = self.dateFormat.date(from: snap.key)
            let path = snap.childSnapshot(forPath: "Pathway").value as! String
                
            if range.contains(sesDates!){
                self.sessionCount = self.sessionCount + 1
                if path == "Mindset"{
                    self.mindSesCount += 1
                }
            }
            }
            
            completionHandler(true)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dateFormat.dateFormat = "MMM d,yyyy h:mm:ss a"
        sessionCount = 0
        
        
        var hrv = app.hrv
        var hrvAvg = 0
        
        /*( UI Action depending on average HRV
        if hrv.count != 0 {
            for i in 1...hrv.count - 1{
                hrvAvg = hrvAvg + hrv[i]
            }
            hrvAvg = hrvAvg / hrv.count - 1
            if hrv[0] < hrvAvg {
                hrvLabel.backgroundColor = UIColor.yellow
            } else if hrv[0] >= hrvAvg {
                hrvLabel.backgroundColor = UIColor(red: 0/255, green: 249/255, blue: 0/255, alpha: 1)
            }
        }
        
        //Setup UI
        goalSettingButton.layer.cornerRadius = 5.0
        //hrvLabel.layer.cornerRadius = hrvLabel.frame.size.width / 2
        //hrvLabel.layer.masksToBounds = true
        */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //Setup Delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        orgName = app.scores.value(forKey: "organization") as! String
    
        //Run function to retreive apple health information
        readActivity()
        readHeartRate()
        readRestingHeartRate()
        
        // Get information (title and badge URL) of completed Achievements
        getAchieve(company: orgName) { (result) in
            self.Achieve.insert(Achievements(badge: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/Challenges%2FBadges%2FbadgeFour.png?alt=media&token=c2d77439-d944-48c1-8336-afeb539795d4", title: "Ready to RVIVE"), at: 0)
            self.collectionView.reloadData()
        }
        
        /* Wellness, sleep, and Mindfullness Ring Outputs.
        if let wellnessScore = app.scores.value(forKey: "averagePostScore") as? Int {
            wellnessRing.startProgress(to: CGFloat(wellnessScore), duration: 5)
            Functions.updateData(company: orgName, area: "wellnessScore", count: wellnessScore)
        }
        
        // Sleep score out.
        if let getSleepScore = app.scores.value(forKey: "sleepScoreTotal") as? Int {
            let total = (Double(getSleepScore)/Double(14)) * 100
            sleepScore.startProgress(to: CGFloat(total), duration: 5)
        }
        */
        // Run methods to retrieve and calc most selected pathway and programs
        topPathways()
        topPrograms()
        
       //run the check session function and output the result to page
        checkSessions(company: orgName) { (result) in
            Functions.getUserGoals(company: self.orgName, detail: "wellnessSessions", completionHandler: { (result) in
                let sessionGoal = result
                self.ampedRxSessions.text = String(self.sessionCount) + " / " + String(sessionGoal)
                
            })
        }
        
        // Retrieve the users goals
        Functions.getUserGoals(company: self.orgName, detail: "mindSessions", completionHandler: { (result) in
            let mindGoal = result
        self.mindfulMin.text = String(self.mindSesCount) + " / " + String(mindGoal)
        })
    }
    
    // Function to retrieve and calculate the users favourite pathways
    func getFavPath(company: String, exit: @escaping (Bool)-> Void ){
        let userID: String = (Auth.auth().currentUser?.uid)!
        var pathway: String!
        ref.child(company).child(userID).child("Scores").child("Sessions").observeSingleEvent(of: .value) { (Snapshot) in
            let snaps = Snapshot.children.allObjects as! [DataSnapshot]
            
            for s in snaps {
                pathway = s.childSnapshot(forPath: "Pathway").value as! String
            
            if pathway == "Mindset" {
                self.paths[3].total += 1
                //self.mindCount += 1
            } else if pathway == "Mobility" {
                self.paths[2].total += 1
            } else if pathway == "Fatigue" {
                self.paths[1].total += 1
            } else if pathway == "Aches and Pains" {
                self.paths[0].total += 1
            }
        }
            self.paths.sort(by : {$0.total > $1.total})
            exit(true)
            
        }
        
        
    }
    
    
    // Output the top pathway so the page is there is more than 2 in the array
    func topPathways(){
        getFavPath(company: orgName) { (result) in
            print(result)
            if self.paths.count > 2 {
            self.selectedOne.text = "1. " + self.paths[0].path
            self.selectedTwo.text = ("2. \(self.paths[1].path!)")
            self.selectedThree.text = ("3. \(self.paths[2].path!)")
            }
            
        }
    }
    
    // Retrieve and calculate the fav programs of the user
    func getFavProg(company: String, exit: @escaping ([(key: String, value: Int)])-> Void ){
        let userID: String = (Auth.auth().currentUser?.uid)!
        var program: String!
        ref.child(company).child(userID).child("Scores").child("Sessions").observeSingleEvent(of: .value) { (Snapshot) in
            let snaps = Snapshot.children.allObjects as! [DataSnapshot]
            
            for s in snaps {
                program = s.childSnapshot(forPath: "Program").value as! String
                
                self.favProgs.append(program)
            }
            self.favProgs.sort(by : { $0 > $1 })
            for item in self.favProgs {
                self.favProgsCount[item] = (self.favProgsCount[item] ?? 0) + 1
            }
            
            let p = self.favProgsCount.sorted(by: {$0.value > $1.value})
            exit(p)
            
        }
    }
    
    // Output the results of the fav programs to the screen
    func topPrograms(){
        getFavProg(company: orgName) { (result) in
            if result.count > 2{
            self.treatedOne.text = "1. \(result[0].key)"
            self.treatedTwo.text = "2. \(result[1].key)"
            self.treatedThree.text = "3. \(result[2].key)"
            }
        }
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to download the title and badge information of the acheivements from the database
    func getAchieve(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        let userId: String = (Auth.auth().currentUser?.uid)!
        let query = ref.child(company).child(userId).child("userDetails").child("challenges").queryLimited(toLast: 50)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
        
            let title      = snapshot.key
            let badge      = snapshot.value as! String
            
            let ach = Achievements(badge: badge, title: title)
            self?.Achieve.insert(ach, at: 0)

            completionHandler(true)
            
        })
    }
    
    

}
