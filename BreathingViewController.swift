//
//  BreathingViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 12/19/17.
//  Copyright © 2017 Amped. All rights reserved.
//

import UIKit
import AudioToolbox
import AudioUnit
import AVFoundation
import Firebase
import SwiftySound
import ImageSlideshow
import FirebaseStorage
//import Kingfisher

class BreathingViewController: UIViewController {
    
    var kingSourceOne: [KingfisherSource] = []
    var kingSourceTwo: [KingfisherSource] = []
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    var medPlayer: AVPlayer?
    var focusPlayer: AVPlayer?
    var sleepPlayer: AVPlayer?
    var relaxPlayer: AVPlayer?
    var playerItem: AVPlayerItem?
    var sizeW = UIScreen.main.bounds.width
    @IBOutlet weak var beatButtonsConstraint: NSLayoutConstraint!
    //let binauralBeat = BinauralBeat()
    let app = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var breathingBackground: UIImageView!
    @IBOutlet weak var BreathingTiming: UILabel!
    @IBOutlet weak var totalBreathingTimeOut: UILabel!
   // @IBOutlet weak var toneLabel: UILabel!
   // @IBOutlet weak var toneOut: UILabel!
   // @IBOutlet weak var toneSlider: UISlider!
   // @IBOutlet weak var beatLabel: UILabel!
   // @IBOutlet weak var beatOut: UILabel!
   // @IBOutlet weak var beatSlider: UISlider!
    //@IBOutlet weak var toneSliderValue: UISlider!
   // @IBOutlet weak var beatZoneLabel: UILabel!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var meditateButton: UIButton!
    @IBOutlet weak var relaxButton: UIButton!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var beatsLabel: UILabel!
    @IBOutlet weak var beatsSelectLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    var remainingTime: Int!
    var beats: Bool?
    var beatsAdded = false
    var totalBreathingTime = 0
    var totalTimer = Timer()
    var breathingTimer = Timer()
    var totalTime = 0
    var exSelected: Bool!
    var fourSixBool = false
    var fiveFiveBool = false
    var fiveSevenBool = false
    var cream: Bool!
    var tape: Bool!
    
    var fourSixInhale = 4
    var fourSixExhale = 0
    
    var fiveFiveInhale = 5
    var fiveFiveExhale = 0
    
    var fiveSevenInhale = 5
    var fiveSevenExhale = 0
    
    var sessionSkipped = 0
    
    var breathingOnly = false
    
    var pathway = ""
    var PrescriptionTwoImage: [UIImage] = []
    var prescriptionTimeTwo = 0
    var preTwoTitle: String?
    
    var PrescriptionThreeImage: [UIImage] = []
    var prescriptionTimeThree = 0
    var preThreeTitle: String?
    var numbOfPre: Int?
    var orgName: String!
    var dateFormat = DateFormatter()
    
    var progType: String!
    var progArea: String!
    
    let alert = UIAlertController(title: "Amplify your Breathing Session", message: "Add Binarual Beats to your breathing Session - YOU NEED TO CONNECT HEADPHONES TO USE THIS FEATURE", preferredStyle: .alert)
    let alertTwo = UIAlertController(title: "Session Paused", message: "Do you  also want to stop the Binarual Beats  Session", preferredStyle: .alert)
    let alertThree = UIAlertController(title: "SKIP SESSION", message: "Do you want skip the rest of your session?", preferredStyle: .alert)
    
    
    @IBOutlet weak var fourSixButton: UIButton!
    @IBOutlet weak var fiveFiveButton: UIButton!
    @IBOutlet weak var fiveSevenButton: UIButton!
    
    @IBOutlet weak var breathingRatioLabel: UILabel!
    @IBOutlet weak var skipLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var skipButtonNo: UIButton!
    
