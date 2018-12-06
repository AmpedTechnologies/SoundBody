//
//  VideoViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 8/15/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import JGProgressHUD
import AudioUnit
import AudioToolbox
import SwiftySound
import Cosmos
import HealthKit

class progVideos {
    var name: String!
    var video: String!
    var time: Int!
    var audio: String!
    
    init(name: String, video: String, time: Int, audio: String){
        self.name = name
        self.video = video
        self.time = time
        self.audio = audio
    }
}

class VideoViewController: UIViewController {

    var stars = 0.0
    var met = 0.0
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    let healthStore = HKHealthStore()
    let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    var energyBurned = 0.0
    var weight = ""
    let dateFormat = DateFormatter()
    var audioOne: AVPlayerItem!
    var audioTwo: AVPlayerItem!
    var playerOne: AVPlayer!
    var playerTwo: AVPlayer!
    
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    var playerViewControllerTwo = AVPlayerViewController()
    var playerViewTwo = AVPlayer()
    var timer = Timer()
    var exTimer = Timer()
    var timeTotal: Int?
    var exerciseTime: Int?
    var progType = ""
    var progArea = ""
    var time = 0
    var progDivide = 0.0
    var orgName: String!
    var pathway: String!
    var AmpedRx: String!
    var t: Int!
    var startTime: Date!
    var endTime: Date!
    var progNumb = 0
    var vidNumb = 0
    var prog = 0.0
    var playSelected = false
    var looper: AVPlayerLooper?
    var looperTwo: AVPlayerLooper?
    var queuePlayer: AVQueuePlayer!
    var queueTwoPlayer: AVQueuePlayer!
    let zero = 0
    var progVidArray: [progVideos] = []
    var timeRemain = 0
    
    var lockerEquipment: [String] = []
    var soreLocker =  ["Marc Pro", "Game Ready", "VibHH", "Myofascial Roller", "Myofascial Ball", "Myofascial Stick", "Compex", "Ice", "Heat"]
    var fatLocker = ["Sauna", "Cryotherapy", "Ice Bath", "Heat", "Normatec", "Marc Pro", "Compex", "VibWB", "VibHH", "IASTM", "Myofascial Roller", "Myofascial Roller", "Myofascial Stick", "Floss Band"]
    var mindLocker = ["Binuaral Beats", "Guided Meditation", "Unguided Meditation"]
    var mobLocker = ["Cryotherapy", "Heat", "Normatec", "VibWB", "VibHH", "IASTM", "Myofascial Roller", "Myofascial Roller", "Myofascial Stick", "Floss Band", "Band"]
    var locker: [String] = []
    
    let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    let pauseButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var programProg: UIProgressView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var nextExButton: UIButton!
    @IBOutlet weak var nextExLabel: UILabel!
    @IBOutlet weak var exNumbLabel: UILabel!
    @IBOutlet weak var exVideoPlayer: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var exTime: UILabel!
    @IBOutlet weak var nextExName: UILabel!
    @IBOutlet weak var exName: UILabel!
    @IBOutlet weak var nextExImage: UIImageView!
    
    // Setup No button on the sudo alert
    @IBAction func noAlertButton(_ sender: Any) {
        alertView.isHidden = true
    }
    
