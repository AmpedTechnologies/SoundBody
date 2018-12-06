//
//  ProgramsTableViewCell.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 6/20/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit

class ProgramsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var programImage: UIImageView!
    @IBOutlet weak var programLabel: UILabel!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 4
            frame.size.height -= 2 * 4
            layer.cornerRadius = 5.0
            layer.masksToBounds = true
        
            super.frame = frame
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