    func ButtonSettings(Name: UIButton){
        Name.layer.backgroundColor = UIColor.white.cgColor
        Name.setTitleColor(.black, for: .normal)
        Name.layer.borderWidth = 2
        Name.layer.borderColor = UIColor.white.cgColor
    }
    
    
    func ButtonSettingsReset(Name: UIButton){
        Name.layer.backgroundColor = UIColor.clear.cgColor
        Name.setTitleColor(.white, for: .normal)
        Name.layer.borderWidth = 2
        Name.layer.borderColor = UIColor.white.cgColor
    }
    
    func setBinarual ( tFreq: Float, bFreq: Float) {
       // binauralBeat.baseFrequency = tFreq
        //binauralBeat.beatFrequency = bFreq
    }
    
    func fourSixButtonReset() {
        fourSixBool = false
        ButtonSettingsReset(Name: fourSixButton)
        fourSixInhale = 4
        fourSixExhale = 0
        
    }
    
    func fiveFiveButtonReset() {
        fiveFiveBool = false
        ButtonSettingsReset(Name: fiveFiveButton)
        fiveFiveInhale = 5
        fiveFiveExhale = 0
        
    }
    
    func fiveSevenButtonReset() {
        fiveSevenBool = false
        ButtonSettingsReset(Name: fiveSevenButton)
        fiveSevenInhale = 5
        fiveSevenExhale = 0
        
    }
    
    
    
    func totalTimeCalc() {
        totalBreathingTime = totalBreathingTime * 60
        //let hours = Int(time!) / 3600
        let minutes = Int(totalBreathingTime / 60 ) % 60
        let seconds = Int(totalBreathingTime) % 60
        totalBreathingTimeOut.text = String(format: "%02i:%02i", minutes, seconds)
    }
    
    @objc func totalTimeUpdate(){
        if totalBreathingTime > 0 {
            totalBreathingTime = totalBreathingTime - 1
            
            let minute = Int(totalBreathingTime / 60) % 60
            let second = Int(totalBreathingTime) % 60
            totalBreathingTimeOut.text = String(format: "%01i:%02i", minute, second)
            
        }
        else {
            AudioServicesPlayAlertSound(1005)
            totalTimer.invalidate()
            breathingTimer.invalidate()
        }
    }
    
    
    @IBAction func fourSixButtonOption(_ sender: Any) {
        breathingRatioLabel.isHidden = true
        if fourSixBool == false {
        ButtonSettings(Name: fourSixButton)
            //fourSixInhale = fourSixInhale * 60
            //let hours = Int(time!) / 3600
            //let minutes = Int(fourSixInhale / 60 ) % 60
            let seconds = Int(fourSixInhale) % 60
            BreathingTiming.text = String(format: "%01i", seconds)
        fiveFiveButtonReset()
        fiveSevenButtonReset()
        fourSixBool = true
        }

    }
    @IBAction func fiveFiveButtonOption(_ sender: Any) {
        breathingRatioLabel.isHidden = true
        if fiveFiveBool == false {
        ButtonSettings(Name: fiveFiveButton)
            if fiveFiveInhale < 10 {
        //fiveFiveInhale = fiveFiveInhale * 60
        //let hours = Int(time!) / 3600
        //let minutes = Int(fourSixInhale / 60 ) % 60
        let seconds = Int(fiveFiveInhale) % 60
        BreathingTiming.text = String(format: "%01i", seconds)
        }
        fourSixButtonReset()
        fiveSevenButtonReset()
        fiveFiveBool = true
        }
    }
    