    //Setup Yes button action on the sudo alert
    @IBAction func yesAlertButton(_ sender: Any) {
        
        // Set end time for apple health info
        self.endTime = Date()
        
        //Set up the metabloic equivalent score for apple health
        if progType == "Pilates" || progType == "Yoga" || progType == "AmpedRx" {
            met = 3.3
        } else {
            met = 2.0
        }
        
        // Calculate the total energy burned
        let en = (Double(weight)! / 2.2) * met
        let t = Double((self.time * 60 - self.timeTotal!) / 60) / 60
        self.energyBurned = Double(t * en)
        
        //Save the calories to apple health
        self.saveExCal(startTime: self.startTime, endTime: self.endTime)
        
        // Pause all video and audio players
        if self.progVidArray.count <= 1 {
        
        } else {
            self.queueTwoPlayer.pause()
            self.playerTwo.pause()
        }
        self.playerOne.pause()
        self.queuePlayer.pause()
        self.timer.invalidate()
        self.exTimer.invalidate()
        
        // Update the database with SKIPPED programs
        Functions.updatePathwayInfo(company: self.orgName, program: self.progType, prog: self.progArea, pathway: self.pathway, stus: "Skipped", time: "\(self.time) Min", timeCompleted: (self.time * 60 - self.timeTotal!))
        
        self.performSegue(withIdentifier: "Skip", sender: self)
    }
    
    //Setup action for when the next button is pressed on screen
    func nextVideo(){
        
        //Check the number of videos is in the progVid array
        if progVidArray.count <= 1 {
            
        } else {
        vidNumb = vidNumb + 1
        self.exNumbLabel.text = "Exercise \(self.vidNumb + 1) of \(self.progVidArray.count)"
        let addTime = (progDivide * Double(exerciseTime!))
        prog = prog + addTime
        
        if vidNumb < progVidArray.count {
            if progNumb == 0 {
                
                //Pause player one and update the screen details with the info in the next array index
                playerOne.pause()
                exerciseTime = progVidArray[vidNumb].time
                exName.text = progVidArray[vidNumb].name
                //Play video player two immediately without waiting for the whole video to buffer
                playerViewTwo.playImmediately(atRate: 1.0)
                
                // display the second video player
                playerViewControllerTwo.view.frame = exVideoPlayer.frame
                playerViewController.view.removeFromSuperview()
                self.view.addSubview(playerViewControllerTwo.view)
                self.view.bringSubview(toFront: exVideoPlayer)
                playerViewControllerTwo.showsPlaybackControls = false
                
                // Initialize the first video player with the next video
                    //Check to make sure there is another video
                if vidNumb + 1 < progVidArray.count{
                    nextExName.text = progVidArray[vidNumb + 1].name
                    //Setup video file
                    let asset = AVAsset(url: URL(string: self.progVidArray[vidNumb + 1].video)!)
                    let playerItem = AVPlayerItem(asset: asset)
                    queuePlayer = AVQueuePlayer(playerItem: playerItem)
                    looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
                    playerViewController.player = queuePlayer
                    //Setup audio file
                    let SoundURL = URL(string: self.progVidArray[vidNumb + 1].audio)
                    self.audioOne = AVPlayerItem(url: SoundURL!)
                    self.playerOne = AVPlayer(playerItem: self.audioOne)
                }
                queueTwoPlayer.play()
                playerTwo.play()
                progNumb = 1
                
            } else if progNumb == 1 {
                playerTwo.pause()
                exName.text = progVidArray[vidNumb].name
                exerciseTime = progVidArray[vidNumb].time
                playerView.playImmediately(atRate: 1.0)
                    if vidNumb + 1 < progVidArray.count{
                        nextExName.text = progVidArray[vidNumb + 1].name
                    } else {
                        nextExName.text = ""
                    }
                queueTwoPlayer.pause()
                
                // Display the first Video Player
                playerViewController.view.frame = exVideoPlayer.frame
                playerViewControllerTwo.view.removeFromSuperview()
                self.view.addSubview(playerViewController.view)
                self.view.bringSubview(toFront: exVideoPlayer)
                playerViewController.showsPlaybackControls = false
                
                // Need to add code to initialize the second video Player with the next next video
                if vidNumb + 1 < progVidArray.count{
                    let asset = AVAsset(url: URL(string: self.progVidArray[vidNumb + 1].video)!)
                    let playerItemTwo = AVPlayerItem(asset: asset)
                    queueTwoPlayer = AVQueuePlayer(playerItem: playerItemTwo)
                    looperTwo = AVPlayerLooper(player: queueTwoPlayer, templateItem: playerItemTwo)
                    playerViewControllerTwo.player = queueTwoPlayer
                    let SoundURLTwo = URL(string: self.progVidArray[vidNumb + 1].audio)
                    self.audioTwo = AVPlayerItem(url: SoundURLTwo!)
                    self.playerTwo = AVPlayer(playerItem: self.audioTwo)
                } else {
                    nextExButton.isEnabled = false
                }
                progNumb = 0
                queuePlayer.play()
                playerOne.play()
            }
        } else {
            nextExButton.isEnabled = false
                }
        }
    }
    
