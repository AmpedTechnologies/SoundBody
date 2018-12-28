//
//  SelfReportViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 10/30/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import AGCircularPicker
import Firebase
import JGProgressHUD

// Setup Body dial outputs
extension SelfReportViewController: AGCircularPickerDelegate {
    
    func didChangeValues(_ values: Array<AGColorValue>, selectedIndex: Int) {
        let valueComponents = values.map { return String(format: "%00002d", $0.value) }
        var fullString = valueComponents.joined(separator: ":")
        bodyScore = Int(fullString)!
        if Int(fullString)! <= 25 {
            fullString = "Good "
        } else if Int(fullString)! > 25 &&  Int(fullString)! <= 50 {
            fullString = "Tired"
        } else if Int(fullString)! > 50 &&  Int(fullString)! <= 75 {
            fullString = "Tight"
        } else {
            fullString = "Sore "
        }
        let attributedString = NSMutableAttributedString(string:fullString)
        let fullRange = (fullString as NSString).range(of: fullString)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white.withAlphaComponent(0.5), range: fullRange)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.bold), range: fullRange)
        
        let range = NSMakeRange(selectedIndex * 2 + selectedIndex, 5)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: values[selectedIndex].color, range: range)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.black), range: range)
        
        bodyLabel.attributedText = attributedString
    }
    
}

// Setup Mind dial outputs
extension SelfReportViewController {
    
    func updateLabel(value: Int, color: UIColor) {
        if value <= 24 {
            mindLabel.text = "OK"
        } else if value > 24 && value <= 46 {
            mindLabel.text = "Good"
        } else if value > 46 && value <= 75 {
            mindLabel.text = "Tired"
        } else {
            mindLabel.text = "Stressed"
        }
        mindScore = value
        //mindLabel.text = String(format: "%02d", value)
        mindLabel.textColor = color
    }
    
}

extension SelfReportViewController: AGCircularPickerViewDelegate {
    
    func circularPickerViewDidChangeValue(_ value: Int, color: UIColor, index: Int) {
        updateLabel(value: value, color: color)
    }
    
    func circularPickerViewDidEndSetupWith(_ value: Int, color: UIColor, index: Int) {
        updateLabel(value: value, color: color)
    }
    
    func didBeginTracking(timePickerView: AGCircularPickerView) {
        
    }
    
    func didEndTracking(timePickerView: AGCircularPickerView) {
        
    }
    
}


class SelfReportViewController: UIViewController {

    
    @IBOutlet weak var pickerView: AGCircularPickerView!
    @IBOutlet weak var circlePicker: AGCircularPicker!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var mindLabel: UILabel!
    var orgName: String!
    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    let dateFormat = DateFormatter()
    var mindScore: Int!
    var bodyScore: Int!
    var AmpedRx: Bool!
    
    let recAlert = UIAlertController(title: "Recommendation", message: "", preferredStyle: .alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgName = app.scores.value(forKey: "organization") as? String
        
        ref = Database.database().reference()
        
        //Setup colors of body dial
        let bodyColor1 = UIColor.rgb_color(r: 255, g: 141, b: 0)
        let bodyColor2 = UIColor.rgb_color(r: 255, g: 0, b: 88)
        let bodyColor3 = UIColor.rgb_color(r: 146, g: 0, b: 132)
        let bodyColorOption = AGCircularPickerColorOption(gradientColors: [bodyColor1, bodyColor2, bodyColor3], gradientAngle: -20)
        let bodyTitleOption = AGCircularPickerTitleOption(title: "BODY")
        let bodyValueOption = AGCircularPickerValueOption(minValue: 0, maxValue: 100)
        let bodyOption = AGCircularPickerOption(valueOption: bodyValueOption, titleOption: bodyTitleOption, colorOption: bodyColorOption)
        
        circlePicker.options = [bodyOption]
        circlePicker.delegate = self
        
        //Setup colors of mind dial
        let mindColor1 = UIColor.green  //rgb_color(r: 144, g: 99, b: 50)
        let mindColor2 = UIColor.orange
        let mindColor3 = UIColor.red
        
        let mindColorOption = AGCircularPickerColorOption(gradientColors: [mindColor1, mindColor2, mindColor3], gradientAngle: 140)
        let mindTitleOption = AGCircularPickerTitleOption(title: "MIND")
        let mindValueOption = AGCircularPickerValueOption(minValue: 0, maxValue: 100)
        let option = AGCircularPickerOption(valueOption: mindValueOption, titleOption: mindTitleOption, colorOption: mindColorOption)
        pickerView.setupPicker(delegate: (self as! AGCircularPickerViewDelegate), option: option)
        
        // Set nav bar title
        let pageTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        pageTitle.text = "Daily Checkin"
        pageTitle.textColor = UIColor.green
        
        // Setup button on right side of nav bar
        let submitButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        submitButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        submitButton.setTitle("Submit", for: .normal)
        submitButton.layer.borderColor = UIColor.green.cgColor
        submitButton.layer.borderWidth = 1.0
        submitButton.layer.cornerRadius = 5.0
        submitButton.addTarget(self, action: #selector(self.submitAction(sender:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: submitButton)
        
        // recommendations alert actions
        recAlert.addAction(UIAlertAction(title: "Thanks", style: .default, handler: { (result) in
            self.performSegue(withIdentifier: "back", sender: self)
        }))
        
        // Get the recomendation status from the users database information.
        Functions.getRecStatus(company: orgName) { (result) in
            self.AmpedRx = result
        }
    }
    
    // Action for submit Nav bar button
    @objc func submitAction(sender: UIButton){
        let total = self.mindScore + self.bodyScore
        // Send daily check in mind & body scores to the database
        Functions.updateDailyCheckin(company: orgName, mind: self.mindScore, body: self.bodyScore)
        
        // If the user has recommendations selected this section displays alert with necessary information
        if AmpedRx == true {
            if self.bodyScore >= 75 {
                recAlert.message = "To feel RVIVED, the SORENESS pathway is reccommended for you today."
            } else if self.bodyScore < self.mindScore {
                recAlert.message = "To feel RVIVED, the MINDFULNESS pathway is reccommended for you today."
            } else if self.bodyScore > self.mindScore {
                if self.bodyScore > 25 &&  self.bodyScore <= 50 {
                    recAlert.message = "To feel RVIVED, the FATIGUE pathway is reccommended for you today."
                } else if self.bodyScore > 50 &&  self.bodyScore <= 75 {
                    recAlert.message = "To feel RVIVED, the MOBILITY pathway is reccommended for you today."
            }
            }
        self.present(recAlert, animated: true)
        } else {
            print("NO RECOMMENDATION")
            self.performSegue(withIdentifier: "back", sender: self)
        }
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