    @IBAction func fiveSevenButtonOption(_ sender: Any) {
        breathingRatioLabel.isHidden = true
        if fiveSevenBool == false {
        ButtonSettings(Name: fiveSevenButton)
        //fiveSevenInhale = fiveSevenInhale * 60
        //let hours = Int(time!) / 3600
        //let minutes = Int(fourSixInhale / 60 ) % 60
        let seconds = Int(fiveSevenInhale) % 60
        BreathingTiming.text = String(format: "%01i", seconds)
        fourSixButtonReset()
        fiveFiveButtonReset()
        fiveSevenBool = true
        }
    }
    
    
    @objc func breathingTimeUpdate(){
        if fourSixBool == true {
            if fourSixInhale > 1 {
            fourSixInhale = fourSixInhale - 1
                
                UIView.animate(withDuration: 4.2, animations: {
                    self.bubbleView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                })

            let second = Int(fourSixInhale) % 60
                BreathingTiming.textColor = UIColor.white
            BreathingTiming.text = String(format: "%01i", second)
            print(fourSixInhale)
                print(fourSixExhale)
        } else if fourSixInhale <= 1 && fourSixExhale < 6 {
            fourSixExhale = fourSixExhale + 1
                UIView.animate(withDuration: 6.5, animations: {
                    self.bubbleView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
                
            let second = Int(fourSixExhale) % 60
            BreathingTiming.textColor = UIColor.cyan
            BreathingTiming.text = String(format: "%01i", second)
            
        } else if fourSixExhale >= 6{
                let second = 4
                BreathingTiming.textColor = UIColor.white
                BreathingTiming.text = String(format: "%01i", second)
               
        fourSixInhale = 4
        fourSixExhale = 0
        }

        }
        
        if fiveFiveBool == true {
            if fiveFiveInhale > 1 {
                fiveFiveInhale = fiveFiveInhale - 1
                
                UIView.animate(withDuration: 5.2, animations: {
                    self.bubbleView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                })
                
                let second = Int(fiveFiveInhale) % 60
                BreathingTiming.textColor = UIColor.white
                BreathingTiming.text = String(format: "%01i", second)
                
            } else if fiveFiveInhale <= 1 && fiveFiveExhale < 5 {
                fiveFiveExhale = fiveFiveExhale + 1
                UIView.animate(withDuration: 5.5, animations: {
                    self.bubbleView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
                let second = Int(fiveFiveExhale) % 60
                BreathingTiming.textColor = UIColor.cyan
                BreathingTiming.text = String(format: "%01i", second)
               
            } else if fiveFiveExhale >= 5{
                let second = 5
                BreathingTiming.textColor = UIColor.white
                BreathingTiming.text = String(format: "%01i", second)
                fiveFiveInhale = 5
                fiveFiveExhale = 0
            }
        }
        
        if fiveSevenBool == true {
            if fiveSevenInhale > 1 {
                fiveSevenInhale = fiveSevenInhale - 1
                
                UIView.animate(withDuration: 5.2, animations: {
                    self.bubbleView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                })
                let second = Int(fiveSevenInhale) % 60
                BreathingTiming.textColor = UIColor.white
                BreathingTiming.text = String(format: "%01i", second)
               
            } else if fiveSevenInhale <= 1 && fiveSevenExhale < 7 {
                fiveSevenExhale = fiveSevenExhale + 1
                
                UIView.animate(withDuration: 7.5, animations: {
                    self.bubbleView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
                let second = Int(fiveSevenExhale) % 60
                BreathingTiming.textColor = UIColor.cyan
                BreathingTiming.text = String(format: "%01i", second)
                
            } else if fiveSevenExhale >= 7{
                let second = 5
                BreathingTiming.textColor = UIColor.white
                BreathingTiming.text = String(format: "%01i", second)
                fiveSevenInhale = 5
                fiveSevenExhale = 0
            }
        }
        
    }
    
    
    
    func playSound(soundUrl: String) {
        let sound = URL(fileURLWithPath: soundUrl)
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: sound)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    /*
    func playBinauralSound(name: String){
        let url = Bundle.main.url(forResource: "Sleep", withExtension: "wav")
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            medPlayer = try AVAudioPlayer(contentsOf: url!, fileTypeHint: AVFileType.wav.rawValue)
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            print("TRYING TO PLAY" )
            medPlayer.volume = 0
            medPlayer.numberOfLoops = -1
            medPlayer.setVolume(1, fadeDuration: 5)
            medPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    */
    
    @IBAction func sleepButtonAction(_ sender: Any) {
        ButtonSettings(Name: sleepButton)
        ButtonSettingsReset(Name: meditateButton)
        ButtonSettingsReset(Name: relaxButton)
        ButtonSettingsReset(Name: focusButton)
        //Sound.stopAll()
        //Sound.play(file: "Sleep15.(.02in:out)wav", fileExtension: "wav", numberOfLoops: -1)
        focusPlayer?.pause()
        relaxPlayer?.pause()
        medPlayer?.pause()
        sleepPlayer?.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            // report for an error
        }
        sleepPlayer!.play()
        
        
        //playBinauralSound(name: "Delta Waves (Sleep)")
    
        
    }
    
    @IBAction func meditateButtonAction(_ sender: Any) {
        ButtonSettings(Name: meditateButton)
        ButtonSettingsReset(Name: sleepButton)
        ButtonSettingsReset(Name: relaxButton)
        ButtonSettingsReset(Name: focusButton)
        //Sound.stopAll()
        //Sound.play(file: "Meditate15 (.02in:out)", fileExtension: "wav", numberOfLoops: -1)
        sleepPlayer?.pause()
        relaxPlayer?.pause()
        focusPlayer?.pause()
        medPlayer?.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            // report for an error
        }
        medPlayer!.play()
    }
    
    @IBAction func relaxButtonAction(_ sender: Any) {
        ButtonSettings(Name: relaxButton)
        ButtonSettingsReset(Name: meditateButton)
        ButtonSettingsReset(Name: sleepButton)
        ButtonSettingsReset(Name: focusButton)
        //Sound.stopAll()
        //Sound.play(file: "Relax15 (.02in:out)", fileExtension: "wav", numberOfLoops: -1)
        sleepPlayer?.pause()
        focusPlayer?.pause()
        medPlayer?.pause()
        relaxPlayer?.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            // report for an error
        }
        relaxPlayer!.play()
    }
    @IBAction func focusButtonAction(_ sender: Any) {
        ButtonSettings(Name: focusButton)
        ButtonSettingsReset(Name: meditateButton)
        ButtonSettingsReset(Name: relaxButton)
        ButtonSettingsReset(Name: sleepButton)
        //Sound.stopAll()
        
        //player!.pause()
        //if player?.currentItem == FocusTone{
        //    player!.pause()
        //} else {
        sleepPlayer?.pause()
        relaxPlayer?.pause()
        medPlayer?.pause()
        focusPlayer?.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            // report for an error
        }
        focusPlayer!.play()
       // }
        //Sound.play(url: soundURL!)
        
        
        //Sound.play(file: "Focus15 (.02 in:out)", fileExtension: "wav", numberOfLoops: -1)
    }
    
    
    var playSelected = false
    @IBAction func playTimers(_ sender: Any) {
        if playSelected == false {
    if totalBreathingTime > 0{
        if fourSixBool == false && fiveFiveBool == false && fiveSevenBool == false {
            
        } else {
        playSelected = true
    totalTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(BreathingViewController.totalTimeUpdate), userInfo: nil, repeats: true)
        
    breathingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(BreathingViewController.breathingTimeUpdate), userInfo: nil, repeats: true)
    
    
        fourSixButton.isHidden = true
        fiveFiveButton.isHidden = true
        fiveSevenButton.isHidden = true
        breathingRatioLabel.isHidden = true
        self.present(alert, animated: true)
            }
            }
    }
}
    
