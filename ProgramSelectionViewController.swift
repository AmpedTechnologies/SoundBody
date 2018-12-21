//
//  ProgramSelectionViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 6/20/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class prog{
    var progImage: String!
    var progLabel: String!
    
    init(progImage: String, progLabel: String)
    {
        self.progImage = progImage
        self.progLabel = progLabel
    }
}

class progDetails{
    var name: String!
    var areas: [Areas]
    
    
    init(name: String, areas: [Areas])
    {
        self.name = name
        self.areas = areas
        
        
    }
}

class Areas{
    var name: String!
    var image: String!
    var premium: Bool!
    
    init(name: String, image: String!, premium: Bool!)
    {
        self.name = name
        self.image = image
        self.premium = premium
    }
}

class progTableCell: UITableViewCell{
    
    @IBOutlet weak var collViewOne: UICollectionView!
    @IBOutlet weak var progTitle: UILabel!
    
}


extension progTableCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collViewOne.delegate = dataSourceDelegate
        collViewOne.dataSource = dataSourceDelegate
        collViewOne.tag = row
        collViewOne.setContentOffset(collViewOne.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collViewOne.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collViewOne.contentOffset.x = newValue }
        get { return collViewOne.contentOffset.x }
    }
}

class ProgramSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var checkinButton: UIButton!
    @IBOutlet weak var titleOne: UILabel!
    @IBOutlet weak var titleTwo: UILabel!
    @IBOutlet weak var titleThree: UILabel!
    @IBOutlet weak var collViewOne: UICollectionView!
    @IBOutlet weak var collViewTwo: UICollectionView!
    @IBOutlet weak var collViewThree: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var orgName: String!
    var pathway: String!
    var timeOut = 0
    var fiveMinuteBool = false
    var fifteenMinuteBool = false
    var thirtyMinuteBool = false
    var onlyBool = false
    var match = false
    var room = ""
    var storedOffsets = [Int: CGFloat]()
    var progType = ""
    var progArea = ""
    var breathingOnly = true
    var numberOfPrescriptions = 0
    var preTwoImage: UIImage!
    var passTimeTwo = 0
    var preTwoTitle = ""
    var lockerEquipment: [String] = []
    let dateFormat = DateFormatter()
    var cNumb = 0
    var PremMember = false
    var progD: [progDetails] = []
    var areaOne: [Areas] = []
    var programs: [prog] = []
    var pastPrograms: [String] = []
    var program: [String] = []
    
    let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
    
    let premiumAlert = UIAlertController(title: "Unlock Premium Content?", message: "You need to sign up for an RVIVE Membership to access the premium content", preferredStyle: .alert)
    
    // UI Button Setup For the circle time buttons
    func ButtonSettings(Name: UIButton){
        Name.layer.backgroundColor = UIColor.white.cgColor
        Name.setTitleColor(.black, for: .normal)
        Name.layer.borderWidth = 2
        Name.layer.borderColor = UIColor.white.cgColor
        Name.layer.cornerRadius = Name.frame.size.width / 2
    }

    func ButtonSettingsReset(Name: UIButton, bool: inout Bool){
        Name.layer.backgroundColor = UIColor.clear.cgColor
        Name.setTitleColor(.white, for: .normal)
        Name.layer.borderWidth = 2
        Name.layer.borderColor = UIColor.white.cgColor
        Name.layer.cornerRadius = Name.frame.size.width / 2
        bool = false
    }
    
    func initialButtonSettings(name: UIButton){
        name.layer.backgroundColor = UIColor.clear.cgColor
        name.setTitleColor(.white, for: .normal)
        name.layer.borderWidth = 2
        name.layer.borderColor = UIColor.white.cgColor
        name.layer.cornerRadius = name.frame.size.width / 2
    }
    
    // Action for 5 minute button selected
    @IBOutlet weak var fiveMinuteButton: UIButton!
    @IBAction func fiveMinuteButton(_ sender: Any) {
        if fiveMinuteBool == false {
            ButtonSettings(Name: fiveMinuteButton)
            timeOut = 5
            ButtonSettingsReset(Name: fifteenMinuteButton, bool: &fifteenMinuteBool)
            ButtonSettingsReset(Name: thirtyMinuteButton, bool: &thirtyMinuteBool)
            fiveMinuteBool = true
            pathwaySelected()
        }
    }

    //Action for 15 min button selected
    @IBOutlet weak var fifteenMinuteButton: UIButton!
    @IBAction func fifteenMinuteButton(_ sender: Any) {
        if fifteenMinuteBool == false {
            ButtonSettings(Name: fifteenMinuteButton)
            timeOut = 15
            ButtonSettingsReset(Name: fiveMinuteButton, bool: &fiveMinuteBool)
            ButtonSettingsReset(Name: thirtyMinuteButton, bool: &thirtyMinuteBool)
            fifteenMinuteBool = true
            pathwaySelected()
        }
    }
    
    // Action for 30 min button Selected
    @IBOutlet weak var thirtyMinuteButton: UIButton!
    @IBAction func thirtyMinuteButton(_ sender: Any) {
        if thirtyMinuteBool == false {
            ButtonSettings(Name: thirtyMinuteButton)
            timeOut = 30
            ButtonSettingsReset(Name: fiveMinuteButton, bool: &fiveMinuteBool)
            ButtonSettingsReset(Name: fifteenMinuteButton, bool: &fifteenMinuteBool)
            thirtyMinuteBool = true
            pathwaySelected()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // setup organization, room, and pathway information
        orgName = app.scores.value(forKey: "organization") as! String
        room = app.room
        pathway = app.pathway
        
    }
    
    
    //TABLE VIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  progD.count //program.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "progTableCell") as! progTableCell
        
        cell.progTitle.text = progD[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? progTableCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? progTableCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    
    //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return progD[collectionView.tag].areas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "programCell", for: indexPath) as! programCollectionViewCell
        
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            //cell.layer.backgroundColor = UIColor.green.cgColor
            //cell.titleButton.setBackgroundImage(#imageLiteral(resourceName: "demoBackground.png"), for: .normal)
            let imageUrl = URL(string: (progD[collectionView.tag].areas[indexPath.row].image))
            cell.cellImage.kf.setImage(with: imageUrl)
            cell.titleButton.titleLabel?.numberOfLines = 0
            cell.titleButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.titleButton.setTitle((progD[collectionView.tag].areas[indexPath.row].name), for: .normal)
            // set membership status
            if PremMember == true{
                cell.lockedImage.isHidden = true
            } else {
            cell.lockedImage.isHidden = !(progD[collectionView.tag].areas[indexPath.row].premium)
            }
            cNumb = cell.tag
            return cell
    
        }
    
    
    // What to do when collectionView cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        progType = progD[collectionView.tag].name
        progArea = progD[collectionView.tag].areas[indexPath.row].name!
        if progD[collectionView.tag].areas[indexPath.row].premium == true {
            if PremMember == true {
                self.pathwaySegue()
                print("PREMIUM PROGRAM")
            } else {
                self.present(premiumAlert, animated: true)
                print("Can not access this program")
            }
        } else if progD[collectionView.tag].areas[indexPath.row].premium == false {
            print("FREE PROGRAM")
            self.pathwaySegue()
        }
    }
    
    // Function to perform the correct segue depending on selected program - needs to be reduced when on video and meditation screen are used.
    func pathwaySegue(){
        
        if pathway == "Aches and Pains" || pathway == "Mobility" || pathway == "Fatigue" {
             performSegue(withIdentifier: "toVideo", sender: self)
        } else {
            if progType == "Breathing" {
                onlyBool = true
                performSegue(withIdentifier: "BREATHING", sender: self)
            } else {
                performSegue(withIdentifier: "toMeditation", sender: self)
            }
        }
        
        /*
        if pathway == "Aches and Pains" {
            if progType == "Foam Roller" || progType == "Vibration Therapy" || progType == "Full Program" || progType == " Full Programs" {
                performSegue(withIdentifier: "toVideo", sender: self)
            } else {
                numberOfPrescriptions = 1
                onlyBool = true
                performSegue(withIdentifier: "toImages", sender: self)
            }
        } else if pathway == "Fatigue" {
            if progType == "Foam Roller" || progType == "Vibration Therapy" {
                performSegue(withIdentifier: "toVideo", sender: self)
            } else {
                numberOfPrescriptions = 1
                onlyBool = true
                performSegue(withIdentifier: "toImages", sender: self)
            }
        } else if pathway == "Mindset" {
            if progType == "Unguided Meditation" || progType == "Guided Meditation" || progType == "Binaural Beats" {
                performSegue(withIdentifier: "toMeditation", sender: self)
            } else if progType == "Breathing" {
                onlyBool = true
                performSegue(withIdentifier: "BREATHING", sender: self)
            } else {
                performSegue(withIdentifier: "toVideo", sender: self)
            }
        }else if pathway == "Mobility" {
            performSegue(withIdentifier: "toVideo", sender: self)
        }
 */
    }
    
    // Download the program information from the database - name and tile image
    func getPrograms(pathway: String, time: String, completionHandler:@escaping (_ status: Int)-> Void) {
        var image = ""
        var prem: Bool!
        ref.child("Programs").child(pathway).child(time).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snap = snapshot.children.allObjects as? [DataSnapshot]
            
            for s in snap! {
                
                    let name    = s.key
                    if self.app.lockerEquipment.contains(name){
                        let sn = s.children.allObjects as? [DataSnapshot]
                            
                        for sna in sn! {
                            let area    = sna.key
                            image = sna.childSnapshot(forPath: "image").value as! String
                            prem = sna.childSnapshot(forPath: "premium program").value as? Bool
                            let a = Areas(name: area, image: image, premium: prem)
                            self.areaOne.append(a)
                        }
                
                        let det = progDetails(name: name, areas: self.areaOne)
                        self.progD.append(det)
                        self.areaOne.removeAll()
                    }
            }
            completionHandler(0)
        })
    }
    
    // Function to display the applicable programs depending on time selected - removes all first so that when different time selected their isnt duplicate programs displayed
    func pathwaySelected(){
        progD.removeAll()
        getPrograms(pathway: app.pathway, time: "\(timeOut) Min" ) { (result) in
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormat.dateFormat = "MMM d,yyyy h:mm:ss a"
        orgName = app.scores.value(forKey: "organization") as! String
        ref = Database.database().reference()
        
        // Setup Delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        //Setup back button as left navigation button
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.setBackgroundImage(#imageLiteral(resourceName: "backIcon.png"), for: .normal)
        backButton.layer.borderColor = UIColor.green.cgColor
        backButton.layer.borderWidth = 2.0
        backButton.layer.cornerRadius = backButton.bounds.width / 2
        backButton.addTarget(self, action: #selector(SocialFeedViewController.backButton(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        // Setup navigation bar title
        let titleOut = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        titleOut.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleOut.heightAnchor.constraint(equalToConstant: 21).isActive = true
        titleOut.image = (UIImage(named: "RviveWhite"))
        self.navigationItem.titleView = titleOut
        
        // UI Setup for buttons
        initialButtonSettings(name: fiveMinuteButton)
        initialButtonSettings(name: fifteenMinuteButton)
        initialButtonSettings(name: thirtyMinuteButton)

        //Load membership status
        Functions.getMembershipInfo(company: orgName) { (result) in
            self.PremMember = result
        }
        //Setup Premium Alert
        premiumAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (result) in
            print("Going to in-app purchase screen")
            self.performSegue(withIdentifier: "toPurchase", sender: self)
        }))
        premiumAlert.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: nil))
        
    }
    
    // Action for left nav bar button
    @objc func backButton(sender: UIButton){
        performSegue(withIdentifier: "back", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Segue information setup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let BreathingViewController = segue.destination as? BreathingViewController {
            
            BreathingViewController.totalBreathingTime = timeOut;
            BreathingViewController.breathingOnly = onlyBool;
            BreathingViewController.progType = progType
            BreathingViewController.progArea = progArea
            BreathingViewController.pathway = pathway
        }
        
        if let VideoViewController = segue.destination as? VideoViewController {
            
            VideoViewController.progType = progType
            VideoViewController.progArea = progArea
            VideoViewController.time = timeOut
            VideoViewController.pathway = pathway
            VideoViewController.lockerEquipment = lockerEquipment
        }
        
        if let MeditationViewController = segue.destination as? MeditationViewController {
            
            MeditationViewController.progType = progType
            MeditationViewController.progArea = progArea
            MeditationViewController.time = timeOut
            MeditationViewController.pathway = pathway
        }
        
        
        
    }
    
}
