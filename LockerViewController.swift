//
//  LockerViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/20/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import Kingfisher

class LockerViewController: UIViewController {
    
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    
    var orgName: String!
    var location = "AtHome"
    var setup = false
    var ud = UserDefaults.standard
    var percentage = 0.0
    
    
    let exitAlert = UIAlertController(title: "Available Programs", message: "", preferredStyle: .alert)
    
    let mobAlert = UIAlertController(title: "MOBILITY EXERCISES", message: "Mobility exercise are designated to focus on increasing flexibility to optimize physical performance and restore balance. \r\r\u{2022}Mobility is a necessary part of a well-balanced program for feeling better. \r\r\u{2022}These exercises can be performed with little or no equipment in any setting. \r\r\u{2022}Exercises can assist in improving range of motion of area targeted. \r\r\u{2022}Progressed based on comfort with no risk to injury or soreness.", preferredStyle: .alert)
    
    let compAlert = UIAlertController(title: "COMPRESSION THERAPY", message: "Compression Therapy units use a predetermined pulsed massage pattern and compressed air  sleeves to massage your hips, upper or lower body.  Therapy claims are: \r\r\u{2022}Mobilize fluid and metabolites out of the extremities. \r\r\u{2022}Enhance circulatory flow. \r\r\u{2022}Enhance flexibility and relax muscles through utilizing compression. \r\r\u{2022}Reduce recover time between sessions.", preferredStyle: .alert)
    
    let compArmAlert = UIAlertController(title: "COMPRESSION THERAPY", message: "Compression Therapy units use a predetermined pulsed massage pattern and compressed air  sleeves to massage your hips, upper or lower body.  Therapy claims are: \r\r\u{2022}Mobilize fluid and metabolites out of the extremities. \r\r\u{2022}Enhance circulatory flow. \r\r\u{2022}Enhance flexibility and relax muscles through utilizing compression. \r\r\u{2022}Reduce recover time between sessions.", preferredStyle: .alert)
    
    let compHipAlert = UIAlertController(title: "COMPRESSION THERAPY", message: "Compression Therapy units use a predetermined pulsed massage pattern and compressed air  sleeves to massage your hips, upper or lower body.  Therapy claims are: \r\r\u{2022}Mobilize fluid and metabolites out of the extremities. \r\r\u{2022}Enhance circulatory flow. \r\r\u{2022}Enhance flexibility and relax muscles through utilizing compression. \r\r\u{2022}Reduce recover time between sessions.", preferredStyle: .alert)
    
    let coldPackAlert = UIAlertController(title: "COLD PACK", message: "Cold packs or ice bags are a safe, portable and effective way to aid in addressing the body’s needs in feeling better. \r\r\u{2022}Sooth aches and soreness where the body needs it. \r\r\u{2022}Help increase flexibility and mobility. \r\r\u{2022}Increase circulation to applied area.", preferredStyle: .alert)
    
    let hotPackAlert = UIAlertController(title: "HOT PACK", message: "Dry Hot packs or moist heat packs are a safe, portable and effective way to aid in addressing the body’s needs in feeling better. \r\r\u{2022}Sooth aches and soreness where the body needs it. \r\r\u{2022}Help increase flexibility and mobility. \r\r\u{2022}Increase circulation to applied area.", preferredStyle: .alert)
    
    let coldShowerAlert = UIAlertController(title: "COLD SHOWER", message: "Cold shower provides an easy-to-access solution for feeling better using the temperature of cold water based on personal comfort.   \r\r\u{2022}Regulate the autonomic nervous system. \r\r\u{2022}Reduce body aches and soreness. \r\r\u{2022}Improve mental focus and sleep.\r\r\u{2022}Improve circulation through stimulation of nervous system.", preferredStyle: .alert)
    
    let coldBathAlert = UIAlertController(title: "COLD WATER IMMERSION", message: "Utilizing a tub, pool or even a lake, cold water immersion uses water with temperatures of 50 – 59F and can vary in time based on comfort and desire.   \r\r\u{2022}Stimulate the autonomic nervous system and help increase beta- endorphins \r\r\u{2022}Increase circulation and help flush metabolic waste.\r\r\u{2022}Improve mood and focus.\r\r\u{2022}Reduce inflammation caused from strenuous exercise or activity.", preferredStyle: .alert)
    