    @IBAction func pauseTimers(_ sender: Any) {
        if playSelected == true {
            playSelected = false
        totalTimer.invalidate()
        breathingTimer.invalidate()
            sleepPlayer?.pause()
            focusPlayer?.pause()
            medPlayer?.pause()
            relaxPlayer?.pause()
         //binauralBeat.playing ? binauralBeat.stop() : binauralBeat.stop()
        fourSixButton.isHidden = false
        fiveFiveButton.isHidden = false
        fiveSevenButton.isHidden = false
        breathingRatioLabel.isHidden = false
            if beatsAdded == true{
        self.present(alertTwo, animated: true)
            }
        }
    }

    @IBAction func NextButton(_ sender: Any) {
        print(totalBreathingTime)
        if totalBreathingTime == 0 {
            if beats == true && totalBreathingTime != totalTime {
                performSegue(withIdentifier: "beats", sender: self)
            }
            if breathingOnly == false {
            performSegue(withIdentifier: "pre", sender: self)
            }
            if breathingOnly == true {
                var time = self.totalBreathingTime / 60
                Functions.updatePathwayInfo(company: self.orgName, program: self.progType, prog: self.progArea, pathway: self.pathway, stus: "Completed", time: "\(time) Min", timeCompleted: self.totalBreathingTime * 60 )
                
                performSegue(withIdentifier: "backToStart", sender: self)
            }
        }
            else  {
            self.present(alertThree, animated: true)
            
            totalTimer.invalidate()
            breathingTimer.invalidate()
        }
        
    }
    
