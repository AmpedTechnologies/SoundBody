//
//  setupProfileViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 5/23/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}

extension UIImage {
    
    func resize(withWidth newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

class setupProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    let picker = UIImagePickerController()
    var data = Data()
    var pickedImage: UIImage!
    var rand = arc4random_uniform(1000)
    
    @IBOutlet weak var metButton: UIButton!
    @IBOutlet weak var impButton: UIButton!
    var orgName: String!
    var avatar = "None"
    var profilePic = "None"
    
    func buttonSelected(buttonName: UIButton){
        buttonName.layer.borderColor = UIColor.white.cgColor
        buttonName.layer.borderWidth = 2.0
    }
    
    func buttonUnselected(buttonName: UIButton){
        buttonName.layer.borderColor = UIColor.clear.cgColor
        buttonName.layer.borderWidth = 2.0
    }
    func avatarButtonState(selected: UIButton, unOne: UIButton,unTwo: UIButton,unThree: UIButton,unFoour: UIButton, unFive: UIButton, unSix: UIButton, unSeven: UIButton,unEight: UIButton ) {
        
        buttonSelected(buttonName: selected)
        buttonUnselected(buttonName: unOne)
        buttonUnselected(buttonName: unTwo)
        buttonUnselected(buttonName: unThree)
        buttonUnselected(buttonName: unFoour)
        buttonUnselected(buttonName: unFive)
        buttonUnselected(buttonName: unSix)
        buttonUnselected(buttonName: unSeven)
        buttonUnselected(buttonName: unEight)
    }
    
    func profileButtonState(selected: UIButton, unOne: UIButton,unTwo: UIButton,unThree: UIButton,unFoour: UIButton, unFive: UIButton) {
        
        buttonSelected(buttonName: selected)
        buttonUnselected(buttonName: unOne)
        buttonUnselected(buttonName: unTwo)
        buttonUnselected(buttonName: unThree)
        buttonUnselected(buttonName: unFoour)
        buttonUnselected(buttonName: unFive)
    }
    
    @IBAction func impButtonAction(_ sender: Any) {
        //height.placeholder = "ft'in"
        weight.placeholder = "lbs"
        
        metButton.backgroundColor = UIColor.clear
        metButton.setTitleColor(.white, for: .normal)
        
        impButton.backgroundColor = UIColor.white
        impButton.setTitleColor(.black, for: .normal)
        
    }
    
    @IBAction func metButtonAction(_ sender: Any) {
        //height.placeholder = "cm"
        weight.placeholder = "kg"
        
        impButton.backgroundColor = UIColor.clear
        impButton.setTitleColor(.white, for: .normal)
        
        metButton.backgroundColor = UIColor.white
        metButton.setTitleColor(.black, for: .normal)
    }
    
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var prof: UITextField!
    @IBOutlet weak var age: UITextField!
    //@IBOutlet weak var height: UITextField!
    @IBOutlet weak var weight: UITextField!
    //@IBOutlet weak var cOfRes: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var gender: UITextField!
    //@IBOutlet weak var wearable: UITextField!
    @IBOutlet weak var avatarOne: UIButton!
    @IBOutlet weak var avatarTwo: UIButton!
    @IBOutlet weak var avatarThree: UIButton!
    @IBOutlet weak var avatarFour: UIButton!
    @IBOutlet weak var avatarFive: UIButton!
    @IBOutlet weak var avatarSix: UIButton!
    @IBOutlet weak var avatarSeven: UIButton!
    @IBOutlet weak var avatarEight: UIButton!
    @IBOutlet weak var avatarNine: UIButton!
    @IBOutlet weak var profileOne: UIButton!
    @IBOutlet weak var profileTwo: UIButton!
    @IBOutlet weak var profileThree: UIButton!
    @IBOutlet weak var profileFour: UIButton!
    @IBOutlet weak var profileFive: UIButton!
    @IBOutlet weak var profileSix: UIButton!
    
    @IBAction func pOneButton(_ sender: Any) {
        profilePic = "sampleProfile"
        profileButtonState(selected: profileOne, unOne: profileTwo, unTwo: profileThree, unThree: profileFour, unFoour: profileFive, unFive: profileSix)
    }
    @IBAction func pTwoButton(_ sender: Any) {
        profilePic = "profileTwo"
        profileButtonState(selected: profileTwo, unOne: profileOne, unTwo: profileThree, unThree: profileFour, unFoour: profileFive, unFive: profileSix)
    }
    
    @IBAction func pThreeButton(_ sender: Any) {
        profilePic = "profileThree"
        profileButtonState(selected: profileThree, unOne: profileTwo, unTwo: profileOne, unThree: profileFour, unFoour: profileFive, unFive: profileSix)
    }
    @IBAction func pFourButton(_ sender: Any) {
        profilePic = "profileFive"
        profileButtonState(selected: profileFour, unOne: profileTwo, unTwo: profileThree, unThree: profileOne, unFoour: profileFive, unFive: profileSix)
    }
    @IBAction func pFiveButton(_ sender: Any) {
        profilePic = "profileSix"
        profileButtonState(selected: profileFive, unOne: profileTwo, unTwo: profileThree, unThree: profileFour, unFoour: profileOne, unFive: profileSix)
    }
    @IBAction func pSixButton(_ sender: Any) {
        profilePic = "profileFour"
        profileButtonState(selected: profileSix, unOne: profileTwo, unTwo: profileThree, unThree: profileFour, unFoour: profileFive, unFive: profileOne)
    }
    
    
    @IBAction func aOneButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FmanFive.png?alt=media&token=c7b5cba0-7ebe-4496-ab45-520817bc5a18"
        avatarButtonState(selected: avatarOne, unOne: avatarTwo, unTwo: avatarThree, unThree: avatarFour, unFoour: avatarFive, unFive: avatarSix, unSix: avatarSeven, unSeven: avatarEight, unEight: avatarNine)
    }
    
