//
//  orgLockerMenuViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 9/10/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase

class orgLockerMenuViewController: UIViewController {

    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    
    var lockerEquipment: [String] = []
    var pathway = ""
    var room = ""
    var locker = ""
    var orgName = ""
    var location = ""
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var roomOne: UIButton!
    @IBOutlet weak var roomTwo: UIButton!
    @IBOutlet weak var roomThree: UIButton!
    @IBOutlet weak var roomFour: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func homeButton(_ sender: Any) {
        
        location = "AtHome"
        roomButtonSettings(Name: homeButton)
        roomButtonReset(Name: roomOne)
        roomButtonReset(Name: roomTwo)
        roomButtonReset(Name: roomThree)
        roomButtonReset(Name: roomFour)
    }
    
    
    @IBAction func roomOne(_ sender: Any) {
        lockerEquipment.removeAll()
        loadLockerData(loc: "One")
        location = "One"
        app.room = "One"
        roomButtonSettings(Name: roomOne)
        roomButtonReset(Name: roomTwo)
        roomButtonReset(Name: roomThree)
        roomButtonReset(Name: roomFour)
        roomButtonReset(Name: homeButton)
    }
    
    @IBAction func roomTwoButton(_ sender: Any) {
        lockerEquipment.removeAll()
        loadLockerData(loc: "Two")
        location = "Two"
        app.room = "Two"
        roomButtonSettings(Name: roomTwo)
        roomButtonReset(Name: roomOne)
        roomButtonReset(Name: roomThree)
        roomButtonReset(Name: roomFour)
        roomButtonReset(Name: homeButton)
    }
    
    @IBAction func roomThreeButton(_ sender: Any) {
        lockerEquipment.removeAll()
        loadLockerData(loc: "Three")
        location = "Three"
        app.room = "Three"
        roomButtonSettings(Name: roomThree)
        roomButtonReset(Name: roomTwo)
        roomButtonReset(Name: roomOne)
        roomButtonReset(Name: roomFour)
        roomButtonReset(Name: homeButton)
    }
    
    @IBAction func roomFourButton(_ sender: Any) {
        lockerEquipment.removeAll()
        loadLockerData(loc: "Four")
        location = "Four"
        app.room = "Four"
        roomButtonSettings(Name: roomFour)
        roomButtonReset(Name: roomTwo)
        roomButtonReset(Name: roomThree)
        roomButtonReset(Name: roomOne)
        roomButtonReset(Name: homeButton)
        
    }
    
    @IBAction func startButton(_ sender: Any) {
        if pathway != "AmpedRx" {
            performSegue(withIdentifier: "DemoTwo", sender: self)
        } else {
            performSegue(withIdentifier: "DemoOne", sender: self)
        }
    }
    
    
    func roomButtonSettings(Name: UIButton){
        Name.layer.backgroundColor = UIColor.white.cgColor
        Name.setTitleColor(.black, for: .normal)
        Name.layer.borderWidth = 2
        Name.layer.borderColor = UIColor.white.cgColor
    }
    
    func roomButtonReset(Name: UIButton){
        Name.layer.backgroundColor = UIColor.clear.cgColor
        Name.setTitleColor(.white, for: .normal)
        Name.layer.borderWidth = 2
        Name.layer.borderColor = UIColor.white.cgColor
        
    }
    
    func initialButtonSettings(name: UIButton){
        name.layer.backgroundColor = UIColor.clear.cgColor
        name.setTitleColor(.white, for: .normal)
        name.layer.borderWidth = 2
        name.layer.borderColor = UIColor.white.cgColor
        name.layer.cornerRadius = 5.0
    }
    
