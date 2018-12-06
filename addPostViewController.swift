//
//  addPostViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 6/14/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import ALCameraViewController
import JGProgressHUD


extension UITextView {
    func setupText(name: UITextView){
        name.layer.borderColor = UIColor.black.cgColor
        name.layer.borderWidth = 1.0
        //name.layer.cornerRadius = 5.0
        
    }
}

extension UIImageView {
    func setupImage(name: UIImageView){
        name.layer.borderColor = UIColor.black.cgColor
        name.layer.borderWidth = 1.0
        name.layer.cornerRadius = 15.0
    }
    
}

class addPostViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let hud = JGProgressHUD(style: .dark)
    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    let picker = UIImagePickerController()
    var data = Data()
    var pickedImage = #imageLiteral(resourceName: "defaultPost.png")
    var rand = arc4random_uniform(10000)
    var orgName: String!
    var libraryEnabled: Bool = true
    var croppingEnabled: Bool = true
    var allowResizing: Bool = true
    var allowMoving: Bool = false
    var minimumSize: CGSize = CGSize(width: 60, height: 100)
    var senderId: String!
    var name: String!
    var postMessage: String!
    var postImageId: String!
    var profilePic: String!
    
    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var imageOut: UIImageView!

    //Action for left nav bar button
    @objc func back(sender: UIButton){
        performSegue(withIdentifier: "back", sender: self)
    }
    
    //Function to deal with changing of text within a textview
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        counter.text = String(80 - changedText.count)
        if changedText.count >= 80 {
            counter.textColor = UIColor.red
        } else {
            counter.textColor = UIColor.black
        }
        return changedText.count <= 80
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup delegates
        caption.delegate = self
        picker.delegate = self
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        //UI setup background
        view.backgroundColor = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1)
        caption.layer.cornerRadius = 5.0
        
        // UI Setup through extensions
        caption.setupText(name: caption)
        imageOut.setupImage(name: imageOut)
        
        
        // Setup Right Nav Button
        let post = UIButton(frame: CGRect(x: 0, y: 0, width: 52, height: 30))
        post.layer.cornerRadius = 5.0
        post.layer.masksToBounds = true
        post.widthAnchor.constraint(equalToConstant: 52).isActive = true
        post.heightAnchor.constraint(equalToConstant: 30).isActive = true
        post.setTitle("POST", for: .normal)
        post.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        post.setTitleColor(UIColor.white, for: .normal)
        post.layer.borderColor = UIColor.white.cgColor
        post.layer.backgroundColor = UIColor(red: 0/255, green: 143/255, blue: 0/255, alpha: 0.7).cgColor
        post.layer.borderWidth = 1.0
        post.addTarget(self, action: #selector(addPostViewController.addPost(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: post)
        
        //Setup Left Nav Button
        let back = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        back.layer.cornerRadius = back.frame.size.width / 2
        back.layer.masksToBounds = true
        back.widthAnchor.constraint(equalToConstant: 30).isActive = true
        back.heightAnchor.constraint(equalToConstant: 30).isActive = true
        back.setBackgroundImage(#imageLiteral(resourceName: "backIcon.png"), for: .normal)
        back.layer.borderColor = UIColor.white.cgColor
        back.layer.borderWidth = 1.0
        back.addTarget(self, action: #selector(addPostViewController.back(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)

        // Add tap gesture to the image view
        let imageTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(addPostViewController.addImage(sender:)))
        imageOut.isUserInteractionEnabled = true
        imageOut.addGestureRecognizer(imageTap)
        
    
    }
    
    //Setup image cropping parameters
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: croppingEnabled, allowResizing: allowResizing, allowMoving: allowMoving, minimumSize: minimumSize)
    }
    
    // Setup button action for right nav bar button
    @objc func addImage(sender: Any){
        print("add Image pressed")
       
        //Setup and display camera view controller
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            if image != nil {
            self?.pickedImage = image!
            self?.imageOut.image =  image //.resize(withWidth: 200)
            self?.imageOut.contentMode = .scaleAspectFill
            
            self?.imageOut.layer.cornerRadius = 15
            self?.imageOut.layer.masksToBounds = true
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }
    
    // Add post to storage and to database
    @objc func addPost(sender: UIButton){
        // Setup HUD to delay until post is submitted
        hud.textLabel.text = "Submitting your post"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)
        
        postMessage = caption.text!
        
         var downloadURL: String!
         let fileName = String(self.rand)
         let nationRef = self.storageRef.child("Nation").child(orgName).child("FeedImages").child(fileName)
        let uploadData = UIImageJPEGRepresentation(self.pickedImage, 100)
        
         nationRef.putData(uploadData!, metadata: nil) { (metadata, error) in
            nationRef.downloadURL(completion: { (url, error) in
                if let urlText = url?.absoluteString {
                    
                    downloadURL = urlText
                    print(downloadURL)
            }
                let postRef = self.ref.child(self.orgName).child("Nation").child("Feed").childByAutoId()
                let nationPost = ["Sender ID": self.senderId, "Name": self.name, "Message": self.postMessage, "Image": downloadURL, "ProfilePic" : self.profilePic, "link": ""]
                
                postRef.setValue(nationPost)
            })
        self.performSegue(withIdentifier: "back", sender: self)
    }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        orgName = app.scores.value(forKey: "organization") as! String
        
        //Get user information for comments
        getUserInformation(company: orgName, completionHandler: { (result) in
            print(result)
        })
    }
    
    // Download user information from database
    func getUserInformation(company: String, completionHandler:@escaping (_ status: String)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() == true {
                let firstName = snapshot.childSnapshot(forPath: "first name").value as? String
                let lastName = snapshot.childSnapshot(forPath: "last name").value as? String
                self.name = firstName! + " " + lastName!
                self.senderId = snapshot.childSnapshot(forPath: "senderId").value as? String
                self.profilePic = snapshot.childSnapshot(forPath: "avatar").value as? String
            } else {
                completionHandler("")
                return
            }
            
            completionHandler("COMPLETE")
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
