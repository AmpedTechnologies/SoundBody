//
//  Onboarding.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 11/21/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit


class Onboarding: UIViewController {

    @IBOutlet weak var pageOne: UIView!
    @IBOutlet weak var pageTwo: UIView!
    @IBOutlet weak var pageThree: UIView!
    @IBOutlet weak var pageCounter: UIPageControl!
    
    var pages: [UIView] = []
    var pageNumber = 0
    let app = UIApplication.shared.delegate as! AppDelegate
    
    let profileAlert = UIAlertController(title: "WAIT", message: "We need you to complete and save your profile first", preferredStyle: .alert)
    
    func swipeResponse(swipe: UISwipeGestureRecognizer){
        
        if let swipeGesture = swipe as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if pageNumber > 0 {
                pageNumber -= 1
                pages[pageNumber].isHidden = false
                pages[pageNumber + 1 ].isHidden = true
                pageCounter.currentPage = pageNumber
                print("Swipe right")
                }
                
            case UISwipeGestureRecognizerDirection.left:
                if (pageNumber == 1 && app.profileSetup != true) {
                        self.present(profileAlert, animated: true)
                } else {
                if pageNumber < 2 {
                pageNumber += 1
                pages[pageNumber].isHidden = false
                pages[pageNumber - 1].isHidden = true
                pageCounter.currentPage = pageNumber

                print("Swipe left")
                    }
                }
            default:
                break
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pages.append(pageOne)
        pages.append(pageTwo)
        pages.append(pageThree)
        print("The value in ps = \(app.profileSetup)")

        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(Onboarding.swipeResponse))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(Onboarding.swipeResponse))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        profileAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
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
