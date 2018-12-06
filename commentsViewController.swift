//
//  commentsViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 6/16/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class postCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    
    func setupCell(){
    
    // Setup the profile pic to display as cirle
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
    profilePic.clipsToBounds = true
    profilePic.layer.borderColor = UIColor.white.cgColor
    profilePic.layer.borderWidth = 1.0
        
    //Setup the  username Label parameters
    name.textColor = UIColor(white: 1, alpha: 0.7)
        
    //Setup message label parameters
    message.textColor = UIColor(white: 1, alpha: 0.8)
        
        
    }
    
}

class Comments {
    var name: String!
    var profileImage: String!
    var message: String!
    
    init(name: String, profileImage: String, message: String)
    {
        self.name = name
        self.profileImage = profileImage
        self.message = message
        
    }
}


class commentsViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {

    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    var comments: [Comments] = []
    
    
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentCount: UILabel!
    
    var postID: String!
    var orgName: String!
    var name: String!
    var profilePic: String!
    var senderId: String!
    var postComment: String!
    var rand = arc4random_uniform(10000)
    var storageRef: StorageReference!
    var socType: String!
    
    //Left navigation button action
    @objc func back(sender: UIButton){
        performSegue(withIdentifier: "back", sender: self)
    }
    
    //right navigation button action
    @objc func addComment(sender: UIButton){
        print("The socType = \(socType!)")
        print("The post ID = \(postID!)")
        postComment = self.comment.text
        // generate a unique ID for the database to use as the key
        let postRef = self.ref.child(self.orgName).child(socType!).child("Feed").child(postID!).child("Comments").childByAutoId()
        
        // set value of information to add to the database
        let commentToAdd = ["Sender ID": self.senderId, "Name": self.name, "Message": self.postComment, "ProfilePic" : self.profilePic]
        
        // Send information to the database
        postRef.setValue(commentToAdd)
        
        // reset the text field to blank and remove the keyboard from the screen.
        comment.text = ""
        comment.resignFirstResponder()
        }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        orgName = app.scores.value(forKey: "organization") as! String
        postID = app.postID
        
        // Get any comments that have previously been made on the post.
        getUserInformation(company: orgName) { (result) in
            self.getComments(company: self.orgName) { (result) in
                self.tableView.reloadData()
            }
        }
        socType = app.socType
    }
    
    // Function to deal with the textview is the text is changed
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // Output text count to screen
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        commentCount.text = String(80 - changedText.count)
        if changedText.count >= 80 {
            commentCount.textColor = UIColor.red
        } else {
            commentCount.textColor = UIColor.black
        }
        return changedText.count <= 80
    }

    // function to deal with the end of editing the textview
    func textViewDidEndEditing(_ textView: UITextView) {
        comment.resignFirstResponder()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up delegates and necessary information
        tableView.delegate = self
        tableView.dataSource = self
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        //Setup comment area
        comment.setupText(name: comment)
        
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
        post.addTarget(self, action: #selector(commentsViewController.addComment(sender:)), for: .touchUpInside)
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
        back.addTarget(self, action: #selector(commentsViewController.back(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
        
        
    }
    
    //TableView setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count  //TestPost.getPostFeed().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! postCell
        cell.setupCell()
        cell.name.text = comments[indexPath.row].name
        cell.message.text = comments[indexPath.row].message
        
        //Use kingfisher to set the profile images
        let picUrl = URL(string: comments[indexPath.row].profileImage)
        let processor = RoundCornerImageProcessor(cornerRadius: cell.profilePic.frame.size.width / 2)
        cell.profilePic.kf.setImage(with: picUrl, placeholder: nil, options: [.processor(processor)])
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function for retrieving the post comments
    func getComments(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        print("Here")
        let query = ref.child(company).child(socType!).child("Feed").child(postID).child("Comments").queryLimited(toLast: 50)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if snapshot.exists() == true {
            print("Yes")
            let name        = snapshot.childSnapshot(forPath: "Name").value as! String
            let message     = snapshot.childSnapshot(forPath: "Message").value as! String
            let profilePic  = snapshot.childSnapshot(forPath: "ProfilePic").value as! String
            
            //add the information to the comments array
            let comm = Comments(name: name, profileImage: profilePic, message: message)
            self?.comments.append(comm)
            }
            completionHandler(true)
        })
        
        
    }
    
    // Get user information for comments
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

}
