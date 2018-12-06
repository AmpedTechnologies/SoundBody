//
//  RxPathwayReviewViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 10/25/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import Firebase

class rxRec {
    var name: String!
    var time: Int!
    
    init(name: String, time: Int){
        self.name = name
        self.time = time
        
    }
}

class RxPathwayReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var orgName: String!
    var ref: DatabaseReference!
    let app = UIApplication.shared.delegate as! AppDelegate
    
    var rxProg: [rxRec] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgName = app.organziation
        tableView.delegate = self
        tableView.dataSource = self
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rxProg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RxCell") as! RxPathwayCell
        
        return cell
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
