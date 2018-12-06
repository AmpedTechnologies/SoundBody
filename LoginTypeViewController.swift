//
//  LoginTypeViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 5/23/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Kingfisher
import SafariServices

class LoginTypeViewController: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var DemoImage: UIImageView!
    @IBOutlet weak var individualLogin: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var orgLogin: Bool!
    
    // Action if Individual login button is selected
    @IBAction func individualLoginAction(_ sender: Any) {
        orgLogin = false
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    // Action if signup now is selected
    @IBAction func signUpButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "SignUp", sender: self)
        //let safariVC = SFSafariViewController(url: NSURL(string: "http://www.ampedtechnologies.com/SignUp")! as URL)
        //self.present(safariVC, animated: true, completion: nil)
        //safariVC.delegate = self

    }
    
    // Deal with safari being opened within the app
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //Organization button Action
    @IBAction func orgLoginButtonAction(_ sender: Any) {
        orgLogin = true
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        individualLogin.layer.borderWidth = 2.0
        individualLogin.layer.borderColor = UIColor.white.cgColor
        individualLogin.layer.cornerRadius = 5.0
        
        signUpButton.layer.borderWidth = 2.0
        signUpButton.layer.borderColor = UIColor.white.cgColor
        signUpButton.layer.cornerRadius = 5.0
        
        //Setup background UI
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "frontScreen.png")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Send information to new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let Login = segue.destination as? Login {
            Login.orgLogin = orgLogin;
        }
    }
 

}
