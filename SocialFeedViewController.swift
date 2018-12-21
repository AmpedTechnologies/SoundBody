//
//  SocialFeedViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 6/14/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import MessageUI


class socialCell: UITableViewCell {
    
    
    @IBOutlet weak var messageOut: UITextView!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var messageCount: UILabel!
    @IBOutlet weak var comment: UIButton!
    @IBOutlet weak var postId: UILabel!
    let finalString = NSMutableAttributedString()
    
    
    func configure(p: Posts, socType: String ){
        // add clickable link to new feed posts
        if socType == "News Feed"{
        let linkString = NSMutableAttributedString(string: p.message)
        let link = URL(string: p.link)!
        let count = p.message.count - 9
        linkString.setAttributes([.link: link], range: NSMakeRange(count, 9))
        
        self.messageOut.attributedText = linkString
        } else {
            let linkString = NSMutableAttributedString(string: p.message)
            let link = URL(string: "https://www.ampedtechnologies.com")!
            linkString.setAttributes([.link: link], range: NSMakeRange(1, 0))
            
            self.messageOut.attributedText = linkString
        }
        self.userName.text = p.name
        
        
        
        if p.comNumb == 0 {
            self.messageCount.isHidden = true
        } else {
            self.messageCount.text = String(p.comNumb)
        }
        
        self.setupCell()
        self.layer.masksToBounds = true
        
        // Add shadow
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 4
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
    
    }
    
    // Setup the cells
    func setupCell(){
        // Setup the UIView parameters
        postView.layer.borderWidth = 1
        postView.layer.borderColor = UIColor.clear.cgColor
        postView.layer.cornerRadius = 15.0
        postView.layer.masksToBounds = true
        
        // Setup the profile pic to display as cirle
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.red.cgColor
        profileImage.layer.borderWidth = 1.0
        
        //Setup the  username Label parameters
        userName.textColor = UIColor(white: 0.0, alpha: 0.7)
        
        
        //Setup message label parameters
        messageOut.textColor = UIColor(white: 0.0, alpha: 0.8)
        messageOut.contentInset = UIEdgeInsetsMake(-7.0, -5.0, 0.0, 0.0)
        
        //setup message count badge
        messageCount.layer.cornerRadius = messageCount.frame.size.width / 2
        messageCount.clipsToBounds = true
        
        
    }
    
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

class Posts {
    var name: String!
    var profileImage: String!
    var message: String!
    var postImage: String!
    var postId: String!
    var comNumb: Int!
    var link: String!
    var senderID: String!
    
    init(name: String, profileImage: String, message: String, postImage: String, postId: String, comNumb: Int, link: String, senderID: String)
    {
        self.name = name
        self.profileImage = profileImage
        self.message = message
        self.postImage = postImage
        self.postId = postId
        self.comNumb = comNumb
        self.link = link
        self.senderID = senderID
    }
}

class Friend{
    
    var senderID: String!
    
    init( senderId: String){
        
        self.senderID = senderId
        
    }
}

class SocialFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    var postID: String!
    var socType = "Nation"
    
    let cameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let grad = CAGradientLayer()
    let gradHeight = UIApplication.shared.statusBarFrame.size.height as CGFloat
    var orgName: String!
    
   
    
    // Setup the left nav bar action
    @objc func backButton(sender: UIButton){
        print("BACK Pressed")
        performSegue(withIdentifier: "back", sender: self)
    }
    
    //Setup the right nav bar action
    @objc func postButton(sender: UIButton){
        performSegue(withIdentifier: "addPost", sender: self)
    }
    
    // Setup the comments button within each post
    @objc func comments(sender: UIButton){
        print(posts[sender.tag].postId)
        
        postID = posts[sender.tag].postId
        app.postID = postID
        print("Post ID = " + postID)
        performSegue(withIdentifier: "comments", sender: self)
        
    }
    
