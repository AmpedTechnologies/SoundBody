//
//  SetupPageThree.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/21/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit

class SetupPageThree: UIViewController {

    let app = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var startButton: UIButton!
    var orgName: String!
    
    @IBAction func startButton(_ sender: Any) {
        print("Strart Pressed")
        setupCompleted()
        performSegue(withIdentifier: "start", sender: self)
    }
    
    func setupCompleted(){
        Functions.updateUserInfo(company: orgName)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orgName = app.scores.value(forKey: "organization") as! String
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "RecoveryLocker.png")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        startButton.layer.borderColor = UIColor.white.cgColor
        startButton.layer.borderWidth = 2.0
        startButton.layer.cornerRadius = 5.0

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
