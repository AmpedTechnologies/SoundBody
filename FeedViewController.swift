//
//  FeedViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 5/2/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController



//UIViewController
class FeedViewController: JSQMessagesViewController  {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var messages = [JSQMessage]()
    var orgName: String!
    //let alert = UIAlertController(title: "Your Message is to Long!", message: "Everyone wants to read the 60 characters you have to post, nothing more!", preferredStyle: .alert)
    
    func getUserInformation(company: String, completionHandler:@escaping (_ status: String)-> Void) {
        let userID: String = (Auth.auth().currentUser?.uid)!
        ref.child(company).child(userID).child("userDetails").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() == true {
                let firstName = snapshot.childSnapshot(forPath: "first name").value as? String
                let lastName = snapshot.childSnapshot(forPath: "last name").value as? String
                self.senderDisplayName = firstName! + " " + lastName!
                self.senderId = snapshot.childSnapshot(forPath: "senderId").value as? String
            } else {
                    completionHandler("")
                    return
            }
            
            completionHandler("COMPLETE")
            
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        orgName = app.scores.value(forKey: "organization") as! String
        getUserInformation(company: orgName) { (result) in
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        orgName = app.scores.value(forKey: "organization") as! String
        setupBackButton()
        //let chat = ref.child("BetaUsers").child("Nation").child("Feed")
        
        
        
        //print("The details are: SenderId = " + senderId + " and name = " + senderDisplayName)
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        //JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "Emoji! copy.png"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        print(orgName)
        checkForNew(company: orgName)
        
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "backButton.png")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "backButton.png")
        
    
        // Do any additional setup after loading the view.
    }
    
    func checkForNew(company: String){
        print(company)
        let query = ref.child(company).child("Message Board").queryLimited(toLast: 50)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["text"],
                !text.isEmpty
            {
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    self?.messages.append(message)
                    
                    self?.finishReceivingMessage()
                }
            }
        })
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let alert = UIAlertController(title: "Your Message is " + String(text.count) + " characters!", message: "Everyone wants to read the 60 characters you have to post, nothing more!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "CLOSE", style: .cancel, handler: nil))
        print(orgName)
       let refTwo = ref.child(self.orgName).child("Message Board").childByAutoId()
        if text.count > 60 {
            self.present(alert, animated: true)
        } else {
       
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]
        
        refTwo.setValue(message)
        print("MESSAGE SENT")
           // checkForNew(company: orgName)
        finishSendingMessage()
        }
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
