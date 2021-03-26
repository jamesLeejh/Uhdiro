//
//  EventDetailViewCell.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 07/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit
import ReadMoreTextView

class EventDetailViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellExplainTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
