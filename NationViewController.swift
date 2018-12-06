//
//  NationViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 4/26/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import Kingfisher

class cell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var nationLabel: UILabel!
    
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 8
            frame.size.height -= 2 * 8
            super.frame = frame
        }
    }
}

class NationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UISearchBarDelegate {

    //@IBOutlet weak var messageBoardButton: UIButton!
    let app = UIApplication.shared.delegate as! AppDelegate
    let mail = MFMailComposeViewController()
    var ref: DatabaseReference!
    var orgName: String!
    //var name: String!
    var avatar = ""
    var name = ""
    
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var feedButton: UIButton!
    @IBOutlet weak var usernameOutput: UILabel!
    @IBOutlet weak var gotAmpedOut: UILabel!
    @IBOutlet weak var badgesOut: UILabel!
    @IBOutlet weak var userAvatarOut: UIImageView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var username = ""
    var userID = ""
    var users: [Users] = []
    var filteredUsers: [Users] = []
    var userIdArray: [String] = []
    var data: [String] = []
    var selectedFullName: String?
    var selectedUser: String!
    var selectedAvatar: String!
    var selectedProfilePic: String!
    var numbOfSessions = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! //1.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! cell
        //let image: UIImage!
        
        //cell.setupCell()
        
        let text = ((filteredUsers[indexPath.row].firstName)! + " " + (filteredUsers[indexPath.row].lastName)!) //2.
        