    //Action for when next button is pressed
    @IBAction func nextExButton(_ sender: Any) {
        nextVideo()
    }
    
    // Action for when the cancel button is pressed.
    @IBAction func cancelButtonAction(_ sender: Any) {
        alertLabel.text = "Are you sure you want to skip the rest of this program?"
        alertView.isHidden = false
        
    }
    
    //Update the total timer - this info is used to send how long the program was run to the database - important to see if user is skipping.
    @objc func updateTime(){
        if timeTotal! > 0 {
            prog = prog + progDivide
            timeTotal! = timeTotal! - 1
            let minute = Int(timeTotal! / 60) % 60
            let second = Int(timeTotal!) % 60
            totalTime.text = String(format: "%02i:%02i", minute, second)
            self.programProg.setProgress(Float(prog), animated: true)
            
        }
        else {
            if exerciseTime! == 0 {
            AudioServicesPlayAlertSound(1005)
            }
        }
    }
    
    // Update the individual exercise timer
    @objc func updateExTime(){
        if exerciseTime! > 0 {
            
            exerciseTime! = exerciseTime! - 1
            let minute = Int(exerciseTime! / 60) % 60
            let second = Int(exerciseTime!) % 60
            exTime.text = String(format: "%02i:%02i", minute, second)
            
        }
        else {
            AudioServicesPlayAlertSound(1008)
            if vidNumb == progVidArray.count - 1 {
                timer.invalidate()
                exTimer.invalidate()
                endAlertView()
            } else {
                nextVideo()
            }
        }
    }

    
   // Setup the end alert
    func endAlertView(){
        noButton.isHidden = true
        yesButton.isHidden = true
        okButton.isHidden = false
        alertLabel.text = "You have completed your program"
        alertView.isHidden = false
    }

    // Setup action when ok selected after completing workout
    @IBAction func okButton(_ sender: Any) {
        
        //Set metabolic equivalent for apple health calculation
        if progType == "Pilates" || progType == "Yoga" || progType == "AmpedRx" {
            met = 3.3
        } else {
            met = 2.0
        }
        
        //Perform calculation of Metabolic equivalent
        let en = (Double(weight)! / 2.2) * met
        let t = Double((self.time * 60 / 60)) / 60
        self.energyBurned = Double(t * en)
        self.endTime = Date()
        self.saveExCal(startTime: self.startTime, endTime: self.endTime)
        
        //pause/stop/terminate all video and audio players.
        if self.progVidArray.count <= 1 {
            
        } else {
            self.queueTwoPlayer.pause()
            self.playerTwo.pause()
        }
        self.playerOne.pause()
        self.queuePlayer.pause()
        self.timer.invalidate()
        self.exTimer.invalidate()
        
        // Update database with completed program information
        Functions.updatePathwayInfo(company: self.orgName, program: self.progType, prog: self.progArea, pathway: self.pathway, stus: "Completed", time: "\(self.time) Min", timeCompleted: (self.time * 60 - self.timeTotal!))

        self.performSegue(withIdentifier: "Skip", sender: self)
    }
    