    let coldCompAlert = UIAlertController(title: "COLD COMPRESSION SLEEVE", message: "Using sleeves, wraps or cuffs designed for a specific body part or region, these accessories usually attach to a supply either electric or gravity feed water supply to provide continuous cooled water to the desired location.  \r\r\u{2022}Provide controlled temperature cooling to desired location. \r\r\u{2022}Compression helps reduce swelling and relax surrounding musculature.\r\r\u{2022}Soreness reduction related to musculoskeletal strains and sprains.\r\r\u{2022}Decrease inflammation.", preferredStyle: .alert)
    
    let wbCryoAlert = UIAlertController(title: "WHOLE BODY CRYOTHERAPY", message: "Whole Body Cryotherapy consists of a chamber that is either electric or nitrogen cooled and reaching temperatures as cold as -200F aimed at dropping the skin temperature without discomfort. Therapy claims are: \r\r\u{2022}Decrease soreness and improve joint range of motion and flexibility.  \r\r\u{2022}Improve mental focus and immunity.  \r\r\u{2022}Physical and mental health benefits from power release of endorphins.  \r\r\u{2022}Cold air provides a quicker and more comfortable session compared to cold water immersion.", preferredStyle: .alert)
    
    let saunaAlert = UIAlertController(title: "TRADITIONAL SAUNA", message: "Traditional Saunas use wood-burning, electric or natural gas to heat the chamber.  Whether moist (steam) or dry heat is chosen the temperatures in these saunas can reach as high as 150 to 180F. \r\r\u{2022}Heated air increases your body temperature and starts the body’s natural cooling process.  \r\r\u{2022}The heat brings blood closer to the skin improving circulation.  \r\r\u{2022}Brings relief to sore joints and muscles.  \r\r\u{2022}Relieves stress and mental fatigue.", preferredStyle: .alert)
    
    let myoMobAlert = UIAlertController(title: "MYOFASCIAL MOBILIZATION", message: "Using a roller, stick or ball, myofascial mobilization allows for targeting nerurotrigger points via self-massage.\r\r\u{2022}Roller, stick or ball differences in size and shape allow for different surface area contact and thus targeting body regions desired.  \r\r\u{2022}Improve range of motion and decrease muscle tension through customized massage.  \r\r\u{2022}Decrease soreness.  \r\r\u{2022}Portability allows for use in many different settings.", preferredStyle: .alert)
    
    let myoMobBallAlert = UIAlertController(title: "MYOFASCIAL MOBILIZATION", message: "Using a roller, stick or ball, myofascial mobilization allows for targeting nerurotrigger points via self-massage.\r\r\u{2022}Roller, stick or ball differences in size and shape allow for different surface area contact and thus targeting body regions desired.  \r\r\u{2022}Improve range of motion and decrease muscle tension through customized massage.  \r\r\u{2022}Decrease soreness.  \r\r\u{2022}Portability allows for use in many different settings.", preferredStyle: .alert)
    
    let myoMobStickAlert = UIAlertController(title: "MYOFASCIAL MOBILIZATION", message: "Using a roller, stick or ball, myofascial mobilization allows for targeting nerurotrigger points via self-massage.\r\r\u{2022}Roller, stick or ball differences in size and shape allow for different surface area contact and thus targeting body regions desired.  \r\r\u{2022}Improve range of motion and decrease muscle tension through customized massage.  \r\r\u{2022}Decrease soreness.  \r\r\u{2022}Portability allows for use in many different settings.", preferredStyle: .alert)
    
    let flossAlert = UIAlertController(title: "FLOSS BAND", message: "Floss bands use compressive elastic bands to target areas and help improve tissue quality and joint mechanics. \r\r\u{2022}Improve mobility and flexibility.  \r\r\u{2022}Help warm tissues by increasing blood flow to targeted area.  \r\r\u{2022}Compress swelling out of tissue and joints.  \r\r\u{2022}Portability allows for use in many different settings.", preferredStyle: .alert)
    
    let resistanceAlert = UIAlertController(title: "RESISTANCE BAND", message: "Resistance bands are elastic bands used to target specific areas and provide slight resistance.  This resistance can vary based on style of band and be used as pulling force or slight traction on area desired. \r\r\u{2022}Improve mobility and flexibility.  \r\r\u{2022}Help warm tissues by increasing blood flow to target area.  \r\r\u{2022}Slight resistance in targeted area allows for using push-pull techniques of muscle relaxation.  \r\r\u{2022}Portability allows for use in many different settings.", preferredStyle: .alert)
    