    func setAtHomeModalities(passOrg: String, locker: String, passModality: String, completionHandler:@escaping (_ status: Bool)-> Void) {
    
        ref.child(passOrg).child("lockers").child(locker).child(passModality).observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let result = snapshot.value as? Bool
                else {
                    completionHandler(false)
                    print("NO")
                    return
            }
            completionHandler(result)
        })
    }
    
    func loadLockerData(loc: String){
        print("LOCKER EQUIP")
        
        //setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Mobility Exercises") { (result) in if result == true {self.lockerEquipment.append("MobEx")}}
        //Compression
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Compression Legs") { (result) in if result == true {self.lockerEquipment.append("Normatec")}}
        //setAtHomeModalities(passOrg: company, locker: locker, passModality: "Compression Arms") { (result) in if result == true {self.lockerEquipment.append("Normatec")}}
        //setAtHomeModalities(passOrg: company, locker: locker, passModality: "Compression Hips") { (result) in if result == true {self.lockerEquipment.append("Normatec")}}
        
        //Thermal Therapy
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Shower") { (result) in if result == true {self.lockerEquipment.append("Shower")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Water Immersion") { (result) in if result == true {self.lockerEquipment.append("Bath")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Ice") { (result) in if result == true {self.lockerEquipment.append("Ice")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Cold Compression") { (result) in if result == true {self.lockerEquipment.append("Game Ready")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Cryotherapy") { (result) in if result == true {self.lockerEquipment.append("Cryotherapy")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Heat Pack") { (result) in if result == true {self.lockerEquipment.append("Heat")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Sauna") { (result) in if result == true {self.lockerEquipment.append("Sauna")}}
        
        // Myofascial Equip
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Roller") { (result) in if result == true {self.lockerEquipment.append("Myofascial Roller")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Ball") { (result) in if result == true {self.lockerEquipment.append("Myofascial Ball")}}
        //setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Stick") { (result) in if result == true {self.lockerEquipment.append("Myofascial Stick")}}
        setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Floss Band") { (result) in if result == true {self.lockerEquipment.append("Floss Band")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Resistance Band") { (result) in if result == true {self.lockerEquipment.append("Resistance Band")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "IASTM") { (result) in if result == true {self.lockerEquipment.append("IASTM")}}
        //setAtHomeModalities(passOrg: orgName, locker: locker, passModality: "Kinesio Tape") { (result) in if result == true {self.lockerEquipment.append("Kinesio Tape")}}
        
        //Light Therapy
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "IR Sauna") { (result) in if result == true {self.lockerEquipment.append("IrSauna")}}
        
        //Electrical Muscle Stim
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Soreness Relief Unit") { (result) in if result == true {self.lockerEquipment.append("Compex")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Recovery Flush Unit") { (result) in if result == true {self.lockerEquipment.append("Marc Pro")}}
        
        // Vibration Therapy
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Vibration Hand Held") { (result) in if result == true {self.lockerEquipment.append("VibHH")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Vibration Plate") { (result) in if result == true {self.lockerEquipment.append("Vibration Plate")}}
        
        //Mindset Therapy
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "EGG Unit") { (result) in if result == true {self.lockerEquipment.append("Muse")}}
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Neurostimulation Unit") { (result) in if result == true {self.lockerEquipment.append("Thync")}}
        
        // Sensory Deprevation
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Float Tank") { (result) in if result == true {self.lockerEquipment.append("Float Tank")}}
        
        //Cream
        setAtHomeModalities(passOrg: orgName, locker: loc, passModality: "Cream") { (result) in if result == true {self.lockerEquipment.append("Cream")}}
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("The selected room is \(location)")
        print("The pathway is \(pathway)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(pathway)
        ref = Database.database().reference()
        orgName = "Animal Surf"
        
        initialButtonSettings(name: homeButton)
        initialButtonSettings(name: roomOne)
        initialButtonSettings(name: roomTwo)
        initialButtonSettings(name: roomThree)
        initialButtonSettings(name: roomFour)
        initialButtonSettings(name: startButton)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ProgramSelectionViewController = segue.destination as? ProgramSelectionViewController {
            ProgramSelectionViewController.room = location
            ProgramSelectionViewController.pathway = pathway
        }
        /*if let FirstViewController = segue.destination as? FirstViewController {
            //FirstViewController.timeSelected = timeOut
            FirstViewController.lockerEquipment = lockerEquipment
            FirstViewController.locker = locker
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