    @objc func reEnter(){
        if app.timeStampIn == 0.0 {
            
        } else {
            print("WE MADE IT THIS FAR")
            totalBreathingTime = totalBreathingTime + Int(app.timeStampIn)
            if totalBreathingTime <= 0 {
                totalBreathingTimeOut.text = "00:00"
            }
        }
    }
    var FocusTone: AVPlayerItem!
    var sleepTone: AVPlayerItem!
    var relaxTone: AVPlayerItem!
    var medTone: AVPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Breathing only = \(breathingOnly)")
        storageRef = Storage.storage().reference()
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        Sound.enabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(reEnter), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        let focusSoundURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/programs%2FMindset%2FBinuaralBeatsTones%2FFocus15%20(.02%20in%3Aout).wav?alt=media&token=d621ec53-05cf-47ad-a21d-5d2fd3b53de4")
        FocusTone = AVPlayerItem(url: focusSoundURL!)
        focusPlayer = AVPlayer(playerItem: FocusTone)

        let sleepSoundURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/programs%2FMindset%2FBinuaralBeatsTones%2FSleep15.(.02in%3Aout)wav.wav?alt=media&token=1d14db95-8a34-4f10-9961-e9b361989967")
        sleepTone = AVPlayerItem(url: sleepSoundURL!)
        sleepPlayer = AVPlayer(playerItem: sleepTone)
        
        let medSoundURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/programs%2FMindset%2FBinuaralBeatsTones%2FMeditate15%20(.02in%3Aout).wav?alt=media&token=bf01dc0f-28f1-4805-a0c1-0745ca2cf201")
        medTone = AVPlayerItem(url: medSoundURL!)
        medPlayer = AVPlayer(playerItem: medTone)
        
        let relaxSoundURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/programs%2FMindset%2FBinuaralBeatsTones%2FRelax15%20(.02in%3Aout).wav?alt=media&token=95bce23b-7578-4aba-8c36-efec5f18906f")
        relaxTone = AVPlayerItem(url: relaxSoundURL!)
        relaxPlayer = AVPlayer(playerItem: relaxTone)
        
        if sizeW > 375 {
            beatButtonsConstraint.constant = 30
        }
        