    let iastmAlert = UIAlertController(title: "IASTM", message: "Instrument assisted soft tissue mobilization (IASTM) tools are used as an enhanced scraping technique applied to the skin to influence fascial and neurological musculoskeletal improvements.  Therapy claims are: \r\r\u{2022}Improvement in joint range of motion and flexibility. \r\r\u{2022}Stimulation of the nervous system to reduce spasm.  \r\r\u{2022}increase activation that can aid in functional stability. ", preferredStyle: .alert)
    
    let irSaunaAlert = UIAlertController(title: "INFRARED SAUNA", message: "As a safe form of light therapy, these saunas use infrared and FAR infrared rays to introduce invisible waves of energy that have the ability to penetrate deep into most regions of tissue and muscles.  Therapy claims are: \r\r\u{2022}Increase surface temperature of the body to help improve mood and focus.  \r\r\u{2022}Increased circulation and detoxification from increase in sweating during session.  \r\r\u{2022}Relaxation by balancing the body’s level of cortisol.  \r\r\u{2022}Decreased soreness by relaxing muscles and decreasing inflammation", preferredStyle: .alert)
    
    let emsArAlert = UIAlertController(title: "ELECTRICAL MUSCLE STIM with Active Recovery Mode", message: "EMS with Active Recovery Mode uses safe electrical impulses of lower frequency to trigger action potentials of motoneurons of motor nerves in the muscles.  Involuntary contraction of the targeted muscle groups provides benefits to the user.   Therapy claims are: \r\r\u{2022}Increased blood flow and reduction of lactic acid for active recovery.  \r\r\u{2022}Decrease joint soreness and stiffness by reduction of tight muscles   \r\r\u{2022}Allows for re-engagement of targeted muscles for better performance potential. \r\r\u{2022}Unit portability allows for easy travel and application.", preferredStyle: .alert)
    
    let emsSrAlert = UIAlertController(title: "ELECTRICAL MUSCLE STIM with Soreness Relief Mode", message: "EMS with Soreness Relief Mode uses safe electrical impulses of higher frequency to provide soreness relief by altering the wave that travels through the muscle tissue.  The result is more significant and longer lasting relief of targeted area. \r\r\u{2022}Decrease soreness of affected area.  \r\r\u{2022}Longer lasting relief from aches of daily activities.  \r\r\u{2022}Unit portability allows for easy travel and application.", preferredStyle: .alert)
    
    let wbVibAlert = UIAlertController(title: "WHOLE BODY VIBRATION", message: "Utilizing a plate or platform that vibrates side to side or up and down, vibration is directed at the body to promote reflexive engagement of soft tissue.  Therapy claims are:\r\r\u{2022}Shorts session make it easy to incorporate into your day. \r\r\u{2022}Easy to use and can be used in combination with stretching or exercise.  \r\r\u{2022}Increase in flexibility, muscle activation  and mobility.  \r\r\u{2022}Increase in circulation.", preferredStyle: .alert)
    
    let hhVibAlert = UIAlertController(title: "HAND HELD VIBRATION", message: "Using a comfortable hand-held unit, engineered vibration is delivered to the body in the targeted area desired. Therapy claims are: \r\r\u{2022}Reduce soreness by overriding pain frequency. \r\r\u{2022}Increase range of motion in muscles and joints.  \r\r\u{2022}Improve circulation to assist body in reducing metabolites following training and activity. \r\r\u{2022}Unit portability allows for easy travel and application in many settings.", preferredStyle: .alert)
    
    let eggAlert = UIAlertController(title: "EGG UNIT", message: "EGG units allow user to get real time feedback of their current brainwave activity.  Utilizing moibile application driven programs you are guided into meditative states. Therapy claims are: \r\r\u{2022}Feedback of brain activity during session allows for improvement where it is needed.  \r\r\u{2022}Reduction of stress and improved mood. \r\r\u{2022}Application driven feedback allows for understanding your progress.", preferredStyle: .alert)
    
    let NeuroAlert = UIAlertController(title: "NEUROSTIMULATION UNIT", message: "Using low-energy waveforms paired with a streamlined mobile application, neurostimulation units stimulate nerves on your head allowing the relax or energize.  Therapy claims are: \r\r\u{2022}Utilizes the body’s natural ability to relax, without pills or drinks.  \r\r\u{2022}Helps the body achieve the theta state for deep relaxation.  \r\r\u{2022}Deeper relaxation improves sleep quality.  \r\r\u{2022}Mental stimulation increase focus and improves performance.", preferredStyle: .alert)
    