    @IBAction func aTwoButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FmanTwo.png?alt=media&token=d2412141-4734-4322-a16d-6f893e8c1b09"
        avatarButtonState(selected: avatarTwo, unOne: avatarOne, unTwo: avatarThree, unThree: avatarFour, unFoour: avatarFive, unFive: avatarSix, unSix: avatarSeven, unSeven: avatarEight, unEight: avatarNine)
    }
    
    @IBAction func aThreeButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FmanThree.png?alt=media&token=60c5862a-6ed4-4763-9c5b-2b293f29cb6f"
       avatarButtonState(selected: avatarThree, unOne: avatarTwo, unTwo: avatarOne, unThree: avatarFour, unFoour: avatarFive, unFive: avatarSix, unSix: avatarSeven, unSeven: avatarEight, unEight: avatarNine)
    }
    
    @IBAction func aFourButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FmanFour.png?alt=media&token=97fb356f-8a01-4d62-9396-5568da196f02"
        avatarButtonState(selected: avatarFour, unOne: avatarTwo, unTwo: avatarThree, unThree: avatarOne, unFoour: avatarFive, unFive: avatarSix, unSix: avatarSeven, unSeven: avatarEight, unEight: avatarNine)
    }
    
    @IBAction func aFiveButton(_ sender: Any) {
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        //picker.cameraCaptureMode = .photo
        present(picker, animated: true, completion: nil)
        
       //present(picker, animated: true, completion: nil)
        
        
        avatarButtonState(selected: avatarFive, unOne: avatarTwo, unTwo: avatarThree, unThree: avatarFour, unFoour: avatarOne, unFive: avatarSix, unSix: avatarSeven, unSeven: avatarEight, unEight: avatarNine)
    }
    
    @IBAction func aSixButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FwomenOne.png?alt=media&token=da130136-81e7-43f4-b1b2-0b87e62df5cf"
        avatarButtonState(selected: avatarSix, unOne: avatarTwo, unTwo: avatarThree, unThree: avatarFour, unFoour: avatarFive, unFive: avatarOne, unSix: avatarSeven, unSeven: avatarEight, unEight: avatarNine)
    }
    
    @IBAction func aSevenButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FwomenTwo.png?alt=media&token=07b08476-3840-41ff-9307-f0ca6dbf4b1b"
        avatarButtonState(selected: avatarSeven, unOne: avatarTwo, unTwo: avatarThree, unThree: avatarFour, unFoour: avatarFive, unFive: avatarSix, unSix: avatarOne, unSeven: avatarEight, unEight: avatarNine)
    }
    
    @IBAction func aEightButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FwomenThree.png?alt=media&token=53736e62-c225-4e26-a353-fdf1f93cb2ab"
        avatarButtonState(selected: avatarEight, unOne: avatarTwo, unTwo: avatarThree, unThree: avatarFour, unFoour: avatarFive, unFive: avatarSix, unSix: avatarSeven, unSeven: avatarOne, unEight: avatarNine)
    }
    
    @IBAction func aNineButton(_ sender: Any) {
        avatar = "https://firebasestorage.googleapis.com/v0/b/amped-wellness.appspot.com/o/profileImages%2FwomenFour.png?alt=media&token=c199ed7a-e3b1-4f41-ba1a-5d19bde83483"
        avatarButtonState(selected: avatarNine, unOne: avatarTwo, unTwo: avatarThree, unThree: avatarFour, unFoour: avatarFive, unFive: avatarSix, unSix: avatarSeven, unSeven: avatarEight, unEight: avatarOne)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        dismiss(animated:true, completion: {
            let fileName = self.fullName.text! + self.lastName.text! + self.age.text! + self.weight.text! + String(self.rand)
            print(fileName)
            let profileRef = self.storageRef.child("profileImages").child(fileName)
            let uploadData = UIImageJPEGRepresentation(self.pickedImage!, 100)
            
            let uploadTask = profileRef.putData(uploadData!, metadata: nil) { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    //let downloadURL = metadata?.downloadURL()?.absoluteString ?? ""
                    //self.avatar = downloadURL
                    profileRef.downloadURL { url, error in
                        if let error = error {
                            
                        } else {
                            self.avatar = (url?.absoluteString)!
                            // Here you can get the download URL for 'simpleImage.jpg'
                        }
                    }
                    
                }
            }
        })
        
        
        self.avatarFive.setImage(pickedImage!.resize(withWidth: 200), for: .normal)
        self.avatarFive.widthAnchor.constraint(equalToConstant: 75).isActive = true
        self.avatarFive.heightAnchor.constraint(equalToConstant: 75).isActive = true
        self.avatarFive.layer.cornerRadius = self.avatarFive.frame.size.width / 2
        self.avatarFive.layer.masksToBounds = true

    }
    
    
    let saveAlert = UIAlertController(title: "Profile Saved", message: "", preferredStyle: .alert)
    
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveButtonAction(_ sender: Any) {
        updateUserDetails(company: orgName, detail: "first name", input: fullName.text!)
        updateUserDetails(company: orgName, detail: "age", input: age.text!)
        updateUserDetails(company: orgName, detail: "weight", input: weight.text!)
        updateUserDetails(company: orgName, detail: "gender", input: gender.text!)
        updateUserDetails(company: orgName, detail: "last name", input: lastName.text!)
        
        updateUserDetails(company: orgName, detail: "avatar", input: avatar)
        updateUserDetails(company: orgName, detail: "senderId", input: (fullName.text! + age.text! + weight.text!))
        updateUserDetails(company: orgName, detail: "badges", input: String(0))
        updateUserDetails(company: orgName, detail: "push Token", input: app.pushToken)
        
        //updateUserDetails(company: orgName, detail: "profilePic", input: profilePic)
        //updateUserDetails(company: orgName, detail: "country", input: cOfRes.text!)
        //updateUserDetails(company: orgName, detail: "height", input: height.text!)
        //updateUserDetails(company: orgName, detail: "profession", input: prof.text!)
        //updateUserDetails(company: orgName, detail: "wearable", input: wearable.text!)
        
        //performSegue(withIdentifier: "backToSetup", sender: self)
        self.present(saveAlert, animated: true)
    }
    
    
    func updateUserDetails(company: String, detail: String, input: String) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        self.ref.child(company).child(userID).child("userDetails").updateChildValues([detail : input])
        
    }
    
    var profileSaved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        picker.delegate = self
        orgName = app.scores.value(forKey: "organization") as! String
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        func dismissKeyboard() {
            view.endEditing(true)
        }
        
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.borderWidth = 2.0
        saveButton.layer.cornerRadius = 5.0
        
        impButton.layer.borderColor = UIColor.white.cgColor
        impButton.layer.borderWidth = 1.0
       
        
        metButton.layer.borderColor = UIColor.white.cgColor
        metButton.layer.borderWidth = 1.0
        
        saveAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (result) in
            self.app.profileSetup = true
            self.fullName.backgroundColor = UIColor.lightGray
            self.lastName.backgroundColor = UIColor.lightGray
            self.age.backgroundColor = UIColor.lightGray
            self.gender.backgroundColor = UIColor.lightGray
            self.weight.backgroundColor = UIColor.lightGray
            //self.cOfRes.backgroundColor = UIColor.lightGray
            //self.wearable.backgroundColor = UIColor.lightGray
            print("Information has been saved")
        }))
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
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