    // Setup Action for the play/pause button
    @objc func playButton(sender: UIButton){
        progDivide = (1/Double(timeTotal!))
        
        //Check if currently playing - if not start timers
        if playSelected == false {
            if timeTotal! > 0{
                playSelected = true
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(VideoViewController.updateTime), userInfo: nil, repeats: true)
                exTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(VideoViewController.updateExTime), userInfo: nil, repeats: true)
                
                //Change button to pause button
                playButton.setBackgroundImage(#imageLiteral(resourceName: "pauseButtonGreen.png"), for: .normal)
                
                    if progNumb == 0 {
                        queuePlayer.play()
                        playerOne.play()
                    } else if progNumb == 1 {
                        queueTwoPlayer.play()
                        playerTwo.play()
                    }
            }
        } else if playSelected == true {
            if progNumb == 1 {
                queuePlayer.play()
                playerOne.play()
            } else if progNumb == 0 {
                if progVidArray.count <= 1 {
                    
                } else {
                queueTwoPlayer.play()
                playerTwo.play()
                }
            }
            
            //Set button back to play button
            playButton.setBackgroundImage(#imageLiteral(resourceName: "playbuttonGreen.png"), for: .normal)
            playerView.pause()
            queuePlayer.pause()
            
            playSelected = false
            timer.invalidate()
            exTimer.invalidate()
            playerOne.pause()
            
            if progVidArray.count <= 1 {
                
            } else {
                queueTwoPlayer.pause()
                playerTwo.pause()
            }
        }
    }
    
    // Setup action for exit button
    @objc func pauseButton(sender: UIButton){
        okButton.isHidden = true
        alertLabel.text = "Are you sure you want to skip the rest of this program?"
        alertView.isHidden = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set which locker to compare equipment to
        if pathway == "Aches and Pains"{
            locker = soreLocker
        } else if pathway == "Mobility"{
            locker = mobLocker
        } else if pathway == "Mindset" {
            locker = mindLocker
        } else if pathway == "Fatigue" {
            locker = fatLocker
        }
        
        // Remove certain items depending on time
        if time == 5 {
            if lockerEquipment.contains("Marc Pro") {
                if let mpIndex = lockerEquipment.index(where: { $0 == "Marc Pro" }){
                    lockerEquipment.remove(at: mpIndex)
                }
            }
        }
        
        // set locker so that only 1 myofascial tool is used.
        if lockerEquipment.contains("Myofascial Roller") {
            if let ballIndex = lockerEquipment.index(where: { $0 == "Myofascial Ball" }){
                lockerEquipment.remove(at: ballIndex)
            }
            if let stickIndex = lockerEquipment.index(where: { $0 == "Myofascial Stick" }){
                lockerEquipment.remove(at: stickIndex)
            }
        } else if lockerEquipment.contains("Myofascial Ball"){
            if let stickIndex = lockerEquipment.index(where: { $0 == "Myofascial Stick" }){
                lockerEquipment.remove(at: stickIndex)
            }
        }
        
        print("The pathway is \(pathway)")
        print("The progType is \(progType)")
        print("The progArea is \(progArea)")
        print("The time is \(time)")
        // Set time to seconds
        t = time * 60
        timeRemain = t
        
        //If full program selected run function and build workout.
        if progType == " Full Programs" {
            
            Equip(locker: locker, totTime: t, index: 0) { (result) in
                self.playVideo()
            }
        }else {
            //Else pull videos of selected program
            getProgramVid(time: "\(time) Min", path: app.pathway, type: progType, prog: progArea) { (result) in
            self.playVideo()
            }
        }
        
        // Set the video player background color to white
        playerViewController.view.backgroundColor = UIColor.white
        playerViewControllerTwo.view.backgroundColor = UIColor.white

        //Setup time defaults
        timeTotal = (60 * time)
        exerciseTime = 60
        totalTime.text = String(format: "%02i:%02i", time, zero)
    }
    