        if filteredUsers[indexPath.row].avatar!.contains("http") {
            let url = URL(string: filteredUsers[indexPath.row].avatar!)
            let processor = RoundCornerImageProcessor(cornerRadius: cell.cellImage.frame.size.width / 2)
            cell.cellImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
            cell.cellImage.layer.cornerRadius = cell.cellImage.frame.size.width / 2
            cell.cellImage.clipsToBounds = true
            
        } else {
            cell.cellImage.image = UIImage(named: filteredUsers[indexPath.row].avatar!)
            cell.cellImage.layer.cornerRadius = cell.cellImage.frame.size.width / 2
            cell.cellImage.clipsToBounds = true
        }
        
        
        //let image = UIImage(named: users[indexPath.row].avatar!)
        
        
        //cell.cellImage.image = image
        
        
        //cell.cellAmped.text = String(users[indexPath.row].sessions!)
        //cell.cellBadges.text = String(Message[indexPath.row].Badges!)
        cell.cellName.text = text
        //cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 10.0
        
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 45/255, green: 110/255, blue: 39/255, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        
        return cell //4.
    }
    var amped: Int?
    var badges: Int?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SELECTED")
        let selCell = tableView.cellForRow(at: indexPath) as! cell
        
        name = ((self.filteredUsers[indexPath.row].firstName)! + " " + (self.filteredUsers[indexPath.row].lastName)!)
        
        let addAlert = UIAlertController(title: "Follow \(name)", message: "", preferredStyle: .alert)
        
        addAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.updateFriendGroup(sId: (self.filteredUsers[indexPath.row].senderId)!, nm: self.name, profileP: (self.filteredUsers[indexPath.row].avatar)!, company: self.orgName)
            print("ADD \(self.name) to friend group")
            print(self.filteredUsers[indexPath.row].senderId)
        }))
        
        addAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(addAlert, animated: true)
        /*
        selectedUser = (users[indexPath.row].userId)
        getSessionInformation(company: orgName, sessionType: "numberOfSessions", userID: self.selectedUser) { (numberOfSessions) in
            
            self.numbOfSessions = numberOfSessions
            self.selectedFullName = ((self.users[indexPath.row].firstName)! + " " + (self.users[indexPath.row].lastName)!)
            self.selectedProfilePic = self.users[indexPath.row].profilePic
            
            
            self.selectedAvatar = self.users[indexPath.row].avatar
            self.performSegue(withIdentifier: "friend", sender: self)
        }
        */
    }
    
    func updateFriendGroup(sId: String, nm: String, profileP: String, company: String) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        let postRef = self.ref.child(company).child(userID).child("Friend Nation").childByAutoId()
        
        let addFriend = ["Sender ID": sId, "Name": nm, "ProfilePic": profileP]
        
        postRef.setValue(addFriend)
        
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: self)
    }
    //@IBAction func addFriendButton(_ sender: Any) {
      //  sendEmail()
   // }
    
    func sendEmail(){
        if MFMailComposeViewController.canSendMail(){
            
            mail.setSubject("You need to check out this AMPED app")
            mail.setMessageBody("Go to (whatever link we want) to get signed up today!", isHTML: true)
            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        orgName = app.scores.value(forKey: "organization") as! String
        if orgName != "individual" {
            //messageBoardButton.isHidden = true
        }
        setGroupInformation(organization: orgName, information: "name") { (result) in
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        mail.mailComposeDelegate = self
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        //messageBoardButton.layer.cornerRadius = 5.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(NationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        print("NATION")
        
       
        
        backButton.layer.cornerRadius = backButton.frame.size.width / 2
        backButton.layer.borderColor = UIColor.green.cgColor
        backButton.layer.borderWidth = 1.0
        
        tableView.dataSource = self
        tableView.separatorColor = .clear
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*
        if let FriendViewController = segue.destination as? FriendViewController {FriendViewController.username = selectedFullName;
            FriendViewController.amped = numbOfSessions;
            FriendViewController.profilePic = selectedProfilePic;
            FriendViewController.avatar = selectedAvatar;
            
            FriendViewController.selectedUser = selectedUser
        }
 
        if let ChallengesViewController = segue.destination as? ChallengesViewController {
            ChallengesViewController.userAvatar = userAvatarOut.image;
            
            
        }*/
    }
    
    class Users {
        var firstName: String?
        var lastName: String?
        var userId: String?
        var avatar: String?
       // var profilePic: String?
        var senderId: String?
        init(firstName: String, lastName: String, userid: String, avatar: String, senderID: String)
        {
            self.firstName = firstName
            self.lastName = lastName
            self.userId = userid
            self.avatar = avatar
            //self.profilePic = profilePic
            self.senderId = senderID
            
            
        }
    }
    
    func setGroupInformation(organization: String, information: String, completionHandler:@escaping (_ status: String)-> Void) {
        //let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child(organization).observe(.value, with: { (snapshot) in
            for childSnap in snapshot.children.allObjects {
                self.users.removeAll()
                let snap = childSnap as! DataSnapshot
        
                self.userID = snap.key
                //let array: [String] = [snap.key]
                self.userIdArray.append(snap.key)
                self.getFriendDetails(company: self.orgName, userID: snap.key) { (result) in
                    
    
                    self.users.append(result)
                    self.filteredUsers = self.users
                    self.tableView.reloadData()
                    
                }
                completionHandler(snap.key)
                
                
            }
            
        })
    }
    
    func getInformation(company: String, detail: String, userID: String, completionHandler:@escaping (_ status: String)-> Void) {
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() == true {
                
                self.name = (snapshot.childSnapshot(forPath: detail).value as! String)
                self.avatar = (snapshot.childSnapshot(forPath: "avatar").value as! String)
                
            } else {
                    completionHandler("NO")
                    return
            }
            completionHandler(self.name)
            
        })
    }
    
    func getSessionInformation(company: String, sessionType: String, userID: String, completionHandler:@escaping (_ status: Int)-> Void) {
        ref.child(company).child(userID).child("SessionInformation").observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let sessions = snapshot.childSnapshot(forPath: sessionType).value as? Int
                else {
                    completionHandler(0)
                    return
            }
            
            completionHandler(sessions)
            
        })
    }
    
    func getFriendDetails(company: String, userID: String, completionHandler:@escaping (_ status: Users)-> Void) {
        let currentUser: String = (Auth.auth().currentUser?.uid)!
        var firstName = ""
        var lastName = ""
        var avatar = ""
        var profilePic = ""
        var senderId = ""
        var user: Users!
        var exists = false
        if userID != currentUser {
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() == true {
                
                if snapshot.childSnapshot(forPath: "first name").exists() == true {
                firstName = snapshot.childSnapshot(forPath: "first name").value as! String
                lastName = snapshot.childSnapshot(forPath: "last name").value as! String
                avatar = snapshot.childSnapshot(forPath: "avatar").value as! String
                //profilePic = snapshot.childSnapshot(forPath: "profilePic").value as! String
                senderId = snapshot.childSnapshot(forPath: "senderId").value as! String
                    
                    
                    } else {
                    
                    }
                user = Users(firstName: firstName, lastName: lastName, userid: userID, avatar: avatar , senderID: senderId)
                
            }else {
                    print("ERROR")
                    return
            }
            
            completionHandler(user)
        })
        }
    }
    
    func getUserDetails(company: String, completionHandler:@escaping (_ status: String)-> Void) {
        let currentUser: String = (Auth.auth().currentUser?.uid)!
        var firstName = ""
        var lastName = ""
        var avatar = ""
        var numbOfBadges = ""
        if userID != currentUser {
            ref.child(company).child(currentUser).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    
                    firstName = snapshot.childSnapshot(forPath: "first name").value as! String
                    lastName = snapshot.childSnapshot(forPath: "last name").value as! String
                    numbOfBadges = snapshot.childSnapshot(forPath: "badges").value as! String
                    avatar = snapshot.childSnapshot(forPath: "avatar").value as! String
                    
                    
                }else {
                    print("ERROR")
                    return
                }
                completionHandler(avatar)
            })
        }
    }
    func getUserInfo(company: String,  completionHandler:@escaping (_ status: String)-> Void) {
        let currentUser: String = (Auth.auth().currentUser?.uid)!
        var sessionCount = 0
        ref.child(company).child(currentUser).child("SessionInformation").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() == true {
                sessionCount = snapshot.childSnapshot(forPath: "numberOfSessions").value as! Int
                self.gotAmpedOut.text = String(sessionCount)
            }
                else {
                    completionHandler("NO USER INFO")
                    return
            }
            
            completionHandler("User info Complete")
            
        })
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text! == "" {
            filteredUsers = users
        } else {
            // Filter the results
            filteredUsers = users.filter { ($0.firstName?.lowercased().contains(self.searchBar.text!.lowercased()))! }
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        print("KEYBOARD SHOWING")
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            self.bottomConstraint.constant = keyboardHeight
            
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
           self.bottomConstraint.constant = 20
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