    let sensorAlert = UIAlertController(title: "SENSORY DEPREVATION", message: "Float pods and tanks use approximately 1000lbs of magnesium sulfate (Epsom salt) to create buoyancy in a heated solution, allowing the user to “float” experiencing the sensation of weightlessness.  Therapy claims are: \r\r\u{2022}Pods and tanks provide a light and sound free environment for optimal results.  \r\r\u{2022}Shift brainwave activity to a theta state, similar to meditation or deep relaxation.  \r\r\u{2022}Minimize stress on back, hips and joints. \r\r\u{2022}Improve circulation and reset your hormonal and metabolic balance.", preferredStyle: .alert)
    
    let creamAlert = UIAlertController(title: "Topical Cream", message: "", preferredStyle: .alert)
    
    let kTapeAlert = UIAlertController(title: "Kinesio Tape", message: "", preferredStyle: .alert)
    
    @IBOutlet weak var mobExButton: UIButton!
    @IBOutlet weak var creamButton: UIButton!
    @IBOutlet weak var showerButton: UIButton!
    @IBOutlet weak var bathButton: UIButton!
    @IBOutlet weak var coldPackButton: UIButton!
    @IBOutlet weak var heatPackButton: UIButton!
    @IBOutlet weak var coldCompButton: UIButton!
    @IBOutlet weak var rollerButton: UIButton!
    @IBOutlet weak var ballButton: UIButton!
    @IBOutlet weak var stickButton: UIButton!
    @IBOutlet weak var flossBandButton: UIButton!
    @IBOutlet weak var resistBandButton: UIButton!
    @IBOutlet weak var iastmButton: UIButton!
    @IBOutlet weak var kTapeButton: UIButton!
    @IBOutlet weak var vibHhButton: UIButton!
    @IBOutlet weak var wholeVibButton: UIButton!
    @IBOutlet weak var normLegButton: UIButton!
    @IBOutlet weak var normArmButton: UIButton!
    @IBOutlet weak var normHipButton: UIButton!
    @IBOutlet weak var irSaunaButton: UIButton!
    @IBOutlet weak var soreStimButton: UIButton!
    @IBOutlet weak var recStimButton: UIButton!
    @IBOutlet weak var museButton: UIButton!
    @IBOutlet weak var thyncButton: UIButton!
    @IBOutlet weak var saunaButton: UIButton!
    @IBOutlet weak var cryoButton: UIButton!
    @IBOutlet weak var floatButton: UIButton!
    
    
    var rollerOn: Bool!
    var ballOn: Bool!
    var stickOn: Bool!
    var legCompOn: Bool!
    var hipCompOn: Bool!
    var armCompOn = false
    var soreStimOn: Bool!
    var recStimOn: Bool!
    var cryoOn: Bool!
    var floatOn: Bool!
    var vibHHOn: Bool!
    var vibWbOn: Bool!
    var iastmOn: Bool!
    var flossBandOn: Bool!
    var irSaunaOn: Bool!
    var museOn: Bool!
    var thyncOn: Bool!
    var showerOn: Bool!
    var coldOn: Bool!
    var coldCompOn: Bool!
    var resistBandOn: Bool!
    var bathOn: Bool!
    var heatPackOn: Bool!
    var mobExOn = true
    var saunaOn: Bool!
    var creamOn: Bool!
    var KtapeOn: Bool!
    
    // Modality Buttons
    @IBAction func mobExButton(_ sender: Any) {
        ButtonAction(butt: mobExButton, buttBool: &mobExOn, alert: mobAlert)
    }
    
    @IBAction func creamButton(_ sender: Any) {
        ButtonAction(butt: creamButton, buttBool: &creamOn, alert: creamAlert)
    }
    
    @IBAction func showerButton(_ sender: Any) {
        ButtonAction(butt: showerButton, buttBool: &showerOn, alert: coldShowerAlert)
    }
    
    @IBAction func bathButton(_ sender: Any) {
        ButtonAction(butt: bathButton, buttBool: &bathOn, alert: coldBathAlert)
    }
    
    @IBAction func coldPackButton(_ sender: Any) {
        ButtonAction(butt: coldPackButton, buttBool: &coldOn, alert: coldPackAlert)
    }
    
    @IBAction func heatPackButton(_ sender: Any) {
        ButtonAction(butt: heatPackButton, buttBool: &heatPackOn, alert: hotPackAlert)
    }
    
