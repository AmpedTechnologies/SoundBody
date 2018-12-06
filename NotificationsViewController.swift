//
//  NotificationsViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 4/4/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Whisper

class NotificationsViewController: UIViewController {

    let timeP = UIDatePicker()
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var timeOut: UILabel!
    @IBOutlet weak var remTime: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBAction func ReminderSwitch(_ sender: Any) {
        timePicker.isHidden = false
        remTime.isHidden = false
        timeOut.isHidden = false
        
        
    }
    
    func timeChanged(time: UIDatePicker){
        timePicker.datePickerMode = .time
        print(timePicker.datePickerMode = .time)
        let date = timePicker.date
        let c = Calendar.current.dateComponents([.hour, .minute ], from: date)
        var hour = c.hour!
        let min = c.minute!
        var x = "AM"
        if hour > 12 {
            hour = hour - 12
            x = "PM"
        }
        if min < 10 {
        timeOut.text = String(hour) + ":0" + String(min)
        } else {
            timeOut.text = String(hour) + ":" + String(min) + " " + x
        }
    }
    

    @IBAction func pickTime(_ sender: Any) {
        timeChanged(time: timePicker)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: self)
    }
    
    let alert = UIAlertController(title: "Hello", message: "Lets start communicating", preferredStyle: .alert)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker.backgroundColor = UIColor.white
        self.exitButton.setTitleColor(.white, for: .normal)
        self.exitButton.layer.borderWidth = 2
        self.exitButton.layer.borderColor = UIColor.white.cgColor
        
        
        //timePicker.addTarget(self, action: "timePickerChanged", for: UIControlEvents.valueChanged)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
