//
//  MeditationViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 9/17/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import JGProgressHUD
import AudioUnit
import AudioToolbox
import SwiftySound
import HealthKit

class medVideos {
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

class MeditationViewController: UIViewController {
    
    
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var totalTimeOut: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var videoOut: UIView!
    
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    
    let healthStore = HKHealthStore()
    
    var timer = Timer()
    var timeTotal: Int?
    var progType = ""
    var progArea = ""
    var time = 0
    var playSelected = false
    var orgName: String!
    var pathway: String!
    var dateFormat = DateFormatter()
    var startTime: Date!
    var endTime: Date!
    var prog = 0.0
    
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    var audioOne: AVPlayerItem!
    var playerOne: AVPlayer!
    var looper: AVPlayerLooper?
    var queuePlayer: AVQueuePlayer!

    
    // Setup Alerts for both skipping and completing the program.
    let cancelAlert = UIAlertController(title: "Are you sure you want to skip the rest of this program?", message: "", preferredStyle: .alert)
    let endAlert = UIAlertController(title: "You have completed your program", message: "", preferredStyle: .alert)
    
    // Action for updating the timer and playing sound when time == 0
    @objc func updateTime(){
        if timeTotal! > 0 {
            prog = prog + (1/Double(timeTotal!))
            timeTotal! = timeTotal! - 1
            let hour = Int(timeTotal!) / 3600
            let minute = Int(timeTotal! / 60) % 60
            let second = Int(timeTotal!) % 60
            totalTimeOut.text = String(format: "%02i:%02i", minute, second)
            //self.progressBar.setProgress(Float(prog), animated: true)
            
        }
        else {
            AudioServicesPlayAlertSound(1005)
            timer.invalidate()
            self.present(endAlert, animated: true)
        }
    }
    
    // Play/pause button Action
    @IBAction func playButton(_ sender: Any) {
        if playSelected == false {
            if timeTotal! > 0{
                startTime = Date()
                playSelected = true
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(VideoViewController.updateTime), userInfo: nil, repeats: true)
                playButton.setBackgroundImage(#imageLiteral(resourceName: "pauseButtonGreen.png"), for: .normal)
                playerOne.play()
                queuePlayer.play()
                
            }
        } else if playSelected == true {
            
            playButton.setBackgroundImage(#imageLiteral(resourceName: "playbuttonGreen.png"), for: .normal)
            playSelected = false
            timer.invalidate()
            playerOne.pause()
            queuePlayer.pause()
        }
    }
    
    // Exit button Action
    @IBAction func exitButton(_ sender: Any) {
         self.present(cancelAlert, animated: true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        // get Selected programs Information - (Name, time, video URL and Audio URL)
        getProgramVid(time: "\(time) Min", path: app.pathway, type: progType, prog: progArea) { (result) in
            
            // give result of database setup the AVPlayer
            let asset = AVAsset(url: URL(string: self.medVidArray[0].video)!)
            let playerItem = AVPlayerItem(asset: asset)
            let SoundURL = URL(string: self.medVidArray[0].audio)
            self.audioOne = AVPlayerItem(url: SoundURL!)
            self.playerOne = AVPlayer(playerItem: self.audioOne)
            
            self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
            self.looper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)
            self.playerViewController.player = self.queuePlayer
            
            //Setup time of program - downloaded in seconds
            let min = Int(self.medVidArray[0].time / 60) % 60
            let sec = Int(self.medVidArray[0].time) % 60
            self.totalTimeOut.text = String(format: "%02i:%02i", min, sec )
        }
        
        //setup the totalTime the session will be completed - time is passed in Minutes
        timeTotal = (60 * time)
        //Complete setup of the play button.
        playButton.setBackgroundImage(#imageLiteral(resourceName: "playbuttonGreen.png"), for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        //Setup the layers so that the video out is the same size as the frame, and the fill stype is set
        
        playerViewController.view.frame = videoOut.frame
        self.view.addSubview(playerViewController.view)
        self.view.bringSubview(toFront: videoOut)
        playerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        // Setup progress view - how long the delay will be and what it will say while being displayed.
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "DOWNLOADING PROGRAM"
        hud.show(in: self.videoOut)
        hud.dismiss(afterDelay: 5.0)
        
        // complete setup of the AVPlayer so that it does not show the playback controls.
        playerViewController.showsPlaybackControls = false
        playerView.automaticallyWaitsToMinimizeStalling = false
        
        
        // Setup action for Cancel Alert
        cancelAlert.addAction(UIAlertAction(title: "YES", style: .default , handler: { (action) in
            self.endTime = Date()
            self.playerOne.pause()
            self.queuePlayer.pause()
            self.timer.invalidate()
            Functions.updatePathwayInfo(company: self.orgName, program: self.progType, prog: self.progArea, pathway: self.pathway, stus: "Skipped", time: "\(self.time) Min", timeCompleted: (self.time * 60 - self.timeTotal!))
            
            if self.startTime != nil {
            Functions.saveMindMin(startTime: self.startTime, endTime: self.endTime)
            }
            
            self.performSegue(withIdentifier: "home", sender: self)
        }))
        
        cancelAlert.addAction(UIAlertAction(title: "NO", style: .cancel , handler: nil))
        
        // Setup action for end Alert
        endAlert.addAction(UIAlertAction(title: "OK", style: .default , handler: { (action) in
            self.endTime = Date()
            self.playerOne.pause()
            self.queuePlayer.pause()
            self.timer.invalidate()
            Functions.updatePathwayInfo(company: self.orgName, program: self.progType, prog: self.progArea, pathway: self.pathway, stus: "Completed", time: "\(self.time) Min", timeCompleted: (self.time * 60 - self.timeTotal!))
            
            Functions.saveMindMin(startTime: self.startTime, endTime: self.endTime)
            
            self.performSegue(withIdentifier: "home", sender: self)
        }))
        
        // add a tap gesture to the screen so that when tapped all of the controls are hidden
        let hide = UITapGestureRecognizer(target: self, action: #selector(hideButtons))
        videoOut.addGestureRecognizer(hide)
        
        // Do any additional setup after loading the view.
    }
    
    //setup Hide buttons function
    var hideButton = false
    @objc func hideButtons(){
        if hideButton == false {
            hideButton = true
            playButton.isHidden = true
            exitButton.isHidden = true
            totalTimeOut.isHidden = true
        } else if hideButton == true {
            hideButton = false
            playButton.isHidden = false
            exitButton.isHidden = false
            totalTimeOut.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to pull down the necessary information from the database
    func getProgramVid(time: String, path: String, type: String, prog: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        //let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child("Programs").child(path).child(time).child(type).child(prog).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            print("Yes")
            print(snapshot)
            for snap in snapshots! {
                if snap.childSnapshot(forPath: "name").exists() {
                let name    = snap.childSnapshot(forPath: "name").value as! String
                let video   = snap.childSnapshot(forPath: "video").value as! String
                let time    = snap.childSnapshot(forPath: "time").value as! Int
                let audio   = snap.childSnapshot(forPath: "audio").value as! String
                print(name)
                print("*********")
                
                let mv = medVideos(name: name, video: video, time: time, audio: audio)
                
                self.medVidArray.append(mv)
                }
            }
            completionHandler(true)
            
        })
        
    }
    
    // Once program is skipped or completed the database will be updated with the program information
    
    
    // Array of all the videos in the selected program
    var medVidArray: [medVideos] = []

    
    
    
}