    @IBAction func coldCompButton(_ sender: Any) {
        ButtonAction(butt: coldCompButton, buttBool: &coldCompOn, alert: coldCompAlert )
    }
    
    @IBAction func rollerButton(_ sender: Any) {
        ButtonAction(butt: rollerButton, buttBool: &rollerOn, alert: myoMobAlert)
    }
    
    @IBAction func ballButton(_ sender: Any) {
        ButtonAction(butt: ballButton, buttBool: &ballOn, alert: myoMobBallAlert)
    }
    
    @IBAction func stickButton(_ sender: Any) {
        ButtonAction(butt: stickButton, buttBool: &stickOn, alert: myoMobStickAlert)
    }
    
    @IBAction func flossBandButton(_ sender: Any) {
        ButtonAction(butt: flossBandButton, buttBool: &flossBandOn, alert: flossAlert)
    }
    
    @IBAction func resistBandButton(_ sender: Any) {
        ButtonAction(butt: resistBandButton, buttBool: &resistBandOn, alert: resistanceAlert)
    }
    
    @IBAction func iastmButton(_ sender: Any) {
        ButtonAction(butt: iastmButton, buttBool: &iastmOn, alert: iastmAlert)
    }
    
    @IBAction func kTapeButton(_ sender: Any) {
        ButtonAction(butt: kTapeButton, buttBool: &KtapeOn, alert: kTapeAlert)
    }
    
    @IBAction func vibHhButton(_ sender: Any) {
        ButtonAction(butt: vibHhButton, buttBool: &vibHHOn, alert: hhVibAlert)
    }
    
    @IBAction func vibPlateButton(_ sender: Any) {
        ButtonAction(butt: wholeVibButton, buttBool: &vibWbOn, alert: wbVibAlert)
    }
    
    @IBAction func legCompButton(_ sender: Any) {
        ButtonAction(butt: normLegButton, buttBool: &legCompOn, alert: compAlert)
    }
    
    @IBAction func armCompButton(_ sender: Any) {
        ButtonAction(butt: normArmButton, buttBool: &armCompOn, alert: compArmAlert)
    }
    
    @IBAction func hipCompButton(_ sender: Any) {
        ButtonAction(butt: normHipButton, buttBool: &hipCompOn, alert: compHipAlert)
    }
    
    @IBAction func irSaunaButton(_ sender: Any) {
        ButtonAction(butt: irSaunaButton, buttBool: &irSaunaOn, alert: irSaunaAlert)
    }
    
    @IBAction func soreStimButton(_ sender: Any) {
        ButtonAction(butt: soreStimButton, buttBool: &soreStimOn, alert: emsSrAlert )
    }
    
    @IBAction func recStimButton(_ sender: Any) {
        ButtonAction(butt: recStimButton, buttBool: &recStimOn, alert: emsArAlert)
    }
    
    @IBAction func museButton(_ sender: Any) {
        ButtonAction(butt: museButton, buttBool: &museOn, alert: eggAlert)
    }
    
    @IBAction func thyncButton(_ sender: Any) {
        ButtonAction(butt: thyncButton, buttBool: &thyncOn, alert: NeuroAlert)
    }
    
    @IBAction func saunaButton(_ sender: Any) {
        ButtonAction(butt: saunaButton, buttBool: &saunaOn, alert: saunaAlert)
    }
    
    @IBAction func cryoButton(_ sender: Any) {
        ButtonAction(butt: cryoButton, buttBool: &cryoOn, alert: wbCryoAlert)
    }
    
    @IBAction func floatButton(_ sender: Any) {
        ButtonAction(butt: floatButton, buttBool: &floatOn, alert: sensorAlert)
    }
    
    //Function to present alert and add to total percentage of program upon modality button tap
    func ButtonAction(butt: UIButton, buttBool: inout Bool, alert: UIAlertController){
        if buttBool != true {
            self.present(alert, animated: true)
            buttBool = true
            percentage = percentage + 3.7
            print(percentage)
        } else {
            percentage = percentage - 3.7
            print(percentage)
            buttBool = false
            setButtonState(button: butt, state: buttBool)
        }
        
    }
    
    //Function to set locker equipment for the user
    func setLocker(equipSwitch: Bool, org: String, lockerLocation: String, equipName: String){
        updateLocker(passOrg: org, locker: lockerLocation, equipment: equipName, status: equipSwitch)
        
    }
    