    // Setup add friend button Action
    @objc func addFriendButton(sender: UIButton){
        performSegue(withIdentifier: "friendList", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup delegates
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        
        getUserSenderID(company: orgName)
        
        // Set the background color of the view
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        // Set status bar background color to white.
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor.white
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        // add white to gray gradient in navigation bar
        let layerHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height as CGFloat
        grad.frame = CGRect(x: 0, y: gradHeight, width: 1366, height: layerHeight)
        grad.colors = [ UIColor.white.cgColor, UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor]
        self.view.layer.addSublayer(grad)
        
        //Setup camera button as right navigation button
        cameraButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cameraButton.setBackgroundImage(#imageLiteral(resourceName: "cameraIcon2.png"), for: .normal)
        cameraButton.addTarget(self, action: #selector(SocialFeedViewController.postButton(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cameraButton)
        
        //Setup back button as left navigation button
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.setBackgroundImage(#imageLiteral(resourceName: "home"), for: .normal)
        backButton.addTarget(self, action: #selector(SocialFeedViewController.backButton(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        
        // Setup navigation bar title
        let titleOut = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        titleOut.text = "RVIVE Nation"
        self.navigationItem.title = titleOut.text

        // Setup the size of the top collectionview bar so that it is placed correctly on all screen sizes
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        menuConstraint.constant = topBarHeight
        
        
    }
    
    @IBOutlet weak var menuConstraint: NSLayoutConstraint!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TableView setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table row count")
        print(posts.count)
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell") as! socialCell
        
        cell.activityInd.isHidden = false
        let postNumb = posts[indexPath.row]
        cell.configure(p: postNumb, socType: socType)
        
        cell.postView.frame = CGRect(x: 5, y: 5, width: (tableView.frame.width-10), height: (cell.frame.height-20))
        cell.postView.widthAnchor.constraint(equalToConstant: tableView.frame.width-10).isActive = true
        cell.postView.heightAnchor.constraint(equalToConstant: cell.frame.height-10).isActive = true
        
        // Make sure the image is displayed without distortion
        cell.postImage.contentMode = .scaleAspectFill
        cell.postImage.clipsToBounds = true
        
        // User kingfisher to cache images
        let postUrl = URL(string: postNumb.postImage)
        cell.postImage.kf.setImage(with: postUrl, completionHandler: { (image, error, CacheType, imageUrl) in
            cell.backgroundColor = UIColor.clear
            cell.activityInd.isHidden = true
        })
       
        let profileUrl = URL(string: postNumb.profileImage)
        cell.profileImage.kf.setImage(with: profileUrl)
        
        cell.comment.tag = indexPath.row
        //Add action to post
        cell.comment.addTarget(self, action: #selector(SocialFeedViewController.comments(sender:)), for: .touchUpInside)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var swipeConfig = UISwipeActionsConfiguration(actions: [])
        if self.userSenderID == self.posts[indexPath.row].senderID {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let flagAction = self.contextualToggleFlagAction(forRowAtIndexPath: indexPath)
        swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, flagAction])
        }
        if self.userSenderID != self.posts[indexPath.row].senderID{
            let flagAction = self.contextualToggleFlagAction(forRowAtIndexPath: indexPath)
            swipeConfig = UISwipeActionsConfiguration(actions: [flagAction])
        }
        return swipeConfig
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath)  -> UIContextualAction {
        let delete = UIContextualAction(style: .normal,
                                        title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            print(self.userSenderID)
                                            print(self.posts[indexPath.row].senderID)
                                            print(self.posts[indexPath.row].postId)
                                        self.ref.child(self.orgName).child("Nation").child("Feed").child(self.posts[indexPath.row].postId).removeValue()
                                            self.posts.remove(at: indexPath.row)
                                            self.tableView.reloadData()
                
                                
                                            print("DELETED")
        }
        
        delete.backgroundColor = UIColor.red
        return delete
    }
    
    func contextualToggleFlagAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        // 2
        let flag = UIContextualAction(style: .normal,
                                        title: "Report Post") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            self.sendEmail(postID: self.posts[indexPath.row].postId)
                                            print("FLAGGED")
        }
                                            
        flag.backgroundColor = UIColor.orange
        return flag
    }
    
    func sendEmail(postID: String) {
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setSubject("Report an Inappropriate post \(postID)")
            mail.setToRecipients(["information@ampedtechnologies.com"])
            mail.setMessageBody("An inapproriate post has been submitted to the Nation. The post code is \(postID). If you would like to add any more information, please do so below. ", isHTML: true)
            
            present(mail, animated: true)
        } else {
            print("Email Fail")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    /*
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func table(_ tablView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            print("Delete cell")
        }
    }
    */
    var posts: [Posts] = []
    var friendPosts: [Posts] = []
    
    // Download posts from the database
    func getPosts(company: String, type: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        print("Here")
        var commentNumb = 0
        ref.child(company).child(type).child("Feed").observeSingleEvent(of: .value, with: { (snapshot) in
        
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            for snap in snapshots! {
            let postId      = snap.key
            let name        = snap.childSnapshot(forPath: "Name").value as! String
            let postImage   = snap.childSnapshot(forPath: "Image").value as! String
            let message     = snap.childSnapshot(forPath: "Message").value as! String
            let profilePic  = snap.childSnapshot(forPath: "ProfilePic").value as! String
            let senderID    = snap.childSnapshot(forPath: "Sender ID").value as! String
            let link        = snap.childSnapshot(forPath: "link").value as! String
            commentNumb     = Int(snap.childSnapshot(forPath: "Comments").childrenCount)
            
                let p = Posts(name: name, profileImage: profilePic, message: message, postImage: postImage, postId: postId, comNumb: commentNumb, link: link, senderID: senderID)

            self.posts.insert(p, at: 0)
            if self.friendsArray.contains(senderID) {
                    print("The sender ID is \(senderID)")
                self.friendPosts.insert(p, at: 0)
                    print(" THe number of posts are \(self.friendPosts.count)")
                }
            }
            completionHandler(true)
            
        })
        
    }
    
    var newsArray: [Posts] = []
    var friendsArray: [String] = []
    
    var userSenderID: String!
    
    func getUserSenderID(company: String){
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value) { (snapshot) in
            self.userSenderID = snapshot.childSnapshot(forPath: "senderId").value as! String
        }
    }
    
    
    // Get the list of senderIds the user has added to their friends nation
    func getFriendList(company: String, completionHandler:@escaping (_ status: Bool)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        
        ref.child(company).child(userID).child("Friend Nation").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            for snap in snapshots! {
                print(snap.key)
                
                let senderID  = snap.childSnapshot(forPath: "Sender ID").value as! String
                
                self.friendsArray.append(senderID)
        }
            completionHandler(true)
        })
    }
    
    // Setup for top menu bar.
    var titleArray: [String] = ["Global Nation", "News Feed", "Friends Nation"]
    // Set the number of cells to the number of images in the imageURLs array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    // Set properties of each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as! NationButtonsCollectionViewCell
        
        cell.titleOut.text = titleArray[indexPath.row]
        cell.layer.cornerRadius = 5.0
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let selCell = collectionView.cellForItem(at: indexPath) as! NationButtonsCollectionViewCell
        
        selCell.backgroundColor = .darkGray
        print(titleArray[indexPath.row])
        selCell.cellTint.backgroundColor = .green
        selCell.titleOut.textColor = .white
        
        // What to set if certain buttons on the top menu are selected
        if titleArray[indexPath.row] == "Global Nation" {
            self.socType = "Nation"
            app.socType = "Nation"
            posts.removeAll()
            cameraButton.isHidden = false
            cameraButton.setBackgroundImage(#imageLiteral(resourceName: "cameraIcon2.png"), for: .normal)
            cameraButton.removeTarget(self, action: #selector(SocialFeedViewController.addFriendButton(sender:)), for: .touchUpInside)
            cameraButton.addTarget(self, action: #selector(SocialFeedViewController.postButton(sender:)), for: .touchUpInside)
            getPosts(company: orgName, type: "Nation", completionHandler: { (result) in
                
                self.tableView.reloadData()
            })
        } else if titleArray[indexPath.row] == "News Feed" {
            self.socType = "News Feed"
            app.socType = "News"
            posts.removeAll()
            cameraButton.isHidden = true
            getPosts(company: orgName, type: "News", completionHandler: { (result) in
                
                self.tableView.reloadData()
            })
        } else if titleArray[indexPath.row] == "Friends Nation" {
            self.socType = "Nation"
            app.socType = "Nation"
            posts.removeAll()
            cameraButton.isHidden = false
            cameraButton.setBackgroundImage(#imageLiteral(resourceName: "friendsIcon.png"), for: .normal)
            cameraButton.removeTarget(self, action: #selector(SocialFeedViewController.postButton(sender:)), for: .touchUpInside)
            cameraButton.addTarget(self, action: #selector(SocialFeedViewController.addFriendButton(sender:)), for: .touchUpInside)
            getFriendList(company: orgName) { (result) in
                print("Getting Posts")
                self.getPosts(company: self.orgName, type: "Nation", completionHandler: { (result) in
                    self.posts = self.friendPosts
                    self.tableView.reloadData()
                })
            }
        }
        
    }
    
    // Setup what happens to cell when it is DEselected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selCell = collectionView.cellForItem(at: indexPath) as! NationButtonsCollectionViewCell
        
        selCell.backgroundColor = UIColor.lightGray
        selCell.cellTint.backgroundColor = .clear
        selCell.titleOut.textColor = .black
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Retrieve posts from the network
        getPosts(company: orgName, type: "Nation", completionHandler: { (result) in
            self.tableView.reloadData()
        })
        // Function to get list of friends and add to friends array
        getFriendList(company: orgName) { (result) in
            print(self.friendsArray.count)
        }
        
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let commentsViewController = segue.destination as? commentsViewController {commentsViewController.postID = postID
            
        }

    }
    

}