    //Play video function
    func playVideo(){
        //Setup first video and audio files
        self.exerciseTime = self.progVidArray[0].time
        self.exName.text = self.progVidArray[0].name
        self.nextExName.text = ""
        let asset = AVAsset(url: URL(string: self.progVidArray[0].video)!)
        let playerItem = AVPlayerItem(asset: asset)
        let SoundURL = URL(string: self.progVidArray[0].audio)
        self.audioOne = AVPlayerItem(url: SoundURL!)
        self.playerOne = AVPlayer(playerItem: self.audioOne)
        self.nextExButton.isHidden = true
        self.nextExLabel.isHidden = true
        self.exNumbLabel.text = "Exercise \(self.vidNumb + 1) of \(self.progVidArray.count)"
        
        //If the video array only holds 1 video file then setup screen accordingly
        if self.progVidArray.count > 1 {
            self.nextExButton.isHidden = false
            self.nextExLabel.isHidden = false
            self.nextExName.text = self.progVidArray[1].name
            let assetTwo = AVAsset(url: URL(string: self.progVidArray[1].video)!)
            let playerItemTwo = AVPlayerItem(asset: assetTwo)
            let SoundURLTwo = URL(string: self.progVidArray[1].audio)
            self.audioTwo = AVPlayerItem(url: SoundURLTwo!)
            self.playerTwo = AVPlayer(playerItem: self.audioTwo)
            self.queueTwoPlayer = AVQueuePlayer(playerItem: playerItemTwo)
            self.looperTwo = AVPlayerLooper(player: self.queueTwoPlayer, templateItem: playerItemTwo)
            self.playerViewControllerTwo.player = self.queueTwoPlayer
        }
        
        self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.looper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)
        self.playerViewController.player = self.queuePlayer
        self.programProg.transform = CGAffineTransform(scaleX: 1, y: 10)
        
        let min = Int(self.progVidArray[0].time / 60) % 60
        let sec = Int(self.progVidArray[0].time) % 60
        self.exTime.text = String(format: "%02i:%02i", min, sec )
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        //Setup start time and weight so that total cal can be calculated
        startTime = Date()
        weight = app.scores.value(forKey: "weight") as! String
        
        //Setup delay hud
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "DOWNLOADING PROGRAM"
        hud.show(in: self.exVideoPlayer)
        hud.dismiss(afterDelay: 10.0)
        