    // Update the database with the users locker equipment.
    func saveLocker(){
        setLocker(equipSwitch: mobExOn, org: orgName, lockerLocation: location, equipName: "Mobility Exercises")
        
        //Compression
        setLocker(equipSwitch: legCompOn, org: orgName, lockerLocation: location, equipName: "Compression Legs")
        setLocker(equipSwitch: armCompOn, org: orgName, lockerLocation: location, equipName: "Compression Arms")
        setLocker(equipSwitch: hipCompOn, org: orgName, lockerLocation: location, equipName: "Compression Hips")
        
        //Thermal Therapy
        setLocker(equipSwitch: showerOn, org: orgName, lockerLocation: location, equipName: "Shower")
        setLocker(equipSwitch: bathOn, org: orgName, lockerLocation: location, equipName: "Water Immersion")
        setLocker(equipSwitch: coldOn, org: orgName, lockerLocation: location, equipName: "Ice")
        setLocker(equipSwitch: coldCompOn, org: orgName, lockerLocation: location, equipName: "Cold Compression")
        setLocker(equipSwitch: cryoOn, org: orgName, lockerLocation: location, equipName: "Cryotherapy")
        setLocker(equipSwitch: heatPackOn, org: orgName, lockerLocation: location, equipName: "Heat Pack")
        setLocker(equipSwitch: saunaOn, org: orgName, lockerLocation: location, equipName: "Sauna")
        
        //Myofascial Equip
        setLocker(equipSwitch: rollerOn, org: orgName, lockerLocation: location, equipName: "Roller")
        setLocker(equipSwitch: ballOn, org: orgName, lockerLocation: location, equipName: "Ball")
        setLocker(equipSwitch: stickOn, org: orgName, lockerLocation: location, equipName: "Stick")
        setLocker(equipSwitch: flossBandOn, org: orgName, lockerLocation: location, equipName: "Floss Band")
        setLocker(equipSwitch: resistBandOn, org: orgName, lockerLocation: location, equipName: "Resistance Band")
        setLocker(equipSwitch: iastmOn, org: orgName, lockerLocation: location, equipName: "IASTM")
        setLocker(equipSwitch: KtapeOn, org: orgName, lockerLocation: location, equipName: "Kinesio Tape")
        
        //Light Therapy
        setLocker(equipSwitch: irSaunaOn, org: orgName, lockerLocation: location, equipName: "IR Sauna")
        
        // Electrical Muscle Stimulation
        setLocker(equipSwitch: recStimOn, org: orgName, lockerLocation: location, equipName: "Recovery Flush Unit")
        setLocker(equipSwitch: soreStimOn, org: orgName, lockerLocation: location, equipName: "Soreness Relief Unit")
        
        // Vibration Therapy
        setLocker(equipSwitch: vibHHOn, org: orgName, lockerLocation: location, equipName: "Vibration Hand Held")
        setLocker(equipSwitch: vibWbOn, org: orgName, lockerLocation: location, equipName: "Vibration Plate")
        
        //Mindset Therapy
        setLocker(equipSwitch: museOn, org: orgName, lockerLocation: location, equipName: "EGG Unit")
        setLocker(equipSwitch: thyncOn, org: orgName, lockerLocation: location, equipName: "Neurostimulation Unit")
        
        // Sensory Deprevation
        setLocker(equipSwitch: floatOn, org: orgName, lockerLocation: location, equipName: "Float Tank")
        
        //Cream
        setLocker(equipSwitch: creamOn, org: orgName, lockerLocation: location, equipName: "Cream")
    }
    
    // Save button action
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveButton(_ sender: Any) {
        
        // update the locker on the database for the users
        saveLocker()
        let perc = Int(percentage)
        //Update the exit alert to output the percentage of programs availble to the user
        exitAlert.message = "You have access to \(perc)% of AmpedRx programs"
        self.present(exitAlert, animated: true)
    }
    