        bubbleView.layer.cornerRadius = bubbleView.frame.width / 2
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
            print("YOU SAID YES")
            //self.binauralBeat.playing ? self.binauralBeat.play() : self.binauralBeat.play()
            self.sleepPlayer?.pause()
            self.focusPlayer?.pause()
            self.medPlayer?.pause()
            self.relaxPlayer?.pause()
            self.beatsLabel.isHidden = false
            self.beatsSelectLabel.isHidden = false
            self.sleepButton.isHidden = false
            self.meditateButton.isHidden = false
            self.relaxButton.isHidden = false
            self.focusButton.isHidden = false
            self.beatsAdded = true
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        
        alertTwo.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
            //self.binauralBeat.playing ? self.binauralBeat.stop() : self.binauralBeat.stop()
            self.sleepPlayer?.pause()
            self.focusPlayer?.pause()
            self.medPlayer?.pause()
            self.relaxPlayer?.pause()
            self.beatsLabel.isHidden = true
            self.beatsSelectLabel.isHidden = true
            self.sleepButton.isHidden = true
            self.meditateButton.isHidden = true
            self.relaxButton.isHidden = true
            self.focusButton.isHidden = true
           
            
        }))
        
        alertTwo.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        
        alertThree.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
            Sound.stopAll()
            self.sleepPlayer?.pause()
            self.focusPlayer?.pause()
            self.medPlayer?.pause()
            self.relaxPlayer?.pause()
            if self.breathingOnly == false {
                if self.beats == true {
                    if self.prescriptionTimeTwo == 0 {
                        print("MADE IT")
                        self.performSegue(withIdentifier: "breathingOnly", sender: self)
                    } else {
                    self.performSegue(withIdentifier: "beats", sender: self)
                }
                } else {
                    self.performSegue(withIdentifier: "pre", sender: self)
                
                }
            }
            if self.breathingOnly == true {
                var time = self.totalBreathingTime / 60
                Functions.updatePathwayInfo(company: self.orgName, program: self.progType, prog: self.progArea, pathway: self.pathway, stus: "Completed", time: "\(time) Min", timeCompleted: self.totalBreathingTime )
                
                self.performSegue(withIdentifier: "backToStart", sender: self)
            }
            
        }))
        
        alertThree.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action) in
            self.totalBreathingTimeOut.isHidden = false
            self.BreathingTiming.isHidden = false
            self.fourSixButton.isHidden = false
            self.fiveFiveButton.isHidden = false
            self.fiveSevenButton.isHidden = false
            self.breathingRatioLabel.isHidden = false
            //self.beatZoneLabel.isHidden = false
        }))
        
        if breathingOnly == true {
            totalTimeCalc()
        } else if beats == true {
            remainingTime = totalTime - totalBreathingTime
            totalTimeCalc()
        } else {
        totalTimeCalc()
        }
        // set button border size and color
        self.fourSixButton.layer.borderWidth = 2
        self.fourSixButton.layer.borderColor = UIColor.white.cgColor
        self.fourSixButton.layer.cornerRadius = 5.0
        
        
        self.fiveFiveButton.layer.borderWidth = 2
        self.fiveFiveButton.layer.borderColor = UIColor.white.cgColor
        self.fiveFiveButton.layer.cornerRadius = 5.0
        
        self.fiveSevenButton.layer.borderWidth = 2
        self.fiveSevenButton.layer.borderColor = UIColor.white.cgColor
        self.fiveSevenButton.layer.cornerRadius = 5.0
        
        ButtonSettingsReset(Name: focusButton)
        ButtonSettingsReset(Name: meditateButton)
        ButtonSettingsReset(Name: relaxButton)
        ButtonSettingsReset(Name: sleepButton)
        
        // Do any additional setup after loading the view.
    }
    
    func updatePathwayInfo(company: String, program: String, prog: String, pathway: String, stus: String!, time: String!) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        dateFormat.dateFormat =  "MMM d,yyyy h:mm:ss a"//"hh:mm:ss    dd-MM-yyyy"   //"yyyy-MM-dd hh:mm:ss"
        let sessionDate = dateFormat.string(from: Date())
        self.ref.child(company).child(userID).child("Scores").child("Sessions").child(sessionDate).updateChildValues([program : prog, "Pathway" : pathway, "Status": stus, "Time": time])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if let SecondViewController = segue.destination as? SecondViewController { SecondViewController.PrescriptionTwoImage = PrescriptionTwoImage;
            SecondViewController.prescriptionTimeTwo = prescriptionTimeTwo
            SecondViewController.preTwoTitle = preTwoTitle
            
            SecondViewController.PrescriptionThreeImage = PrescriptionThreeImage;
            SecondViewController.prescriptionTimeThree = prescriptionTimeThree;
            SecondViewController.preThreTitle = preThreeTitle;
            SecondViewController.numbOfPre = numbOfPre!;
            SecondViewController.cream = cream;
            SecondViewController.tape = tape;
            SecondViewController.kingSourceOne = kingSourceOne;
            SecondViewController.kingSourceTwo = kingSourceTwo;
        }
        
        if let BinauralViewController = segue.destination as? BinauralViewController { BinauralViewController.totalSessionTime = remainingTime;
            
        }*/
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