        //Setup play button as right navigation button
        playButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        playButton.setBackgroundImage(#imageLiteral(resourceName: "playbuttonGreen.png"), for: .normal)
        playButton.addTarget(self, action: #selector(VideoViewController.playButton(sender:)), for: .touchUpInside)
        self.navBar.rightBarButtonItem = UIBarButtonItem(customView: playButton)
        
        //Setup back button as left navigation button
        pauseButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        pauseButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        pauseButton.setBackgroundImage(#imageLiteral(resourceName: "exitbutton.png"), for: .normal)
        pauseButton.addTarget(self, action: #selector(VideoViewController.pauseButton(sender:)), for: .touchUpInside)
        self.navBar.leftBarButtonItem = UIBarButtonItem(customView: pauseButton)
        
        // Setup navigation bar title
        let titleOut = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        titleOut.text = progArea
        self.navBar.title = titleOut.text
        
  
        //Setup Video player UI
        playerViewController.view.frame = exVideoPlayer.frame
        self.view.addSubview(playerViewController.view)
        self.view.bringSubview(toFront: exVideoPlayer)
        playerViewController.showsPlaybackControls = false
        playerView.automaticallyWaitsToMinimizeStalling = false
        
        //Setup Alert UI
        alertView.layer.cornerRadius = 5.0
        alertView.layer.masksToBounds = true
        
        //Setup rating system
        rating.didFinishTouchingCosmos = { rating in
            self.stars = rating
        }
        
        //Setup Button UI
        yesButton.layer.borderColor = UIColor.gray.cgColor
        yesButton.layer.borderWidth = 1.0
        noButton.layer.borderColor = UIColor.gray.cgColor
        noButton.layer.borderWidth = 1.0
        okButton.layer.borderColor = UIColor.gray.cgColor
        okButton.layer.borderWidth = 1.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Get program video and add to video array so they can be displayed on the screen
    func getProgramVid(time: String, path: String, type: String, prog: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        
        ref.child("Programs").child(path).child(time).child(type).child(prog).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            for snap in snapshots! {
                if snap.childSnapshot(forPath: "name").exists() {
                let name    = snap.childSnapshot(forPath: "name").value as! String
                let video   = snap.childSnapshot(forPath: "video").value as! String
                let time    = snap.childSnapshot(forPath: "time").value as! Int
                let audio   = snap.childSnapshot(forPath: "audio").value as! String
                
                let pv = progVideos(name: name, video: video, time: time, audio: audio)
                
               self.progVidArray.append(pv)
            }
            }
            completionHandler(true)
            
        })
        
    }
    
    
    // Find what equipment the user has in their locker
    func Equip(locker: [String], totTime: Int, index: Int, completition: @escaping (Bool)-> Void){
        if lockerEquipment.contains(locker[index]){
            if index < locker.count - 1{
                self.loadAmpedRxProgs(path: self.pathway!, time: ("\(self.time) Min"), modality: self.locker[index], area: self.progArea) { (result) in
                    
                    if self.t <= 0{
                        completition(true)
                        return
                    } else {
                        self.Equip(locker: locker, totTime: self.timeRemain, index: index + 1, completition: { (result) in
                            
                            if self.t <= 0{
                                completition(true)
                                return
                            }
                        })
                    }
                }
            }
                   else {
                completition(true)
                return
            }
        } else {
            self.Equip(locker: locker, totTime: self.timeRemain, index: index + 1, completition: { (result) in
                print("Not in locker")
                if self.t <= 0{
                    completition(true)
                    return
                }
            })
        }
    }
    
    //Load the application video into the ampedRx program - based on locker equipment function.
    func loadAmpedRxProgs(path: String, time: String, modality: String, area: String, completitionHandler: @escaping (_ status: Int)-> Void){
            var dt = 0
        ref.child("Programs").child("AmpedRx").child(path).child(time).child(modality).child(area).observeSingleEvent(of: .value) { (Snapshot) in
            let snap = Snapshot.children.allObjects as? [DataSnapshot]
            for s in snap!{
                
                if s.childSnapshot(forPath: "name").exists() {
                    let name            = s.childSnapshot(forPath: "name").value as! String
                    let video           = s.childSnapshot(forPath: "video").value as! String
                    var databaseTime    = s.childSnapshot(forPath: "time").value as! Int
                    let audio           = s.childSnapshot(forPath: "audio").value as! String
                    
                    let remain = self.t
                    self.t -= databaseTime

                    // If time == 0 then change the database time to the remaining time and add to array.
                    if self.t <= 0 {
                        databaseTime = remain!
                        let pv = progVideos(name: name, video: video, time: databaseTime, audio: audio)
                        self.progVidArray.append(pv)
                        
                    } else {
                        
                        dt += databaseTime
                        let pv = progVideos(name: name, video: video, time: databaseTime, audio: audio)
                        self.progVidArray.append(pv)
                    }
                }
            }
            completitionHandler(dt)
            
        }
        
        
    }
    
    //Save workout information to apple health
    func saveExCal(startTime: Date, endTime: Date){
        print("Save Ex Cal data")
        let unit = HKUnit.kilocalorie()
        let totalEnergyBurned = self.energyBurned
        let quantity = HKQuantity(unit: unit, doubleValue: totalEnergyBurned)
        let calSample = HKQuantitySample(type: energyType!, quantity: quantity, start: startTime, end: endTime)
        
        healthStore.save(calSample, withCompletion: { (success, error) -> Void in
         if error != nil { return }
        
        print("New Calorie Data sent to apple health \(success)")
        })
    
    }

}





