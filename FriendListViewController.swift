//
//  FriendListViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 10/4/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

/*
class cell: UITableViewCell {

    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    // Make the spacing between the cells
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
*/
class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    
    let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    var friends: [Friends] = []
    var orgName: String!
    
    class Friends{
        var name: String!
        var senderID: String!
        var avatar: String!
        var postId: String!
        
        init( name: String, senderId: String, avatar: String, postID: String){
            self.name = name
            self.senderID = senderId
            self.avatar = avatar
            self.postId = postID
        }
    }
    
    func getFriendList(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child(company).child(userID).child("Friend Nation").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            for snap in snapshots! {
                print(snap.key)
                let name        = snap.childSnapshot(forPath: "Name").value as! String
                let profilePic  = snap.childSnapshot(forPath: "ProfilePic").value as! String
                let senderID    = snap.childSnapshot(forPath: "Sender ID").value as! String
                let postID      = snap.key
                
                let f = Friends(name: name, senderId: senderID, avatar: profilePic, postID: postID)
                self.friends.append(f)
            }
            completionHandler(true)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        orgName = app.scores.value(forKey: "organization") as! String
        
        getFriendList(company: orgName) { (result) in
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        
        //Setup camera button as right navigation button
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.setBackgroundImage(#imageLiteral(resourceName: "addFriend2.png"), for: .normal)
        addButton.layer.borderColor = UIColor.green.cgColor
        addButton.layer.borderWidth = 1.0
        addButton.layer.cornerRadius = 5.0
        addButton.addTarget(self, action: #selector(FriendListViewController.addButton(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        //Setup back button as left navigation button
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.setBackgroundImage(#imageLiteral(resourceName: "backIcon.png"), for: .normal)
        backButton.layer.borderColor = UIColor.green.cgColor
        backButton.layer.borderWidth = 1.0
        backButton.layer.cornerRadius = backButton.frame.width / 2
        backButton.addTarget(self, action: #selector(FriendListViewController.backButton(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        
        // Setup navigation bar title
        let titleOut = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        titleOut.text = "Friends Nation Members"
        titleOut.textColor = UIColor.white
        self.navigationItem.title = titleOut.text
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func addButton(sender: UIButton){
        performSegue(withIdentifier: "addFriend", sender: self)
    }
    
    @objc func backButton(sender: UIButton){
        performSegue(withIdentifier: "back", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeFriend(company: String, ID: String) {
        let userID: String = (Auth.auth().currentUser?.uid)!

        ref.child(company).child(userID).child("Friend Nation").child(ID).removeValue()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! cell
        
        cell.cellName.text = friends[indexPath.row].name
    
        
        let profileUrl = URL(string: friends[indexPath.row].avatar)
        cell.cellImage.kf.setImage(with: profileUrl)
        
        cell.layer.cornerRadius = 10.0
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeFriend(company: orgName, ID: friends[indexPath.row].postId!)
            self.friends.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("DELETED")
        }
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
