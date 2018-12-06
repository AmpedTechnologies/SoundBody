//
//  SideBarViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/2/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase

class SideBarViewController: UIViewController {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var recOn: Bool!
    var orgName: String!
    
    @IBOutlet weak var recSwitch: UISwitch!
    
    @IBAction func recSwitchAction(_ sender: Any) {
        recOn = recSwitch.isOn
        Functions.updateRec(company: orgName, status: recOn)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgName = app.scores.value(forKey: "organization") as! String
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        
        Functions.getRecStatus(company: orgName, completionHandler:  { (result) in
            self.recSwitch.isOn = result
        })
    }
    
    

}