    // Pull down the users locker information from the database
    func setlockerEquip(passOrg: String, passLocker: String, equip: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        ref.child(passOrg).child(userID).child("lockers").child(passLocker).child(equip).observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let result = snapshot.value as? Bool
                else {
                    completionHandler(false)
                    return
            }
            completionHandler(result)
        })
    }
    
    // Update the specific locker information
    func updateLocker(passOrg: String, locker: String, equipment: String, status: Bool) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        self.ref.child(passOrg).child(userID).child("lockers").child(locker).updateChildValues([equipment : status])
    }
    
    //Function to setup the UI for the buttons upon tap
    func setButtonState(button: UIButton, state: Bool){
        if state == true {
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 2.0
            button.layer.cornerRadius = 5.0
            button.layer.masksToBounds = true
        } else {
            button.layer.borderColor = UIColor.clear.cgColor
            button.layer.borderWidth = 2.0
            button.layer.cornerRadius = 5.0
            button.layer.masksToBounds = true
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("LOADING")
        // Pull information from DATABASE
        orgName = app.scores.value(forKey: "organization") as! String
        
        //Setup the locker on device based on information from database - UI, Bool State, and percentage of programs
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Mobility Exercises") { (result) in self.mobExOn = result
            self.setButtonState(button: self.mobExButton, state: self.mobExOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Compression Legs") { (result) in self.legCompOn = result
            self.setButtonState(button: self.normLegButton, state: self.legCompOn)
            //If result is true add 3.7 to the percentage total (100 / total number of modalities listed)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Compression Arms") { (result) in self.armCompOn = result
            self.setButtonState(button: self.normArmButton, state: self.armCompOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Compression Hips") { (result) in self.hipCompOn = result
            self.setButtonState(button: self.normHipButton, state: self.hipCompOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        //Thermal Therapy Equipment
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Shower") { (result) in self.showerOn = result
            self.setButtonState(button: self.showerButton, state: self.showerOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Water Immersion") { (result) in self.bathOn = result
            self.setButtonState(button: self.bathButton, state: self.bathOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Ice") { (result) in self.coldOn = result
            self.setButtonState(button: self.coldPackButton, state: self.coldOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Cold Compression") { (result) in self.coldCompOn = result
            self.setButtonState(button: self.coldCompButton, state: self.coldCompOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Cryotherapy") { (result) in self.cryoOn = result
            self.setButtonState(button: self.cryoButton, state: self.cryoOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Heat Pack") { (result) in self.heatPackOn = result
            self.setButtonState(button: self.heatPackButton, state: self.heatPackOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Sauna") { (result) in self.saunaOn = result
            self.setButtonState(button: self.saunaButton, state: self.saunaOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        //Myofascial Mob Equipment
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Roller") { (result) in self.rollerOn = result
            self.setButtonState(button: self.rollerButton, state: self.rollerOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Ball") { (result) in self.ballOn = result
            self.setButtonState(button: self.ballButton, state: self.ballOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Stick") { (result) in self.stickOn = result
            self.setButtonState(button: self.stickButton, state: self.stickOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Floss Band") { (result) in self.flossBandOn = result
            self.setButtonState(button: self.flossBandButton, state: self.flossBandOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Resistance Band") { (result) in self.resistBandOn = result
            self.setButtonState(button: self.resistBandButton, state: self.resistBandOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "IASTM") { (result) in self.iastmOn = result
            self.setButtonState(button: self.iastmButton, state: self.iastmOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        //Light Therapy
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "IR Sauna") { (result) in self.irSaunaOn = result
            self.setButtonState(button: self.irSaunaButton, state: self.irSaunaOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        // Electrical Muscle Stimulation
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Soreness Relief Unit") { (result) in self.soreStimOn = result
            self.setButtonState(button: self.soreStimButton, state: self.soreStimOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Recovery Flush Unit") { (result) in self.recStimOn = result
            self.setButtonState(button: self.recStimButton, state: self.recStimOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        // Vibration Therapy
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Vibration Hand Held") { (result) in self.vibHHOn = result
            self.setButtonState(button: self.vibHhButton, state: self.vibHHOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Vibration Plate") { (result) in self.vibWbOn = result
            self.setButtonState(button: self.wholeVibButton, state: self.vibWbOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        // Mindset Therapy
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "EGG Unit") { (result) in self.museOn = result
            self.setButtonState(button: self.museButton, state: self.museOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Neurostimulation Unit") { (result) in self.thyncOn = result
            self.setButtonState(button: self.thyncButton, state: self.thyncOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        // Sensory Deprevation
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Float Tank") { (result) in self.floatOn = result
            self.setButtonState(button: self.floatButton, state: self.floatOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Kinesio Tape") { (result) in self.KtapeOn = result
            self.setButtonState(button: self.kTapeButton, state: self.KtapeOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        setlockerEquip(passOrg: orgName, passLocker: location, equip: "Cream") { (result) in self.creamOn = result
            self.setButtonState(button: self.creamButton, state: self.creamOn)
            if result == true {
                self.percentage += 3.7
            }
        }
        
        //UI Setup for button text
        wrapButtonText(button: mobExButton)
        wrapButtonText(button: creamButton)
        wrapButtonText(button: bathButton)
        wrapButtonText(button: coldCompButton)
        wrapButtonText(button: resistBandButton)
        wrapButtonText(button: vibHhButton)
        wrapButtonText(button: normLegButton)
        wrapButtonText(button: normArmButton)
        wrapButtonText(button: normHipButton)
        wrapButtonText(button: irSaunaButton)
        wrapButtonText(button: soreStimButton)
        wrapButtonText(button: recStimButton)
        wrapButtonText(button: thyncButton)
        
    }
    
    // Setup Button to deal with word wrapping of title
    func wrapButtonText(button: UIButton){
        button.titleLabel!.numberOfLines = 0; // Dynamic number of lines
        button.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        //UI Setup
        saveButton.layer.backgroundColor = UIColor.clear.cgColor
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.borderWidth = 2
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.cornerRadius = 5.0
        
        
        // Setup action for exit alert once save button is pressed
        exitAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (result) in
            if self.setup == false {
                self.performSegue(withIdentifier: "backToProfile", sender: self)
            } else {
                self.performSegue(withIdentifier: "backToSetup", sender: self)
            }
        }))
        
        // Setup Button Action Alerts
        //Mob Ex alert action
        mobAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.mobExButton, state: self.mobExOn) }))
        mobAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Compression Arm Sleeves alert
        compArmAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.normArmButton, state: self.armCompOn) }))
        compArmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Compression Leg Sleeves alert
        compAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.normLegButton, state: self.legCompOn) }))
        compAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Compression Hip Sleeves alert
        compHipAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.normHipButton, state: self.hipCompOn) }))
        compHipAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Shower alert
        coldShowerAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.showerButton, state: self.showerOn) }))
        coldShowerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Bath alert
        coldBathAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.bathButton, state: self.bathOn) }))
        coldBathAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Cold Pack alert
        coldPackAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.coldPackButton, state: self.coldOn) }))
        coldPackAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Cold Compression alert
        coldCompAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.coldCompButton, state: self.coldCompOn) }))
        coldCompAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Cryo alert
        wbCryoAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.cryoButton, state: self.cryoOn) }))
        wbCryoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //heat pack alert
        hotPackAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.heatPackButton, state: self.heatPackOn) }))
        hotPackAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Sauna alert
        saunaAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.saunaButton, state: self.saunaOn) }))
        saunaAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Roller alert
        myoMobAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.rollerButton, state: self.rollerOn) }))
        myoMobAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Ball alert
        myoMobBallAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.ballButton, state: self.ballOn) }))
        myoMobBallAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Stick alert
        myoMobStickAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.stickButton, state: self.stickOn) }))
        myoMobStickAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Floss Band alert
        flossAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.flossBandButton, state: self.flossBandOn) }))
        flossAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Resistance Band alert
        resistanceAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.resistBandButton, state: self.resistBandOn) }))
        resistanceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //IASTM alert
        iastmAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.iastmButton, state: self.iastmOn) }))
        iastmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //IR Sauna alert
        irSaunaAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.irSaunaButton, state: self.irSaunaOn) }))
        irSaunaAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Sore Stim alert
        emsSrAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.soreStimButton, state: self.soreStimOn) }))
        emsSrAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Recovery Stim Alert
        emsArAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.recStimButton, state: self.recStimOn) }))
        emsArAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Whole body Vib alert
        wbVibAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.wholeVibButton, state: self.vibWbOn) }))
        wbVibAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Hand Held Vib alert
        hhVibAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.vibHhButton, state: self.vibHHOn) }))
        hhVibAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Muse alert
        eggAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.museButton, state: self.museOn) }))
        eggAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Thync alert
        NeuroAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.thyncButton, state: self.thyncOn) }))
        NeuroAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Float alert
        sensorAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.floatButton, state: self.floatOn) }))
        sensorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Ktape alert
        kTapeAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.kTapeButton, state: self.KtapeOn) }))
        kTapeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Cream alert
        creamAlert.addAction(UIAlertAction(title: "Add to locker", style: .default, handler: { (result) in
            self.setButtonState(button: self.creamButton, state: self.creamOn) }))
        creamAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
